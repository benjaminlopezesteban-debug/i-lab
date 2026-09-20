"""i-lab :: pasarela de WhatsApp (Cloud API de Meta).

Expone el webhook que Meta verifica y al que envía los mensajes entrantes.
Necesita una URL pública: túnel (cloudflared, ngrok) o dominio propio.
"""

import logging
import os

import httpx
from fastapi import FastAPI, Query, Request, Response

GRAPH_API = "https://graph.facebook.com/v21.0"
VERIFY_TOKEN = os.environ.get("WHATSAPP_VERIFY_TOKEN", "")
ACCESS_TOKEN = os.environ.get("WHATSAPP_ACCESS_TOKEN", "")
PHONE_NUMBER_ID = os.environ.get("WHATSAPP_PHONE_NUMBER_ID", "")
LITELLM_BASE_URL = os.environ.get("LITELLM_BASE_URL", "http://litellm:4000")
LITELLM_API_KEY = os.environ.get("LITELLM_API_KEY", "")
MODEL = os.environ.get("GATEWAY_MODEL", "sonnet-5")
ALLOWED = {
    n.strip()
    for n in os.environ.get("WHATSAPP_ALLOWED_NUMBERS", "").split(",")
    if n.strip()
}

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("ilab.whatsapp")

app = FastAPI(title="i-lab WhatsApp gateway")


@app.get("/health")
async def health() -> dict:
    return {"status": "ok"}


@app.get("/webhook")
async def verify(
    mode: str = Query(alias="hub.mode", default=""),
    token: str = Query(alias="hub.verify_token", default=""),
    challenge: str = Query(alias="hub.challenge", default=""),
) -> Response:
    if mode == "subscribe" and token == VERIFY_TOKEN:
        return Response(content=challenge, media_type="text/plain")
    return Response(status_code=403)


@app.post("/webhook")
async def receive(request: Request) -> dict:
    body = await request.json()
    for entry in body.get("entry", []):
        for change in entry.get("changes", []):
            for msg in change.get("value", {}).get("messages", []):
                if msg.get("type") != "text":
                    continue
                sender = msg["from"]
                if ALLOWED and sender not in ALLOWED:
                    log.warning("mensaje descartado de %s", sender)
                    continue
                respuesta = await ask_model(msg["text"]["body"])
                await send_text(sender, respuesta)
    return {"status": "received"}


async def ask_model(text: str) -> str:
    payload = {"model": MODEL, "messages": [{"role": "user", "content": text}]}
    async with httpx.AsyncClient(timeout=120) as client:
        resp = await client.post(
            f"{LITELLM_BASE_URL}/v1/chat/completions",
            json=payload,
            headers={"Authorization": f"Bearer {LITELLM_API_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]


async def send_text(to: str, text: str) -> None:
    async with httpx.AsyncClient(timeout=30) as client:
        await client.post(
            f"{GRAPH_API}/{PHONE_NUMBER_ID}/messages",
            json={"messaging_product": "whatsapp", "to": to, "text": {"body": text}},
            headers={"Authorization": f"Bearer {ACCESS_TOKEN}"},
        )

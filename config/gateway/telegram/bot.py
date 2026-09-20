"""i-lab :: pasarela de Telegram.

Esqueleto mínimo: recibe mensajes por long polling, filtra por lista blanca y
pregunta al modelo a través de LiteLLM. El salto siguiente (delegar la tarea a
OpenHands en vez de responder directo) queda marcado con TODO.
"""

import logging
import os

import httpx
from telegram import Update
from telegram.ext import Application, ContextTypes, MessageHandler, filters

LITELLM_BASE_URL = os.environ.get("LITELLM_BASE_URL", "http://litellm:4000")
LITELLM_API_KEY = os.environ["LITELLM_API_KEY"]
MODEL = os.environ.get("GATEWAY_MODEL", "sonnet-5")
ALLOWED = {
    int(uid)
    for uid in os.environ.get("TELEGRAM_ALLOWED_USER_IDS", "").split(",")
    if uid.strip()
}

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("ilab.telegram")


def load_system_prompt() -> str:
    path = "/app/agents/prompts/system.md"
    try:
        with open(path, encoding="utf-8") as fh:
            return fh.read()
    except FileNotFoundError:
        return "Eres el asistente del laboratorio i-lab."


async def ask_model(text: str) -> str:
    payload = {
        "model": MODEL,
        "messages": [
            {"role": "system", "content": load_system_prompt()},
            {"role": "user", "content": text},
        ],
    }
    async with httpx.AsyncClient(timeout=120) as client:
        resp = await client.post(
            f"{LITELLM_BASE_URL}/v1/chat/completions",
            json=payload,
            headers={"Authorization": f"Bearer {LITELLM_API_KEY}"},
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]


async def on_message(update: Update, _: ContextTypes.DEFAULT_TYPE) -> None:
    user_id = update.effective_user.id
    if ALLOWED and user_id not in ALLOWED:
        log.warning("mensaje descartado de %s (fuera de la lista blanca)", user_id)
        return

    # TODO: enrutar a un workflow de agents/workflows/ cuando el mensaje sea
    # una tarea sobre un repo de workspaces/, en vez de una consulta suelta.
    respuesta = await ask_model(update.message.text)
    await update.message.reply_text(respuesta)


def main() -> None:
    app = Application.builder().token(os.environ["TELEGRAM_BOT_TOKEN"]).build()
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, on_message))
    log.info("pasarela de Telegram lista (modelo=%s)", MODEL)
    app.run_polling()


if __name__ == "__main__":
    main()

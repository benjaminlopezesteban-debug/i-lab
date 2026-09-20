# Puesta en marcha

## Requisitos

- Docker Engine y el plugin `docker compose`
- El usuario en el grupo `docker` (`groups | grep docker`)
- Al menos una clave de proveedor de modelos

## Pasos

```bash
./scripts/bootstrap.sh            # red ilab-net + secrets/.env desde la plantilla
$EDITOR secrets/.env              # rellenar claves (openssl rand -hex 32)
./scripts/check-secrets.sh        # comprobar antes de levantar
./scripts/up.sh core              # postgres + redis + litellm
```

Verificar el proxy:

```bash
curl -s http://localhost:4000/health/liveliness
curl -s http://localhost:4000/v1/models -H "Authorization: Bearer $LITELLM_MASTER_KEY" | jq
```

Una primera llamada de prueba:

```bash
curl -s http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"sonnet-5","messages":[{"role":"user","content":"hola"}]}' | jq -r '.choices[0].message.content'
```

## Stacks adicionales

```bash
./scripts/up.sh openhands         # agente en http://localhost:3000
./scripts/up.sh obs               # langfuse 3001, grafana 3002
./scripts/up.sh gateway           # telegram y whatsapp (requiere tokens)
```

El stack `gateway` se construye localmente la primera vez:
`docker compose -f compose/docker-compose.gateway.yml build`.

WhatsApp necesita una URL pública para el webhook: un túnel
(`cloudflared tunnel --url http://localhost:8081`) o un dominio propio.

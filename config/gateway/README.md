# config/gateway

Pasarelas de mensajería: convierten un mensaje de Telegram o WhatsApp en una
tarea para el agente y devuelven la respuesta al mismo chat.

| Subcarpeta  | Entrada                          | Notas                                   |
|-------------|----------------------------------|-----------------------------------------|
| `telegram/` | long polling (sin puerto abierto)| Lista blanca por `TELEGRAM_ALLOWED_USER_IDS` |
| `whatsapp/` | webhook HTTP (puerto 8081)       | Requiere URL pública (túnel o dominio)  |

Ambas se construyen desde `compose/docker-compose.gateway.yml` y hablan con el
agente por la red interna `ilab-net`. Ningún token se escribe aquí: todo sale
de `secrets/.env`.

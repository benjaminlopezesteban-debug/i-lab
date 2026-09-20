# Arquitectura

El laboratorio se divide en cuatro stacks de Docker Compose que comparten una
red externa, `ilab-net`. Cada uno se levanta y se apaga por separado.

```
                 ┌──────────── gateway ────────────┐
Telegram ───────▶│ telegram-gateway                │
WhatsApp ───────▶│ whatsapp-gateway (webhook 8081) │
                 └───────────────┬─────────────────┘
                                 │
                 ┌───────────────▼─────────────────┐
                 │ openhands (3000)                │ ← workspaces/ montado en /workspace
                 └───────────────┬─────────────────┘
                                 │  API OpenAI-compatible
                 ┌───────────────▼─────────────────┐
   core          │ litellm (4000)                  │
                 │   ├── postgres (claves, gasto)  │
                 │   └── redis (caché, colas)      │
                 └───────────────┬─────────────────┘
                                 │  trazas y métricas
                 ┌───────────────▼─────────────────┐
   obs           │ langfuse (3001) · prometheus    │
                 │ clickhouse · grafana (3002)     │
                 └─────────────────────────────────┘
```

## Decisiones

| Decisión | Motivo |
|---|---|
| Un único proxy (LiteLLM) delante de todos los modelos | Un solo lugar para claves, caché, presupuesto y trazas; cambiar de proveedor no toca a los clientes. |
| Red externa `ilab-net` en vez de una por stack | Permite levantar solo `core` o añadir `obs` después sin recrear nada. |
| `workspaces/` fuera del control de versiones | Son clones de otros repos; el trabajo del agente se versiona en su repo de origen. |
| Prompts en `agents/`, no en `config/` | Los comparten OpenHands y los gateways; se editan en un solo sitio. |
| Langfuse reutiliza el PostgreSQL de `core` | Menos piezas; el stack de observabilidad es opcional. |

## Puertos

| Servicio   | Puerto host | Variable            |
|------------|-------------|---------------------|
| LiteLLM    | 4000        | `LITELLM_PORT`      |
| OpenHands  | 3000        | `OPENHANDS_PORT`    |
| WhatsApp   | 8081        | `WHATSAPP_WEBHOOK_PORT` |
| Langfuse   | 3001        | `LANGFUSE_PORT`     |
| Grafana    | 3002        | `GRAFANA_PORT`      |
| Prometheus | 9090        | `PROMETHEUS_PORT`   |
| PostgreSQL | 5432        | `POSTGRES_PORT`     |
| Redis      | 6379        | `REDIS_PORT`        |

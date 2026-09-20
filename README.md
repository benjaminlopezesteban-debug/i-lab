# i-lab

Laboratorio local de agentes de IA: un proxy único de modelos, un agente que
trabaja sobre repositorios reales, pasarelas de mensajería para hablarle desde
el teléfono y un stack de observabilidad para ver qué hace y cuánto cuesta.

Todo corre en Docker, en cuatro stacks independientes que comparten la red
`ilab-net`.

| Stack       | Contiene                                   | Se levanta con        |
|-------------|--------------------------------------------|-----------------------|
| `core`      | LiteLLM · PostgreSQL · Redis               | `make core`           |
| `openhands` | Agente OpenHands sobre `workspaces/`       | `make agent`          |
| `gateway`   | Pasarelas de Telegram y WhatsApp           | `make gateway`        |
| `obs`       | Langfuse · Prometheus · Grafana            | `make obs`            |

## Arranque rápido

```bash
make bootstrap          # crea la red y secrets/.env desde la plantilla
$EDITOR secrets/.env    # rellenar claves
make check              # verifica que no falte nada
make core               # LiteLLM queda en http://localhost:4000
```

Detalle en [docs/puesta-en-marcha.md](docs/puesta-en-marcha.md).

## Estructura

```
i-lab/
├── compose/            # un archivo por stack
│   ├── docker-compose.core.yml
│   ├── docker-compose.openhands.yml
│   ├── docker-compose.gateway.yml
│   └── docker-compose.obs.yml
├── config/             # configuración de los servicios (sin secretos)
│   ├── litellm.config.yaml
│   ├── prometheus.yml
│   ├── openhands/
│   └── gateway/        # telegram/ y whatsapp/ (código de las pasarelas)
├── agents/
│   ├── prompts/        # prompts de sistema, compartidos por agente y gateways
│   └── workflows/      # flujos de varios pasos, en YAML
├── workspaces/         # repos donde trabaja el agente (fuera de git)
├── secrets/            # .env — nunca a git
├── scripts/            # bootstrap, up, down, logs, check-secrets
├── docs/
└── Makefile
```

## Principios

1. **Un solo camino a los modelos.** Nadie llama a un proveedor directamente:
   todo pasa por LiteLLM, que concentra claves, caché, presupuesto y trazas.
2. **Los secretos, en un solo archivo.** `secrets/.env`, permisos 600, fuera de
   git. `config/` solo contiene referencias a variables.
3. **Stacks separables.** El laboratorio sirve con solo `core` levantado; el
   resto se enciende cuando hace falta.
4. **El trabajo del agente se versiona donde corresponde.** `workspaces/` son
   clones de otros repos; sus commits van allí, no aquí.

## Documentación

- [Arquitectura](docs/arquitectura.md) — diagrama, decisiones y puertos
- [Puesta en marcha](docs/puesta-en-marcha.md) — instalación paso a paso
- [Operación](docs/operacion.md) — día a día, añadir modelos y repos, costos
- [Seguridad](docs/seguridad.md) — secretos, exposición y límites del agente

## Estado

Estructura y configuración base listas. Pendiente: el runner de
`agents/workflows/` (`scripts/run-workflow.sh` es un esqueleto) y la conexión
de los gateways con OpenHands (hoy responden directo vía LiteLLM).

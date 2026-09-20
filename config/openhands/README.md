# config/openhands

Configuración del agente OpenHands.

- `config.toml` — configuración principal (modelo, sandbox, límites). Se monta
  como solo lectura en `/app/config`.
- Los prompts de sistema y los flujos de trabajo **no** viven aquí, sino en
  `agents/prompts/` y `agents/workflows/`, para que sean reutilizables desde
  los gateways.

El modelo se declara con el prefijo `openai/` porque LiteLLM expone una API
OpenAI-compatible; el nombre después del prefijo es el `model_name` definido en
`config/litellm.config.yaml`.

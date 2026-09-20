# agents/workflows

Flujos de varios pasos que el laboratorio ejecuta de forma repetible
(revisar un diff, actualizar dependencias, generar un informe).

Cada workflow es un YAML con `entradas` y `pasos`. Tipos de paso previstos:

| Tipo              | Qué hace                                        |
|-------------------|-------------------------------------------------|
| `shell`           | Ejecuta un comando y captura su salida          |
| `llm`             | Llama a un modelo vía LiteLLM con un prompt     |
| `escribir_archivo`| Guarda el resultado en una ruta del laboratorio |

`ejemplo-revision-pr.yaml` es la plantilla de referencia. El runner
(`scripts/run-workflow.sh`) todavía es un esqueleto.

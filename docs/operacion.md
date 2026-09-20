# Operación

## Día a día

```bash
./scripts/up.sh core openhands    # levantar
./scripts/logs.sh core litellm    # seguir logs de un servicio
docker ps --filter name=ilab-     # qué está corriendo
./scripts/down.sh                 # apagar todo (sin borrar datos)
```

`./scripts/down.sh core --volumes` borra también los volúmenes: pide
confirmación y se lleva la base de datos de LiteLLM (claves virtuales y
registro de gasto). No es reversible.

## Añadir un repo al agente

```bash
git clone <url> workspaces/mi-repo
./scripts/up.sh openhands
```

El agente ve la carpeta como `/workspace/mi-repo`. Lo que escriba se revisa y
se hace commit en el repo de destino, no en i-lab.

## Añadir un modelo

1. Nueva entrada en `model_list` de `config/litellm.config.yaml`.
2. La clave del proveedor, en `secrets/.env` y pasada al servicio en
   `compose/docker-compose.core.yml`.
3. `./scripts/up.sh core` recrea el contenedor con la configuración nueva.

## Costos

LiteLLM lleva el gasto en PostgreSQL y corta al llegar a `max_budget`
(50 USD / 30 días por defecto, en `general_settings`). El detalle por llamada
se ve en Langfuse si el stack `obs` está levantado.

## Problemas frecuentes

| Síntoma | Causa habitual |
|---|---|
| `network ilab-net not found` | Falta `./scripts/bootstrap.sh` |
| LiteLLM reinicia en bucle | Variable obligatoria vacía en `secrets/.env` |
| El agente no ve un repo | El clon no está dentro de `workspaces/` |
| El gateway responde 403 | El remitente no está en la lista blanca |

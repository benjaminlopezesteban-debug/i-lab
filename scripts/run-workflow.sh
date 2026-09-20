#!/usr/bin/env bash
# i-lab :: ejecuta un workflow de agents/workflows/.
# ESQUELETO: valida entradas y muestra los pasos; la ejecución real está por hacer.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

workflow="${1:-}"
[[ -n "$workflow" ]] || die "uso: ./scripts/run-workflow.sh <nombre> [clave=valor...]"

archivo="$ILAB_ROOT/agents/workflows/${workflow}.yaml"
[[ -f "$archivo" ]] || die "no existe el workflow: $archivo"

require_env
log "workflow: $workflow"
grep -E '^\s*(- id|name|descripcion):' "$archivo"

# TODO: interpretar `pasos` (shell / llm / escribir_archivo) y encadenar salidas.
warn "el runner todavía no ejecuta los pasos; ver agents/workflows/README.md"

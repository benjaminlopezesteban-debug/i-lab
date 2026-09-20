#!/usr/bin/env bash
# i-lab :: funciones comunes a los scripts. Se incluye con `source`.

set -euo pipefail

ILAB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ILAB_ROOT/secrets/.env"
NETWORK="ilab-net"

# Stacks disponibles: nombre -> archivo compose
declare -A STACKS=(
  [core]="compose/docker-compose.core.yml"
  [openhands]="compose/docker-compose.openhands.yml"
  [gateway]="compose/docker-compose.gateway.yml"
  [obs]="compose/docker-compose.obs.yml"
)

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

require_env() {
  [[ -f "$ENV_FILE" ]] || die "falta secrets/.env — copia secrets/.env.example y rellénalo"
}

ensure_network() {
  docker network inspect "$NETWORK" >/dev/null 2>&1 || {
    log "creando la red $NETWORK"
    docker network create "$NETWORK" >/dev/null
  }
}

compose_file_for() {
  local stack="$1"
  [[ -n "${STACKS[$stack]:-}" ]] || die "stack desconocido: $stack (opciones: ${!STACKS[*]})"
  printf '%s/%s' "$ILAB_ROOT" "${STACKS[$stack]}"
}

# dc <stack> <args...>  — docker compose con el env-file y el archivo correctos
dc() {
  local stack="$1"; shift
  docker compose --env-file "$ENV_FILE" -f "$(compose_file_for "$stack")" "$@"
}

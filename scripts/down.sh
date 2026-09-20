#!/usr/bin/env bash
# i-lab :: detiene stacks.  Uso: ./scripts/down.sh [stack...] [--volumes]
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env

extra=()
stacks=()
for arg in "$@"; do
  case "$arg" in
    --volumes|-v) extra+=(--volumes) ;;
    *) stacks+=("$arg") ;;
  esac
done
[[ ${#stacks[@]} -gt 0 ]] || stacks=(obs gateway openhands core)

if [[ ${#extra[@]} -gt 0 ]]; then
  warn "se borrarán los volúmenes de: ${stacks[*]}"
  read -rp "¿Continuar? [s/N] " r
  [[ "$r" =~ ^[sS]$ ]] || die "cancelado"
fi

for stack in "${stacks[@]}"; do
  log "deteniendo stack: $stack"
  dc "$stack" down "${extra[@]}"
done

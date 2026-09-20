#!/usr/bin/env bash
# i-lab :: levanta uno o varios stacks.  Uso: ./scripts/up.sh core openhands
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env
ensure_network

stacks=("$@")
[[ ${#stacks[@]} -gt 0 ]] || stacks=(core)

for stack in "${stacks[@]}"; do
  log "levantando stack: $stack"
  dc "$stack" up -d
done

log "estado actual:"
docker ps --filter "name=ilab-" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

#!/usr/bin/env bash
# i-lab :: sigue los logs de un stack.  Uso: ./scripts/logs.sh core [servicio]
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env
stack="${1:-core}"; shift || true
dc "$stack" logs -f --tail 100 "$@"

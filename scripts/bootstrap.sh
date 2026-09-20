#!/usr/bin/env bash
# i-lab :: prepara el laboratorio por primera vez (red, .env, comprobaciones).
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v docker >/dev/null || die "docker no está instalado"
docker compose version >/dev/null 2>&1 || die "falta el plugin 'docker compose'"

if [[ ! -f "$ENV_FILE" ]]; then
  log "creando secrets/.env desde la plantilla"
  cp "$ILAB_ROOT/secrets/.env.example" "$ENV_FILE"
  chmod 600 "$ENV_FILE"
  warn "rellena secrets/.env antes de levantar nada (openssl rand -hex 32)"
fi

ensure_network
log "creando carpetas de trabajo"
mkdir -p "$ILAB_ROOT/workspaces" "$ILAB_ROOT/docs/revisiones"

log "listo. Siguiente paso:  ./scripts/up.sh core"

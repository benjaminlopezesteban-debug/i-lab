#!/usr/bin/env bash
# i-lab :: verifica secrets/.env — existencia, permisos y variables obligatorias.
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

require_env

perms="$(stat -c '%a' "$ENV_FILE")"
[[ "$perms" == "600" ]] || warn "secrets/.env tiene permisos $perms; se recomienda 600 (chmod 600 secrets/.env)"

obligatorias=(
  POSTGRES_PASSWORD
  REDIS_PASSWORD
  LITELLM_MASTER_KEY
  LITELLM_SALT_KEY
)

faltan=()
for var in "${obligatorias[@]}"; do
  valor="$(grep -E "^${var}=" "$ENV_FILE" | head -1 | cut -d= -f2-)"
  [[ -n "${valor//[[:space:]]/}" && "$valor" != "sk-" ]] || faltan+=("$var")
done

if [[ ${#faltan[@]} -gt 0 ]]; then
  die "variables sin valor en secrets/.env: ${faltan[*]}"
fi

if git -C "$ILAB_ROOT" ls-files --error-unmatch secrets/.env >/dev/null 2>&1; then
  die "secrets/.env está versionado en git — sácalo ya (git rm --cached secrets/.env)"
fi

log "secrets/.env correcto"

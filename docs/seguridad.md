# Seguridad

El laboratorio ejecuta un agente con acceso a código y a un socket de Docker.
Estas son las líneas que no se cruzan.

## Secretos

- Todo vive en `secrets/.env`, con permisos `600`, fuera de git.
- `config/` no contiene ni una clave: solo referencias `os.environ/…`.
- `scripts/check-secrets.sh` falla si `secrets/.env` aparece versionado.
- Una clave filtrada se revoca en el proveedor; borrar el archivo no basta.

## Superficie expuesta

- Por defecto, todo escucha en `localhost`. Nada se publica a internet salvo el
  webhook de WhatsApp, y para eso se usa un túnel con TLS.
- Los gateways aplican lista blanca (`TELEGRAM_ALLOWED_USER_IDS`,
  `WHATSAPP_ALLOWED_NUMBERS`). Sin lista, cualquiera que encuentre el bot puede
  gastar el presupuesto.

## El agente

- OpenHands monta `/var/run/docker.sock`: dentro del contenedor tiene, de
  hecho, control del demonio Docker del host. Por eso el laboratorio se ejecuta
  en una máquina de desarrollo, no en un servidor con datos ajenos.
- El agente solo escribe en `/workspace` (es decir, `workspaces/`).
- El prompt de sistema le prohíbe leer `secrets/` y hacer `git push`; es una
  barrera blanda, no una garantía: revisa los diffs antes de subirlos.

## Presupuesto

`max_budget` en `config/litellm.config.yaml` es el freno económico ante un
bucle del agente o un bot descubierto. Mantenlo bajo mientras experimentas.

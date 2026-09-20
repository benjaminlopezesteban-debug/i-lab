# secrets/

Aquí vive `secrets/.env`, que **nunca** entra a git (`.gitignore` ignora todo
este directorio salvo este README y la plantilla).

```bash
cp secrets/.env.example secrets/.env
chmod 600 secrets/.env
openssl rand -hex 32        # para cada valor vacío que sea una clave interna
```

Reglas:

- Si una clave se filtra, se revoca en el proveedor; no basta con borrar el
  archivo.
- Los contenedores reciben los valores por `--env-file secrets/.env`; ninguna
  clave se escribe dentro de `config/`.
- `scripts/check-secrets.sh` verifica que el archivo existe, que tiene permisos
  600 y que no falta ninguna variable obligatoria.

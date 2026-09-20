# workspaces/

Repositorios sobre los que trabaja el agente. Se montan en `/workspace` dentro
del contenedor de OpenHands.

Cada subcarpeta es un clon independiente y **no** se versiona en este
repositorio (`.gitignore` ignora el contenido). Para añadir uno:

```bash
git clone <url> workspaces/<nombre>
```

Lo que el agente escriba aquí es código real: revísalo y haz commit tú, en el
repositorio de destino, no en i-lab.

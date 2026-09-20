# i-lab :: atajos sobre scripts/ — `make` a secas muestra esta ayuda.
.DEFAULT_GOAL := help
.PHONY: help bootstrap check core agent gateway obs all down clean logs ps

help:  ## Muestra esta ayuda
	@grep -E '^[a-z-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[1;34m%-12s\033[0m %s\n", $$1, $$2}'

bootstrap:  ## Prepara red, secrets/.env y carpetas
	@./scripts/bootstrap.sh

check:  ## Verifica secrets/.env
	@./scripts/check-secrets.sh

core:  ## Levanta litellm + postgres + redis
	@./scripts/up.sh core

agent:  ## Levanta OpenHands
	@./scripts/up.sh openhands

gateway:  ## Levanta las pasarelas de Telegram y WhatsApp
	@./scripts/up.sh gateway

obs:  ## Levanta Langfuse, Prometheus y Grafana
	@./scripts/up.sh obs

all:  ## Levanta todos los stacks
	@./scripts/up.sh core openhands obs gateway

down:  ## Detiene todos los stacks (conserva los datos)
	@./scripts/down.sh

clean:  ## Detiene y borra volúmenes (pide confirmación)
	@./scripts/down.sh core openhands obs gateway --volumes

logs:  ## Logs del stack core (make logs STACK=obs)
	@./scripts/logs.sh $(or $(STACK),core)

ps:  ## Contenedores del laboratorio
	@docker ps --filter "name=ilab-" --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

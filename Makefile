include .env
export

HELL := /bin/bash
COMPOSE_FILE := compose/docker-compose.core.yml
ENV_FILE     := .env
DC           := docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

.PHONY: net	up down restart ps logs logs-litellm sh-pg sh-redis health models

net:
	@docker network inspect ia-lab >/dev/null 2>&1 || docker network create ia-lab
	@echo "red ia-lab lista"

up:	
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) restart

ps:
	$(DC) ps

logs:
	$(DC) logs -f --tail=100

logs-litellm:
	$(DC) logs -f --tail=100 litellm

sh-pg:
	$(DC) exec postgres sh -c 'psql -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"'

sh-redis:
	$(DC) exec redis sh -c 'REDISCLI_AUTH="$$REDIS_PASSWORD" redis-cli ping'

health:
	@echo "--- Postgres ---"
	@$(DC) exec -T postgres sh -c 'pg_isready -U "$$POSTGRES_USER" -d "$$POSTGRES_DB"' || true
	@echo "--- Redis ---"
	@$(DC) exec -T redis sh -c 'REDISCLI_AUTH="$$REDIS_PASSWORD" redis-cli ping' || true
	@echo "--- LiteLLM liveliness ---"
	@curl -s http://127.0.0.1:4000/health/liveliness || echo "(sin respuesta)"
	@echo
	@echo "--- LiteLLM readiness ---"
	@curl -s http://127.0.0.1:4000/health/readiness || echo "(sin respuesta)"
	@echo

models:
	@curl -s -H "Authorization: Bearer $$LITELLM_MASTER_KEY" \
	  http://127.0.0.1:4000/v1/models | jq '.data[].id'
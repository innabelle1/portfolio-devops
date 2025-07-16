
ENV_FILE ?= .env.openai
COMPOSE_FILE ?= docker-compose.yml

build:
	docker compose -f $(COMPOSE_FILE) build

up:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up --build -d

clean:
	@echo "Clean Docker containers, images, and volumes..."
	@docker compose -f $(COMPOSE_FILE)  --env-file $(ENV_FILE)  down -v --remove-orphans
	@docker image prune -f
	@docker volume prune -f
	@echo "Optionally cleaning Maven target folders..."
	@find . -type d -name 'target' -exec rm -rf {} +

down:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

switch-openai:
	@$(MAKE) up ENV_FILE=.env.openai

switch-bedrock:
	@$(MAKE) up ENV_FILE=.env.bedrock


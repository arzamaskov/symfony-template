DOCKER_COMPOSE = docker compose
PHP_CONTAINER  = php-fpm
DB_CONTAINER   = postgres

.PHONY: help build up down restart logs shell composer sf db cache-clear ps lint lint-fix phpstan deptrac test qa

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker images
	$(DOCKER_COMPOSE) build

up: ## Start containers in background
	$(DOCKER_COMPOSE) up -d
	@echo ""
	@echo "  Application: http://localhost:8080"
	@echo ""

down: ## Stop and remove containers
	$(DOCKER_COMPOSE) down

restart: down up ## Restart containers

logs: ## Show container logs (follow mode)
	$(DOCKER_COMPOSE) logs -f

ps: ## Show running containers
	$(DOCKER_COMPOSE) ps

shell: ## Open shell in php-fpm container
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) sh

composer: ## Run Composer command (usage: make composer args="require symfony/orm-pack")
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) composer $(args)

sf: ## Run Symfony console command (usage: make sf args="make:controller")
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) php bin/console $(args)

db: ## Open psql in postgres container
	$(DOCKER_COMPOSE) exec $(DB_CONTAINER) psql -U $${POSTGRES_USER:-app} -d $${POSTGRES_DB:-app}

cache-clear: ## Clear Symfony cache
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) php bin/console cache:clear

## ---- Quality & Testing ----

lint: ## Run PHP-CS-Fixer in dry-run mode
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) vendor/bin/php-cs-fixer fix --dry-run --diff

lint-fix: ## Fix code style with PHP-CS-Fixer
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) vendor/bin/php-cs-fixer fix

phpstan: ## Run PHPStan static analysis
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) vendor/bin/phpstan analyse

deptrac: ## Run architecture dependency checks (Deptrac)
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) vendor/bin/deptrac analyse

test: ## Run PHPUnit tests
	$(DOCKER_COMPOSE) exec $(PHP_CONTAINER) bin/phpunit

qa: lint phpstan deptrac test ## Run all quality checks (lint + phpstan + deptrac + tests)

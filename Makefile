# Shelf.nu Docker Compose Makefile
# Convenient shortcuts for Docker Compose commands

.PHONY: help dev-start dev-stop dev-logs dev-build dev-restart dev-shell dev-migrate prod-start prod-stop prod-logs prod-build prod-deploy prod-shell prod-migrate

help:
	@echo "Shelf.nu Docker Compose Commands"
	@echo ""
	@echo "Development:"
	@echo "  make dev-start     - Start development environment"
	@echo "  make dev-stop      - Stop development environment"
	@echo "  make dev-logs      - Show development logs"
	@echo "  make dev-build     - Rebuild development environment"
	@echo "  make dev-restart   - Restart development environment"
	@echo "  make dev-shell     - Open shell in development container"
	@echo "  make dev-migrate   - Run database migrations (dev)"
	@echo ""
	@echo "Production:"
	@echo "  make prod-start    - Start production environment"
	@echo "  make prod-stop     - Stop production environment"
	@echo "  make prod-logs     - Show production logs"
	@echo "  make prod-build    - Build production image"
	@echo "  make prod-deploy   - Build and deploy production"
	@echo "  make prod-shell    - Open shell in production container"
	@echo "  make prod-migrate  - Run database migrations (prod)"
	@echo ""

# Development commands
dev-start:
	@echo "🚀 Starting development environment..."
	docker compose up -d
	@echo "✅ Development server started at http://localhost:3000"

dev-stop:
	@echo "🛑 Stopping development environment..."
	docker compose down

dev-logs:
	docker compose logs -f

dev-build:
	@echo "🔨 Rebuilding development environment..."
	docker compose up --build -d

dev-restart:
	docker compose restart

dev-shell:
	docker compose exec app bash

dev-migrate:
	@echo "🗄️  Running database migrations..."
	docker compose exec app npm run db:deploy

# Production commands
prod-start:
	@echo "🚀 Starting production environment..."
	docker compose -f docker-compose.prod.yml up -d
	@echo "✅ Production server started at http://localhost:8080"

prod-stop:
	@echo "🛑 Stopping production environment..."
	docker compose -f docker-compose.prod.yml down

prod-logs:
	docker compose -f docker-compose.prod.yml logs -f

prod-build:
	@echo "🔨 Building production image..."
	docker compose -f docker-compose.prod.yml build

prod-deploy:
	@echo "🚀 Deploying production environment..."
	docker compose -f docker-compose.prod.yml build
	docker compose -f docker-compose.prod.yml up -d

prod-shell:
	docker compose -f docker-compose.prod.yml exec app bash

prod-migrate:
	@echo "🗄️  Running database migrations..."
	docker compose -f docker-compose.prod.yml exec app npm run db:deploy

# Utility commands
validate-env:
	@./scripts/validate-env.sh

validate-env-prod:
	@./scripts/validate-env.sh .env.production

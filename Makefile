SHELL := /bin/zsh
PROJECT_ROOT := /Users/hongcheolsoo/development/k_medical

.PHONY: up down logs mysql prisma-generate prisma-migrate backend-dev backend-build backend-start health flutter-get flutter-analyze

up:
	cd $(PROJECT_ROOT) && docker compose up -d

down:
	cd $(PROJECT_ROOT) && docker compose down

logs:
	cd $(PROJECT_ROOT) && docker compose logs -f --tail=200

mysql:
	cd $(PROJECT_ROOT) && docker compose exec -it mysql mysql -uroot -ppassword -e 'SHOW DATABASES;'

prisma-generate:
	cd $(PROJECT_ROOT)/backend && corepack pnpm run prisma:generate

prisma-migrate:
	cd $(PROJECT_ROOT)/backend && corepack pnpm exec prisma migrate dev --name init

backend-dev:
	cd $(PROJECT_ROOT)/backend && corepack pnpm run dev

backend-build:
	cd $(PROJECT_ROOT)/backend && corepack pnpm run build

backend-start:
	node $(PROJECT_ROOT)/backend/dist/index.js &

health:
	curl -s http://localhost:4000/health || true

flutter-get:
	cd $(PROJECT_ROOT)/frontend && flutter pub get

flutter-analyze:
	cd $(PROJECT_ROOT)/frontend && flutter analyze

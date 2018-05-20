# Project variables
PROJECT_NAME ?= my_app
ORG_NAME ?= pixalar
REPO_NAME ?= my_app

# Filenames
DEV_COMPOSE_FILE := devops/dev/docker-compose.yml
REL_COMPOSE_FILE := devops/prod/docker-compose.yml
BASE_IMAGE_FILE := devops/base/Dockerfile
RELEASE_IMAGE_FILE := devops/prod/Dockerfile
DOCKER_REGISTRY ?= docker.io

DB_NAME := my_app_development
DB_CONTAINER := $(PROJECT_NAME)_db
DB_DUMP_FILE := tmp/pg_dump.pgdata

# Default command
DC := docker-compose -p $(DEV_PROJECT) -f $(DEV_COMPOSE_FILE)

.PHONY: build bundle run irake rails console migrate up down install test rubocop \
				attach start db owner

start: up attach

build: build-dev

build%dev:
	${INFO} 'Building the development image...'
	@ docker-compose -f $(DEV_COMPOSE_FILE) build

build%base:
	${INFO} 'Building the base image...'
	@ docker build -t $(ORG_NAME)/$(PROJECT_NAME):base -f $(BASE_IMAGE_FILE) .

build%prod:
	${INFO} 'Building the production image...'
	@ docker build -t $(ORG_NAME)/$(PROJECT_NAME):prod -f $(RELEASE_IMAGE_FILE) .

bundle:
	${INFO} 'Installing ruby gems...'
	@ $(DC) run --rm web bundle install --system --jobs 4 --clean

run:
	${INFO} 'Running command...'
	@ $(DC) run --rm web sh

rake:
	${INFO} 'Running rake command...'
	@ $(DC) run --rm web rake $(ARGS)

rails:
	${INFO} 'Running rails command...'
	@ $(DC) run --rm web rails $(ARGS)

db%run:
	${INFO} 'Running db container...'
	@ $(DC) run --rm --name $(DB_CONTAINER) -p '5432:5432' -d db
	${INFO} 'PostgreSQL Server is running on localhost:5432'

db%stop:
	${INFO} 'Stopping and removing db container...'
	@ docker stop $(DB_CONTAINER) && docker rm $(DB_CONTAINER)
	${INFO} 'Done'

db%backup: db-run
	${INFO} 'Backuping development DB...'
	@ docker exec -i $(DB_CONTAINER) pg_dump -F c -U rails -d $(DB_NAME) -v -c > $(DB_DUMP_FILE)
	${INFO} 'Backuping complete'
	$(MAKE) db-stop

db%restore: db-run
	${INFO} 'Restoring development DB...'
	@ docker exec -i $(DB_CONTAINER) pg_restore -F c -U rails -d $(DB_NAME) -v -c < $(DB_DUMP_FILE)
	${INFO} 'Restoring complete'
	$(MAKE) db-stop

owner:
	${INFO} 'Becoming the owner of the files...'
	@ sudo chown -R $(USER):$(USER) .
	${INFO} 'Done'

console:
	${INFO} 'Running rails console...'
	@ $(DC) run --rm web bundle exec rails c

migrate:
	${INFO} 'Running rake db:migrate...'
	@ $(DC) run --rm web bundle exec rake db:migrate

up:
	@ $(DC) up $(ARGS)

down:
	@ $(DC) down

attach:
	@ docker attach $(PROJECT_NAME)_web_1

install:
	${INFO} 'Creating db...'
	@ $(DC) run --rm web bundle exec rake db:create
	${INFO} 'Loading db schema...'
	@ $(DC) run --rm web bundle exec rake db:schema:load
	${INFO} 'Generating seeds...'
	@ $(DC) run --rm web bundle exec rake db:seed

test:
	${INFO} 'Running tests...'
	@ $(DC) run --rm web rspec $(ARGS)

rubocop:
	@ $(DC) run --rm web bundle exec rubocop

# Login to Docker registry
login:
	${INFO} "Logging in to Docker registry $$BASE_IMAGE_REGISTRY..."
	@ docker login
	${INFO} "Logged in to Docker registry $$BASE_IMAGE_REGISTRY"

# Logout of Docker registry
logout:
	${INFO} "Logging out of Docker registry $$BASE_IMAGE_REGISTRY..."
	@ docker logout
	${INFO} "Logged out of Docker registry $$BASE_IMAGE_REGISTRY"

publish:
	${INFO} "Publishing the production image to $(DOCKER_REGISTRY)/$(ORG_NAME)..."
	@ docker push $(DOCKER_REGISTRY)/$(ORG_NAME)/$(PROJECT_NAME):prod
	${INFO} "Publish complete"

# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell function
INFO := @bash -c ' printf $(YELLOW); echo "=> $$1"; printf $(NC)' VALUE

# Extract extra arguments
ifeq ($(firstword $(MAKECMDGOALS)),$(filter $(firstword $(MAKECMDGOALS)),rake rails test))
	ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
endif

# IMPORTANT - ensures arguments are not interpreted as make targets
%:
	@:

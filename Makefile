# Project variables
ORG_NAME     ?= pixalar
PROJECT_NAME ?= my_app

# Filenames
DEV_COMPOSE_FILE   := devops/dev/docker-compose.yml
REL_COMPOSE_FILE   := devops/prod/docker-compose.yml
BASE_IMAGE_FILE    := devops/base/Dockerfile
RELEASE_IMAGE_FILE := devops/prod/Dockerfile

# Useful shortcut
DC := docker-compose -p $(PROJECT_NAME) -f $(DEV_COMPOSE_FILE)

.PHONY: build bundle run rake rails console migrate up down install test rubocop \
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
	@ $(DC) run --rm web bin/rails $(ARGS)

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

test:
	${INFO} 'Running tests...'
	@ $(DC) run --rm web rspec $(ARGS)

rubocop:
	@ $(DC) run --rm web bundle exec rubocop

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

# Project variables
DOCKER_NAMESPACE ?= sshkarupa
PROJECT_NAME ?= $(shell basename `pwd`)

# Filenames
DEV_COMPOSE_FILE   := devops/dev/docker-compose.yml
REL_COMPOSE_FILE   := devops/prod/docker-compose.yml
DEV_IMAGE_FILE    := devops/dev/Dockerfile
BASE_IMAGE_FILE    := devops/base/Dockerfile
RELEASE_IMAGE_FILE := devops/prod/Dockerfile

# Useful shortcut
DC := docker-compose -p $(PROJECT_NAME) -f $(DEV_COMPOSE_FILE)

.PHONY: build bundle run rake rails console migrate up down test rubocop attach start owner

start: up attach

build: build-dev

build%dev:
	${INFO} 'Building the development image...'
	@ docker build -t $(DOCKER_NAMESPACE)/$(PROJECT_NAME):dev -f $(DEV_IMAGE_FILE) .

build%base:
	${INFO} 'Building the base image...'
	@ docker build -t $(DOCKER_NAMESPACE)/$(PROJECT_NAME):base -f $(BASE_IMAGE_FILE) .

build%prod:
	${INFO} 'Building the production image...'
	@ docker build -t $(DOCKER_NAMESPACE)/$(PROJECT_NAME):prod -f $(RELEASE_IMAGE_FILE) .

bundle:
	${INFO} 'Installing ruby gems...'
	@ $(DC) run --rm app bundle install --system --jobs 4 --clean

run:
	${INFO} 'Running command...'
	@ $(DC) run --rm app sh

rake:
	${INFO} 'Running rake command...'
	@ $(DC) run --rm app rake $(ARGS)

rails:
	${INFO} 'Running rails command...'
	@ $(DC) run --rm app bin/rails $(ARGS)

owner:
	${INFO} 'Becoming the owner of the files...'
	@ sudo chown -R `id -u`:`id -g` .
	${INFO} 'Done'

console:
	${INFO} 'Running rails console...'
	@ $(DC) run --rm app bundle exec rails c

migrate:
	${INFO} 'Running rake db:migrate...'
	@ $(DC) run --rm app bundle exec rake db:migrate

up: clean
	@ $(DC) up $(ARGS)

clean:
	@[ -f tmp/pids/server.pid ] && rm tmp/pids/server.pid || true

down:
	@ $(DC) down

attach:
	@ docker attach $(PROJECT_NAME)_app_1

test:
	${INFO} 'Running tests...'
	@ $(DC) run --rm app bundle exec rspec $(ARGS)

rubocop:
	@ $(DC) run --rm app bundle exec rubocop

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

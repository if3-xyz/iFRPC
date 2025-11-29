.PHONY: all build up down clean restart logs network configure

all: network clean configure build up

configure:
	@bash -c 'read -p "Enter chainID: " chainid && ./configure.sh $$chainid'

network:
	docker network create shared-network || true

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v

restart:
	docker compose restart

logs:
	docker compose logs -f


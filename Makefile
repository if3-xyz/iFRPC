.PHONY: all configure network build up down clean restart logs

all:
	docker compose down
	docker compose clean
	$(MAKE) network
	$(MAKE) configure
	docker compose build
	docker compose up

configure:
	@if [ -z "$(CHAIN_ID)" ]; then \
		read -p "Enter chainID: " chainid && ./configure.sh $$chainid; \
	else \
		./configure.sh $(CHAIN_ID); \
	fi

network:
	@docker network create shared-network 2>/dev/null || true

restart:
	docker compose down && docker compose up

logs:
	docker compose logs -f
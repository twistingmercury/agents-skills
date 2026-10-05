.PHONY: help install test

default: help

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nAvailable targets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

install: ## Install Claude Code agents, rules, and skills.
	./install/install.sh

test: ## Run the shared skill test suites and the tool chain script tests (requires Python 3.11+ and bats).
	cd skills/rlm && python3 -m unittest discover -s tests
	bats skills/python-uv-starter/tests
	bats scripts/tests

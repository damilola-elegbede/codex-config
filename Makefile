.DEFAULT_GOAL := help

.PHONY: help sync validate test

help:
	@printf "Available targets:\\n"
	@printf "  sync      Install Codex configuration into ~/.codex\\n"
	@printf "  validate  Validate a staged Codex home (CODEX_HOME required)\\n"
	@printf "  test      Execute automated test suite\\n"

sync:
	@./scripts/sync.sh

validate:
	@./scripts/validate.sh "$(CODEX_HOME)"

test:
	@./tests/test.sh

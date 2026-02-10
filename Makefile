.DEFAULT_GOAL := help

.PHONY: help sync doctor validate test clean

help:
	@printf "Available targets:\\n"
	@printf "  sync      Install Codex configuration into ~/.codex\\n"
	@printf "  doctor    Run environment diagnostics\\n"
	@printf "  validate  Run static validators against personas, commands, and skills\\n"
	@printf "  test      Execute automated test suite\\n"
	@printf "  clean     Remove generated artifacts\\n"

sync:
	@./scripts/sync.sh

doctor:
	@./scripts/codex-doctor.sh

validate:
	@python3 tests/validate_config.py

test:
	@pytest -q

clean:
	@find . -name "__pycache__" -type d -prune -exec rm -rf {} +
	@rm -rf .pytest_cache

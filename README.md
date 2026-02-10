# Codex Config

Codex Config packages reusable personas, skills, and command workflows so Codex agents can start productive sessions fast. It follows a Claude-config style layout with validation, documentation, and automation scripts.

## Getting Started

1. Install prerequisites and validate your environment with `make doctor`.
2. Run static checks via `make validate` (requires `PyYAML`).
3. Sync the configuration into `~/.codex` using `make sync`.
4. Generate a prompt for a workflow with `scripts/run-command.sh <command>`.

Detailed instructions live in [`docs/QUICKSTART.md`](docs/QUICKSTART.md).

## Repository Highlights

- **System Config** (`system-configs/.codex/`): contains `AGENTS.md`, `config.toml`, personas, commands, prompts, and runtime dispatcher scripts ready for syncing.
- **Skills** (`system-configs/.agents/skills/`): official Codex skills, synced to `~/.agents/skills`.
- **Automation** (`scripts/`): `run-command.sh`, `sync.sh`, and `codex-doctor.sh` keep sessions consistent.
- **Validation & Tests** (`tests/`): Python validators and pytest coverage to catch schema drift.
- **Docs** (`docs/`): Quickstart and reference guides for onboarding.

See [`docs/REFERENCE.md`](docs/REFERENCE.md) for a catalog of personas, commands, and skills.

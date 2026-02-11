# Codex Config Quickstart

This repository packages personas, skills, and workflows that help Codex agents start productive sessions immediately. Codex system configuration lives under `system-configs/.codex/` and official skills live under `system-configs/.agents/skills/`. The quickstart below walks through environment setup and common commands.

## 1. Prerequisites

- **Python 3.9+** with `pip`
- **Node.js 16+** (for frontend-oriented tooling)
- **Git** with repository access
- Recommended: `rsync` for faster sync operations
- Python module `PyYAML`

Install Python dependencies:

```bash
python3 -m pip install --user -r requirements.txt
```

> Tip: The validators and dispatcher rely on `PyYAML`. If the module is missing you will see a `RuntimeError` pointing to the installation command.

## 2. Validate your environment

Run the diagnostic script to confirm required binaries and modules are available:

```bash
make doctor
```

Review warnings and install any missing dependencies before continuing.

## 3. Run configuration checks

Static validation ensures personas, skills, and commands stay aligned:

```bash
make validate
```

The script reports missing fields or broken references. Fix issues before syncing the configuration.

## 4. Optional: Execute tests

Pytest exercises importer and dispatcher logic:

```bash
pip install --user -r requirements-dev.txt
make test
```

Continuous integration should run the same test suite.

## 5. Sync configuration into Codex

Copy the curated system configuration (`system-configs/.codex/AGENTS.md`, `config.toml`, personas, commands, prompts, dispatcher scripts) into `~/.codex`, and skills into `~/.agents/skills`:

```bash
make sync
```

The sync script creates timestamped backups under `~/.codex.backup.<timestamp>` and `~/.agents.backup.<timestamp>`. Use `--dry-run` to preview actions:

```bash
scripts/sync.sh --dry-run
```

## 6. Launch a session with a command

Use the dispatcher to assemble a Codex prompt that blends personas, skills, and repository context:

```bash
scripts/run-command.sh prime --focus "stabilize onboarding journey"
```

Pass `--key value` pairs to populate command inputs. The script prints a cohesive prompt you can paste into Codex.

Native slash commands are also provided via `system-configs/.codex/prompts/` and synced to `~/.codex/prompts`. These are separate from the internal dispatcher but aligned in intent.

## 7. Keep configuration fresh

- Update personas (`system-configs/.codex/profiles/`), prompts (`system-configs/.codex/prompts/`), and skills (`system-configs/.agents/skills/`) as teams learn new patterns.
- Add new commands for recurring workflows such as `/triage` or `/retro`.
- Re-run `make validate` before committing changes.

For a catalog of available assets, read [`docs/REFERENCE.md`](./REFERENCE.md).

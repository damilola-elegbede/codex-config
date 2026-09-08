# Codex Config

This public repository is the source of truth for the small, explicit portion
of a Codex home that it owns. It uses native Codex configuration and file-based
profiles; it does not ship a persona dispatcher, custom prompts, or
`[profiles.*]` tables.

## Owned configuration

`system-configs/.codex/config.toml` owns only these top-level keys:

- `model`
- `model_reasoning_effort`
- `web_search`

It also owns the file profiles that it ships (`think.config.toml`,
`code.config.toml`, and `review.config.toml`). The profile values mirror the
fleet model policy and are checked by `tests/test-policy-agreement.sh` whenever
that policy checkout is available.

## Never touched

Sync does not overwrite or back up `[projects.*]`,
`[notice.model_migrations]`, `[tui.*]`, `auth.json`, `sessions/`,
`history.jsonl`, `*.sqlite*`, `cache/`, `log/`, `tmp/`, `plugins/`,
`skills/.system`, or `rules/default.rules`. Unknown profile files also remain
in place. These are Codex state or machine-local configuration, not repository
configuration.

## Validate and sync

Validate a staged home without spending a token:

```sh
scripts/validate.sh "$CODEX_HOME"
```

The validator succeeds only after strict Codex parsing reaches a deliberately
missing model provider. It does not make a model request.

Preview a deployment:

```sh
scripts/sync.sh --dry-run
```

Apply a deployment from a current checkout:

```sh
scripts/sync.sh
```

Sync stages and validates first, makes an owned-only timestamped backup, then
atomically replaces each owned file and validates again. `--no-backup` disables
that backup; `--force` bypasses the local `origin/main` freshness comparison.
Station manifests scope fleet-sensitive surfaces. No manifest uses the
laptop-first defaults; the checked-in Mini manifest intentionally enables only
the model keys and profiles.

## Rollout

Roll out on a laptop first. On the Mini, preview only:

```sh
scripts/sync.sh --dry-run
```

After the resulting diff and staged validator are reviewed, schedule a normal
apply in a maintenance window and smoke the fleet gate:

```sh
infra/scripts/codex-review.sh
```

The Mini Codex home is a fleet surface. Do not use this repository to change
global instructions, hooks, rules, or user skills there until their impact
reviews explicitly enable them.

## Tests

```sh
tests/test.sh
```

The test suite is hermetic: it stubs `codex` on `PATH`. Run
`scripts/validate.sh` separately where a real Codex binary is available.

# Reference

Codex 0.153 loads profiles from `<name>.config.toml` files, selected with
`codex -p <name>`. The repository profile files mirror the fleet model policy.
All other ownership and rollout details are in the [README](../README.md).

Model/effort compatibility is established by a live probe against the real
account, not by `scripts/validate.sh` — that script forces
`model_provider="__nonexistent__"` deliberately, so it verifies TOML parsing
and unknown-field rejection without ever exercising whether a given
`model`/`model_reasoning_effort` pair is actually served. Each profile file
carries a comment recording when and how its pairing was verified.

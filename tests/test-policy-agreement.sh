#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
POLICY_ROOT=${BARECLAUDE_ROOT:-"$HOME/BareClaude"}
POLICY="$POLICY_ROOT/infra/model-policy.json"
if [ ! -f "$POLICY" ]; then
    echo "SKIP — model-policy.json not present"
    exit 0
fi

POLICY="$POLICY" ROOT="$ROOT" python3 - <<'PY'
import json
import os
import tomllib

with open(os.environ["POLICY"], encoding="utf-8") as source:
    policy = json.load(source)["codex"]
root = os.environ["ROOT"]
for tier in ("think", "code", "review"):
    path = os.path.join(root, "system-configs", ".codex", f"{tier}.config.toml")
    with open(path, "rb") as source:
        profile = tomllib.load(source)
    expected = policy[tier]
    actual = {"model": profile.get("model"), "effort": profile.get("model_reasoning_effort")}
    if actual != expected:
        raise SystemExit(f"FAIL {tier}: expected {expected}, got {actual}")
    print(f"PASS {tier}")
PY

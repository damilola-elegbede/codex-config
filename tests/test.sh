#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
status=0
for test in "$ROOT"/tests/test-*.sh "$ROOT"/tests/sync/*.sh; do
    [ -f "$test" ] || continue
    printf '==> %s\n' "${test#"$ROOT"/}"
    if ! sh "$test"; then
        status=1
    fi
done
exit "$status"

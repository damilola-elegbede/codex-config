#!/bin/sh
# Prove each guard can actually fail: apply its mutation, confirm the paired
# test breaks, then revert. A mutation nobody runs is decoration, not a test.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
status=0

find_test() {
    name=$1
    for candidate in "tests/$name.sh" "tests/sync/$name.sh"; do
        [ -f "$candidate" ] && { printf '%s\n' "$candidate"; return 0; }
    done
    return 1
}

for mutation in tests/mutations/*.mutation; do
    [ -f "$mutation" ] || continue
    name=$(basename "$mutation" .mutation)
    if ! test_script=$(find_test "$name"); then
        echo "no test found for $mutation" >&2
        status=1
        continue
    fi
    printf '==> %s (expect %s to fail)\n' "$mutation" "$test_script"

    if ! git apply --check "$mutation" 2>/dev/null; then
        echo "mutation does not apply cleanly: $mutation" >&2
        status=1
        continue
    fi
    git apply "$mutation"
    output=$(sh "$test_script" 2>&1) && rc=0 || rc=$?
    git apply -R "$mutation"

    first_line=$(printf '%s\n' "$output" | head -n 1)
    case "$first_line" in
        SKIP*)
            printf 'SKIP %s - environment cannot exercise this guard\n' "$test_script"
            ;;
        *)
            if [ "$rc" -eq 0 ]; then
                echo "mutation not caught: $test_script passed under $mutation" >&2
                status=1
            else
                printf 'OK mutation caught by %s\n' "$test_script"
            fi
            ;;
    esac
done

exit "$status"

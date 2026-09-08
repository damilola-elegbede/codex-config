#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT HUP INT TERM
mkdir -p "$WORK/bin" "$WORK/good" "$WORK/bad-key" "$WORK/bad-profile"

printf '%s\n' '#!/bin/sh' \
  'if grep -R "^bad_key" "$CODEX_HOME" >/dev/null 2>&1; then' \
  '  echo "unknown configuration field '\''bad_key'\''" >&2; exit 1' \
  'fi' \
  'echo "Model provider __nonexistent__ not found" >&2' \
  'exit 1' > "$WORK/bin/codex"
chmod +x "$WORK/bin/codex"

printf '%s\n' 'model = "test"' > "$WORK/good/config.toml"
printf '%s\n' 'model = "test"' > "$WORK/good/think.config.toml"
PATH="$WORK/bin:$PATH" "$ROOT/scripts/validate.sh" "$WORK/good" >/dev/null

printf '%s\n' 'bad_key = true' > "$WORK/bad-key/config.toml"
if PATH="$WORK/bin:$PATH" "$ROOT/scripts/validate.sh" "$WORK/bad-key" >"$WORK/out" 2>&1; then
    echo "bad base key unexpectedly passed" >&2
    exit 1
fi
grep -Eq 'bad-key/config.toml:1:' "$WORK/out"

printf '%s\n' 'model = "test"' > "$WORK/bad-profile/config.toml"
printf '%s\n' 'bad_key = true' > "$WORK/bad-profile/broken.config.toml"
if PATH="$WORK/bin:$PATH" "$ROOT/scripts/validate.sh" "$WORK/bad-profile" >"$WORK/out" 2>&1; then
    echo "bad profile unexpectedly passed" >&2
    exit 1
fi
grep -Eq 'bad-profile/broken.config.toml:1:' "$WORK/out"
echo "PASS test-validate"

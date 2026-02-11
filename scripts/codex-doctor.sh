#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERBOSE=0

usage() {
  cat <<'EOF'
Usage: scripts/codex-doctor.sh [--verbose]

Run environment diagnostics for Codex configuration tooling.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose)
      VERBOSE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

declare -i EXIT_CODE=0

print_result() {
  local status="$1"
  local message="$2"
  if [[ "$status" -eq 0 ]]; then
    printf "[ OK ] %s\n" "$message"
  else
    printf "[FAIL] %s\n" "$message"
    EXIT_CODE=1
  fi
}

print_warning() {
  local message="$1"
  printf "[WARN] %s\n" "$message"
}

check_command() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    print_result 0 "Command '${cmd}' available."
  else
    print_result 1 "Missing command '${cmd}'. Hint: ${hint}"
  fi
}

check_optional_command() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    print_result 0 "Command '${cmd}' available."
  else
    print_warning "Missing optional command '${cmd}'. Hint: ${hint}"
  fi
}

check_python_module() {
  local module="$1"
  local hint="$2"
  if python3 - <<PY >/dev/null 2>&1
import ${module}
PY
  then
    print_result 0 "Python module '${module}' available."
  else
    print_result 1 "Missing Python module '${module}'. Hint: ${hint}"
  fi
}

check_command python3 "Install Python 3 from python.org or your package manager."
check_command git "Install Git via https://git-scm.com/."
check_command node "Install Node.js (https://nodejs.org/)."
check_optional_command rsync "Optional but recommended for fast syncing."
check_python_module yaml "pip install pyyaml"

if [[ $VERBOSE -eq 1 ]]; then
  printf "Repo root: %s\n" "$REPO_ROOT"
  printf "Codex home: %s\n" "${CODEX_HOME:-$HOME/.codex}"
fi

exit "$EXIT_CODE"

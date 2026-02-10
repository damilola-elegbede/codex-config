#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: scripts/run-command.sh <command-name> [--key value]...

Examples:
  scripts/run-command.sh prime --focus "stabilize onboarding flow"
  scripts/run-command.sh review --changeset origin/main..HEAD
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

COMMAND_NAME="${1#/}" # allow leading slash shorthand
shift

COMMAND_FILE="${REPO_ROOT}/commands/${COMMAND_NAME}.yaml"
if [[ ! -f "${COMMAND_FILE}" ]]; then
  echo "Command definition not found: ${COMMAND_FILE}" >&2
  exit 1
fi

PYTHONPATH="${REPO_ROOT}:${PYTHONPATH:-}" \
python3 "${SCRIPT_DIR}/run_command.py" "${COMMAND_NAME}" "$@"

#!/bin/sh
# Sync script for Codex configuration
# Syncs system-configs/.codex/ to ~/.codex and system-configs/.agents/skills to ~/.agents/skills

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

: "${HOME:?HOME variable is not set}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SOURCE_CODEX="$REPO_DIR/system-configs/.codex"
SOURCE_AGENTS="$REPO_DIR/system-configs/.agents"
TARGET_CODEX="$HOME/.codex"
TARGET_AGENTS="$HOME/.agents"

DRY_RUN=false
CREATE_BACKUP=true

while [ $# -gt 0 ]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --backup)
      CREATE_BACKUP=true
      shift
      ;;
    --no-backup)
      CREATE_BACKUP=false
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--dry-run] [--backup|--no-backup]"
      exit 1
      ;;
  esac
done

print_success() {
  printf "${GREEN}✓${NC} %s\n" "$1"
}

print_error() {
  printf "${RED}✗${NC} %s\n" "$1"
}

print_warning() {
  printf "${YELLOW}⚠${NC} %s\n" "$1"
}

create_backup() {
  target_dir="$1"
  label="$2"
  if [ -d "$target_dir" ]; then
    backup_dir="$HOME/.${label}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Creating backup at $backup_dir..."
    if ! cp -r "$target_dir" "$backup_dir"; then
      print_error "Backup failed - aborting sync to prevent data loss"
      return 1
    fi
    print_success "Backup created at $backup_dir"
  fi
}

cleanup_old_backups() {
  label="$1"
  backup_count=$(find "$HOME" -maxdepth 1 -name ".${label}.backup.*" -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ "$backup_count" -gt 5 ]; then
    echo "Rotating backups for .$label (keeping latest 5)..."
    if stat -f "%m %N" "$HOME" >/dev/null 2>&1; then
      STAT_OPT='-f'
      STAT_FMT='%m %N'
    else
      STAT_OPT='-c'
      STAT_FMT='%Y %n'
    fi
    find "$HOME" -maxdepth 1 -name ".${label}.backup.[0-9]*_[0-9]*" -type d \
      -exec stat "$STAT_OPT" "$STAT_FMT" {} + 2>/dev/null | \
      sort -rn | cut -d' ' -f2- | tail -n +6 | while read -r old_backup; do
      if [ -d "$old_backup" ] && echo "$old_backup" | grep -qE "^$HOME/\.${label}\.backup\.[0-9]{8}_[0-9]{6}$"; then
        rm -rf "$old_backup"
        echo "  Removed old backup: $(basename "$old_backup")"
      fi
    done
  fi
}

validate_configs() {
  echo "Syncing Codex configurations..."
  echo "Source: $SOURCE_CODEX"
  echo "Target: $TARGET_CODEX"
  echo ""

  if [ ! -d "$SOURCE_CODEX" ]; then
    print_error "Source directory not found: $SOURCE_CODEX"
    return 1
  fi

  if [ ! -d "$SOURCE_AGENTS" ]; then
    print_error "Source directory not found: $SOURCE_AGENTS"
    return 1
  fi

  echo "Pre-sync validation:"
  if ! python3 "$REPO_DIR/tests/validate_config.py"; then
    print_error "Validation failed. See errors above."
    return 1
  fi
  print_success "Configuration validation passed"

  if [ ! -w "$HOME" ]; then
    print_error "Cannot write to home directory"
    return 1
  fi
  print_success "Target directory is writable"
  echo ""

  return 0
}

sync_dir() {
  source="$1"
  destination="$2"
  label="$3"

  if [ ! -d "$source" ]; then
    print_warning "Skipping missing directory: $source"
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    echo "DRY-RUN: $label -> $destination"
    return 0
  fi

  mkdir -p "$destination"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete --exclude="README.md" --exclude="*TEMPLATE*" "$source/" "$destination/"
  else
    tmp_dest="${destination}.tmp.$$"
    cp -R "$source" "$tmp_dest"
    rm -rf "$destination"
    mv "$tmp_dest" "$destination"
  fi
  print_success "$label synced"
}

sync_file() {
  source="$1"
  destination="$2"
  label="$3"

  if [ ! -f "$source" ]; then
    print_warning "Skipping missing file: $source"
    return 0
  fi

  if [ "$DRY_RUN" = "true" ]; then
    echo "DRY-RUN: $label -> $destination"
    return 0
  fi

  mkdir -p "$(dirname "$destination")"
  cp "$source" "$destination"
  print_success "$label synced"
}

post_sync_validation() {
  echo "Post-sync validation:"
  codex_profiles=$(find "$TARGET_CODEX/profiles" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  codex_commands=$(find "$TARGET_CODEX/commands" -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
  codex_prompts=$(find "$TARGET_CODEX/prompts" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  skills_count=$(find "$TARGET_AGENTS/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

  echo "  - Personas: $codex_profiles"
  echo "  - Commands: $codex_commands"
  echo "  - Prompts: $codex_prompts"
  echo "  - Skills: $skills_count"
  echo ""
}

main() {
  if ! validate_configs; then
    print_error "Pre-sync validation failed"
    return 1
  fi

  if [ "$DRY_RUN" = "true" ]; then
    echo "Preview mode - no changes will be made"
    echo ""
    echo "Files to sync:"
    echo "  - $SOURCE_CODEX/AGENTS.md -> $TARGET_CODEX/AGENTS.md"
    echo "  - $SOURCE_CODEX/config.toml -> $TARGET_CODEX/config.toml"
    echo "  - $SOURCE_CODEX/profiles -> $TARGET_CODEX/profiles"
    echo "  - $SOURCE_CODEX/commands -> $TARGET_CODEX/commands"
    echo "  - $SOURCE_CODEX/prompts -> $TARGET_CODEX/prompts"
    echo "  - $SOURCE_CODEX/scripts -> $TARGET_CODEX/scripts"
    echo "  - $SOURCE_AGENTS/skills -> $TARGET_AGENTS/skills"
    return 0
  fi

  if [ "$CREATE_BACKUP" = "true" ]; then
    create_backup "$TARGET_CODEX" "codex"
    create_backup "$TARGET_AGENTS" "agents"
    echo ""
  fi

  sync_file "$SOURCE_CODEX/AGENTS.md" "$TARGET_CODEX/AGENTS.md" "AGENTS.md"
  sync_file "$SOURCE_CODEX/config.toml" "$TARGET_CODEX/config.toml" "config.toml"
  sync_dir "$SOURCE_CODEX/profiles" "$TARGET_CODEX/profiles" "profiles"
  sync_dir "$SOURCE_CODEX/commands" "$TARGET_CODEX/commands" "commands"
  sync_dir "$SOURCE_CODEX/prompts" "$TARGET_CODEX/prompts" "prompts"
  sync_dir "$SOURCE_CODEX/scripts" "$TARGET_CODEX/scripts" "scripts"
  sync_dir "$SOURCE_AGENTS/skills" "$TARGET_AGENTS/skills" "skills"

  post_sync_validation

  cleanup_old_backups "codex"
  cleanup_old_backups "agents"

  echo "Sync completed successfully"
}

main "$@"

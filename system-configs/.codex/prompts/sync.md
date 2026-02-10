---
description: "Deploy Codex configuration to ~/.codex with validation and backup."
argument-hint: "[DRY_RUN=true] [BACKUP=false]"
---
You are running /sync.

- Validate configuration assets before syncing.
- Use scripts/sync.sh to copy the system configs into ~/.codex.
- If DRY_RUN is true, use the --dry-run flag.
- If BACKUP is false, use the --no-backup flag.

Return the exact command to run and a brief summary of what will be synced.

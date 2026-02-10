#!/usr/bin/env python3
"""CLI entrypoint for assembling Codex command prompts."""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> None:
    repo_root = Path(__file__).resolve().parents[3]
    sys.path.insert(0, str(repo_root))
    from codex_config.dispatcher import main as dispatcher_main  # import after path patch

    dispatcher_main()


if __name__ == "__main__":
    main()

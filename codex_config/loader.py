"""Shared loader utilities for Codex configuration assets."""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, Tuple

try:
    import yaml  # type: ignore
except ImportError as exc:  # pragma: no cover - surfaced in tooling
    raise RuntimeError(
        "PyYAML is required for Codex tooling. Install with `pip install pyyaml`."
    ) from exc


REPO_ROOT = Path(__file__).resolve().parent.parent
SYSTEM_CONFIG_ROOT = REPO_ROOT / "system-configs" / ".codex"
AGENTS_CONFIG_ROOT = REPO_ROOT / "system-configs" / ".agents"
COMMANDS_DIR = SYSTEM_CONFIG_ROOT / "commands"
PROFILES_DIR = SYSTEM_CONFIG_ROOT / "profiles"
SKILLS_DIR = AGENTS_CONFIG_ROOT / "skills"

FRONT_MATTER_BOUNDARY = re.compile(r"^---\s*$", re.MULTILINE)


@dataclass
class Persona:
    slug: str
    data: Dict
    body: str
    path: Path


@dataclass
class Skill:
    slug: str
    data: Dict
    body: str
    path: Path


def load_yaml_file(path: Path) -> Dict:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if not isinstance(data, dict):
        raise ValueError(f"Expected mapping at {path}, found {type(data).__name__}")
    return data


def parse_front_matter(path: Path) -> Tuple[Dict, str]:
    raw = path.read_text(encoding="utf-8")
    if not raw.startswith("---"):
        raise ValueError(f"{path} is missing YAML front matter.")

    parts = FRONT_MATTER_BOUNDARY.split(raw, maxsplit=2)
    if len(parts) < 3:
        raise ValueError(f"{path} has malformed front matter boundaries.")

    _, meta_raw, body = parts
    meta = yaml.safe_load(meta_raw) or {}
    if not isinstance(meta, dict):
        raise ValueError(f"Front matter in {path} must be a mapping.")
    return meta, body.lstrip()


def load_persona(slug: str) -> Persona:
    path = PROFILES_DIR / f"{slug}.md"
    if not path.exists():
        raise FileNotFoundError(f"Persona '{slug}' not found at {path}.")
    data, body = parse_front_matter(path)
    return Persona(slug=slug, data=data, body=body, path=path)


def load_skill(slug: str) -> Skill:
    path = SKILLS_DIR / slug / "SKILL.md"
    if not path.exists():
        raise FileNotFoundError(f"Skill '{slug}' not found at {path}.")
    data, body = parse_front_matter(path)
    return Skill(slug=slug, data=data, body=body, path=path)


def load_command(name: str) -> Dict:
    path = COMMANDS_DIR / f"{name}.yaml"
    if not path.exists():
        raise FileNotFoundError(f"Command '{name}' not found at {path}.")
    command = load_yaml_file(path)
    command["_path"] = path
    return command


def ensure_known(values: Iterable[str], allowed: Iterable[str], kind: str) -> None:
    allowed_set = set(allowed)
    unknown = [value for value in values if value not in allowed_set]
    if unknown:
        raise ValueError(f"Unknown {kind}: {', '.join(sorted(unknown))}")

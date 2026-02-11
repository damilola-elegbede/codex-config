#!/usr/bin/env python3
"""Static validation for Codex configuration assets."""

from __future__ import annotations

import sys
from pathlib import Path
from typing import List

REPO_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_ROOT))

from codex_config import (
    COMMANDS_DIR,
    PROFILES_DIR,
    SKILLS_DIR,
    load_command,
    load_persona,
    load_skill,
)


def validate_personas(errors: List[str]) -> List[str]:
    personas = []
    required_fields = ["name", "description", "strengths", "default_tools", "guardrails", "skills"]
    for path in sorted(PROFILES_DIR.glob("*.md")):
        slug = path.stem
        persona = load_persona(slug)
        personas.append(slug)
        data = persona.data
        for field in required_fields:
            if field not in data:
                errors.append(f"Persona {slug}: missing '{field}' in front matter.")
        for list_field in ("strengths", "default_tools", "guardrails", "skills"):
            value = data.get(list_field)
            if not isinstance(value, list):
                errors.append(f"Persona {slug}: '{list_field}' must be a list.")
                continue
            if not value:
                errors.append(f"Persona {slug}: {list_field} list cannot be empty.")
        if not persona.body.strip():
            errors.append(f"Persona {slug}: body content is empty.")
    if len(personas) < 10:
        errors.append(f"Expected at least 10 personas; found {len(personas)}.")
    return personas


def validate_skills(errors: List[str]) -> List[str]:
    skills = []
    required_fields = ["name", "description", "tags"]
    for path in sorted(SKILLS_DIR.glob("*/SKILL.md")):
        slug = path.parent.name
        skill = load_skill(slug)
        skills.append(slug)
        data = skill.data
        for field in required_fields:
            if field not in data:
                errors.append(f"Skill {slug}: missing '{field}' in front matter.")
        tags = data.get("tags")
        if not isinstance(tags, list):
            errors.append(f"Skill {slug}: 'tags' must be a list.")
        elif not tags:
            errors.append(f"Skill {slug}: tags list cannot be empty.")
        if not skill.body.strip():
            errors.append(f"Skill {slug}: body content is empty.")
    return skills


def validate_commands(errors: List[str], personas: List[str], skills: List[str]) -> None:
    persona_set = set(personas)
    skill_set = set(skills)
    for path in sorted(COMMANDS_DIR.glob("*.yaml")):
        command = load_command(path.stem)
        if command["name"] != path.stem:
            errors.append(f"Command {path.name}: 'name' field must match filename.")
        if "description" not in command or not str(command["description"]).strip():
            errors.append(f"Command {path.name}: missing description.")
        for kind in ("personas", "skills"):
            values = command.get(kind, [])
            if not isinstance(values, list):
                errors.append(f"Command {path.name}: '{kind}' must be a list.")
                continue
            missing = [value for value in values if value not in (persona_set if kind == "personas" else skill_set)]
            if missing:
                errors.append(
                    f"Command {path.name}: unknown {kind[:-1]} reference(s): {', '.join(missing)}."
                )
        if "inputs" in command and not isinstance(command["inputs"], list):
            errors.append(f"Command {path.name}: inputs must be a list.")
        if "pre_run" in command and not isinstance(command["pre_run"], list):
            errors.append(f"Command {path.name}: pre_run must be a list.")
        if "post_run" in command and not isinstance(command["post_run"], list):
            errors.append(f"Command {path.name}: post_run must be a list.")


def main() -> int:
    errors: List[str] = []
    personas = validate_personas(errors)
    skills = validate_skills(errors)
    validate_commands(errors, personas, skills)

    if errors:
        for error in errors:
            print(f"[ERROR] {error}")
        print(f"Validation failed with {len(errors)} issue(s).")
        return 1

    print("All Codex configuration assets validated successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""Utilities for assembling Codex command prompts."""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

from .loader import COMMANDS_DIR, PROFILES_DIR, SKILLS_DIR, load_command, load_persona, load_skill


REPO_ROOT = Path(__file__).resolve().parent.parent


def parse_kv_args(values: List[str]) -> Dict[str, str]:
    """Parse a list of --key value pairs into a dictionary."""
    if len(values) % 2 != 0:
        raise SystemExit("Expected --key value pairs; found unmatched argument.")

    parsed: Dict[str, str] = {}
    iterator = iter(values)
    for flag in iterator:
        if not flag.startswith("--"):
            raise SystemExit(f"Expected argument starting with '--', got '{flag}'.")
        key = flag[2:]
        try:
            value = next(iterator)
        except StopIteration as exc:  # pragma: no cover - handled above
            raise SystemExit(f"Missing value for flag '{flag}'.") from exc
        parsed[key.replace("-", "_")] = value
    return parsed


def run_git_command(args: Iterable[str]) -> str:
    """Run git commands while safely handling non-git directories."""
    try:
        completed = subprocess.run(
            ["git", *args],
            cwd=REPO_ROOT,
            check=True,
            capture_output=True,
            text=True,
        )
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "Unavailable"
    output = completed.stdout.strip()
    return output or "Clean"


def detect_dependency_manifests() -> List[str]:
    candidates = [
        "package.json",
        "pnpm-lock.yaml",
        "yarn.lock",
        "requirements.txt",
        "pyproject.toml",
        "Pipfile",
        "poetry.lock",
        "go.mod",
        "go.sum",
        "Cargo.toml",
        "Gemfile",
        "composer.json",
    ]
    found: List[str] = []
    for candidate in candidates:
        path = REPO_ROOT / candidate
        if path.exists():
            found.append(str(path.relative_to(REPO_ROOT)))
    return found


def normalize_description(text: str) -> str:
    return " ".join(text.split())


def format_inputs(command: Dict, user_inputs: Dict[str, str]) -> str:
    lines: List[str] = []
    for input_def in command.get("inputs", []):
        key = input_def.get("key")
        prompt = input_def.get("prompt", key)
        required = input_def.get("required", False)
        value = user_inputs.get(key.replace("-", "_"), "").strip()
        caption = value if value else "[not provided]" if not required else "[missing]"
        lines.append(f"- {prompt}: {caption}")
    if not lines:
        lines.append("- (no additional inputs requested)")
    return "\n".join(lines)


def assemble_prompt(command_name: str, user_inputs: Dict[str, str]) -> str:
    command = load_command(command_name)
    personas = [load_persona(slug) for slug in command.get("personas", [])]
    skills = [load_skill(slug) for slug in command.get("skills", [])]

    git_branch = run_git_command(["rev-parse", "--abbrev-ref", "HEAD"])
    git_status = run_git_command(["status", "--short"])
    dependency_files = detect_dependency_manifests()

    lines: List[str] = []
    lines.append(f"=== Codex Command: /{command['name']} ===")
    lines.append(f"Source: {command['_path'].relative_to(REPO_ROOT)}")
    lines.append("")
    lines.append(normalize_description(command.get("description", "")))
    lines.append("")

    lines.append("Inputs:")
    lines.append(format_inputs(command, user_inputs))
    lines.append("")

    if command.get("pre_run"):
        lines.append("Pre-run considerations:")
        lines.extend(f"- {item}" for item in command["pre_run"])
        lines.append("")

    lines.append("Personas:")
    if personas:
        for persona in personas:
            persona_name = persona.data.get("name", persona.slug)
            lines.append(f"\n--- Persona: {persona_name} ({persona.path.relative_to(REPO_ROOT)}) ---")
            lines.append(persona.body.strip())
    else:
        lines.append("- (none defined)")
    lines.append("")

    lines.append("Skills:")
    if skills:
        for skill in skills:
            skill_name = skill.data.get("name", skill.slug)
            lines.append(f"\n--- Skill: {skill_name} ({skill.path.relative_to(REPO_ROOT)}) ---")
            lines.append(skill.body.strip())
    else:
        lines.append("- (none defined)")
    lines.append("")

    if command.get("context", {}).get("include"):
        lines.append("Context files to review:")
        lines.extend(f"- {item}" for item in command["context"]["include"])
        lines.append("")

    if command.get("post_run"):
        lines.append("Post-run follow-ups:")
        lines.extend(f"- {item}" for item in command["post_run"])
        lines.append("")

    lines.append("Repository snapshot:")
    lines.append(f"- Branch: {git_branch}")
    lines.append(f"- Git status:\n{git_status if git_status != 'Clean' else '  Clean'}")
    lines.append(
        f"- Dependency manifests: {', '.join(dependency_files) if dependency_files else 'none detected'}"
    )

    return "\n".join(lines).strip() + "\n"


def dispatch(command_name: str, raw_args: List[str]) -> str:
    user_inputs = parse_kv_args(raw_args)
    return assemble_prompt(command_name, user_inputs)


def main(argv: List[str] | None = None) -> None:
    parser = argparse.ArgumentParser(description="Codex command dispatcher.")
    parser.add_argument("command_name", help="Command file name (e.g., prime, test)")
    args, unknown = parser.parse_known_args(argv)
    prompt = dispatch(args.command_name, unknown)
    print(prompt)

from codex_config import (
    COMMANDS_DIR,
    PROFILES_DIR,
    SKILLS_DIR,
    assemble_prompt,
    load_command,
    load_persona,
    load_skill,
)


def test_persona_required_fields():
    required = {"name", "description", "strengths", "default_tools", "guardrails", "skills"}
    for path in PROFILES_DIR.glob("*.md"):
        persona = load_persona(path.stem)
        assert required.issubset(persona.data.keys()), f"{path.name} missing required fields"
        assert persona.body.strip(), f"{path.name} body must not be empty"


def test_skill_required_fields():
    required = {"name", "description", "tags"}
    for path in SKILLS_DIR.glob("*/SKILL.md"):
        skill = load_skill(path.parent.name)
        assert required.issubset(skill.data.keys()), f"{path.name} missing required fields"
        assert skill.body.strip(), f"{path.name} body must not be empty"


def test_commands_reference_existing_assets():
    persona_slugs = {path.stem for path in PROFILES_DIR.glob("*.md")}
    skill_slugs = {path.parent.name for path in SKILLS_DIR.glob("*/SKILL.md")}
    for path in COMMANDS_DIR.glob("*.yaml"):
        command = load_command(path.stem)
        assert command["name"] == path.stem
        for slug in command.get("personas", []):
            assert slug in persona_slugs, f"{path.name} references missing persona '{slug}'"
        for slug in command.get("skills", []):
            assert slug in skill_slugs, f"{path.name} references missing skill '{slug}'"


def test_dispatcher_generates_prompt():
    prompt = assemble_prompt("prime", {"focus": "stability"})
    assert "/prime" in prompt
    assert "Personas:" in prompt
    assert "Skills:" in prompt
    assert "Repository snapshot:" in prompt

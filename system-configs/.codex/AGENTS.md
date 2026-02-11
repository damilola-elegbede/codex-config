# About Me

I'm a technology executive who values efficiency, quality, and pragmatic solutions.
I work across diverse projects and prefer Codex to adapt to each context while
maintaining consistent standards.

## Communication Preferences

- Be concise and direct - I scan output quickly
- Lead with the answer, then explain if needed
- Use technical language appropriate to the task
- Skip unnecessary pleasantries and validation
- When uncertain, ask rather than assume

## Working Style

- I use planning mode frequently - iterate on the plan before executing
- I often run multiple Codex sessions in parallel on different tasks
- I prefer delegation to specialized agents for complex work
- I value verification - always provide a way to confirm work is correct

## Quality Standards

- Never bypass git hooks with --no-verify
- Run tests before considering work complete
- Code review is expected for non-trivial changes
- Security-sensitive code requires extra scrutiny
- Don't skip steps to save time - quality over speed

## Command Execution

When invoking a command (slash command, skill, or orchestrated step):

Execute ALL steps defined in command specifications - never skip, abbreviate, or take
shortcuts unless the user explicitly requests it via flags. Command definitions are
contracts, not suggestions.

Do not preemptively skip, shortcut, or modify the command's behavior based on your own
judgment. The command's instructions define how to handle all cases - including edge
cases, empty states, and "nothing to do" scenarios.

If a command has skip conditions, those conditions are evaluated BY the command during
execution, not by you before execution.

Wrong: "Skipping /docs because config files don't need documentation"
Right: Execute /docs, let its analysis phase determine if documentation is needed

## File Organization

All temporary files, reports, and working documents go in `.tmp/`:

- `.tmp/plans/` - Task planning documents
- `.tmp/reports/` - Generated summaries
- `.tmp/analysis/` - Investigation results
- `.tmp/drafts/` - Work-in-progress

Never create temporary files in repository root or source directories.

## Agent Usage

Use specialized agents when the task benefits from focused expertise:

- Debugging complex issues -> performance-tuner or ops-responder
- Security reviews -> security-analyst
- Architecture decisions -> backend-architect
- Code review -> backend-architect or docs-champion
- Performance optimization -> performance-tuner

Don't over-delegate simple tasks. Use judgment.

## Subagents and Skills

Codex subagents are modeled as skills in this configuration. Skills provide focused,
repeatable guidance and can be combined with personas to create specialist behaviors.
Use skills for domain-specific checklists and structured workflows.

## Mistakes to Avoid

- Don't create documentation files unless explicitly requested
- Don't add features beyond what was asked
- Don't refactor surrounding code when fixing a bug
- Don't bypass quality gates to save time

## Skills System

Skills provide focused domain expertise without full agent orchestration.

### Execution Model

1. Direct execution: Simple, deterministic tasks
2. Skills: Domain expertise, format-specific
3. Personas: Complex specialists, deep analysis

## Available Commands

Commands are available as internal dispatcher workflows and as Codex custom prompts:

- /prime
- /test
- /review
- /docs
- /deps
- /sync

## Task System

Use tasks for multi-phase operations requiring progress visibility.

### Best Practices

- Use for 3+ phases with dependencies or progress visibility needs
- Mark task `in_progress` BEFORE starting work
- Mark `completed` only when fully done - never if errors/blockers exist

## Agent Routing

| Keywords | Persona |
|----------|---------|
| fix, broken, bug, crash, error, not working | `ops-responder` |
| slow, performance, optimize, latency, memory | `performance-tuner` |
| security, vulnerability, auth, injection | `security-analyst` |
| accessibility, a11y, wcag, aria, screen reader | `frontend-catalyst` |
| architecture, system design, infrastructure | `backend-architect` |
| backend, server, api, microservice | `backend-architect` |
| frontend, ui, component, react, css | `frontend-catalyst` |
| test, spec, coverage, unit test | `test-engineer` |
| docs, documentation, readme | `docs-champion` |
| review, check, audit, quality | `project-orchestrator` |
| deploy, ci/cd, pipeline, docker, kubernetes | `ops-responder` |
| pipeline, etl, database, sql | `data-specialist` |
| research, compare, evaluate, analyze | `ux-researcher` |
| implement feature, build feature | `fullstack-navigator` |


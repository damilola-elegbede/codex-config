# Codex Configuration Reference

Use this reference to explore the personas, commands, and skills packaged with the Codex configuration. Runtime assets reside in `system-configs/.codex/` (including `AGENTS.md`) and official skills live in `system-configs/.agents/skills/`.

## Personas

| Slug | Name | Primary Focus | Core Skills |
| --- | --- | --- | --- |
| `backend-architect` | Backend Architect | Shape resilient APIs, data models, and integration patterns. | `api-design`, `dependency-health`, `testing-strategy` |
| `frontend-catalyst` | Frontend Catalyst | Deliver accessible, high-performance user experiences. | `frontend-accessibility`, `lint-triage`, `performance-profiling` |
| `test-engineer` | Quality Guardian | Expand automated coverage and shorten feedback loops. | `testing-strategy`, `ci-debugging`, `git-workflow-rescue` |
| `security-analyst` | Security Analyst | Surface and mitigate vulnerabilities without slowing delivery. | `security-audit`, `dependency-health`, `release-operations` |
| `docs-champion` | Docs Champion | Keep guides, references, and changelogs accurate. | `markdown-polish`, `documentation-style`, `release-operations` |
| `project-orchestrator` | Project Orchestrator | Sequence work across teams while making risk visible. | `git-workflow-rescue`, `release-operations`, `product-discovery` |
| `data-specialist` | Data Specialist | Maintain trustworthy data assets and experimentation tooling. | `dependency-health`, `testing-strategy`, `product-discovery` |
| `ops-responder` | Ops Responder | Stabilize production incidents and capture learnings fast. | `ci-debugging`, `release-operations`, `git-workflow-rescue` |
| `ux-researcher` | UX Researcher | Connect product direction with real user needs. | `user-research-synthesis`, `product-discovery`, `documentation-style` |
| `performance-tuner` | Performance Tuner | Measure and resolve performance bottlenecks. | `performance-profiling`, `ci-debugging`, `dependency-health` |
| `fullstack-navigator` | Fullstack Navigator | Ship end-to-end features across the entire stack. | `api-design`, `frontend-accessibility`, `git-workflow-rescue` |

Each persona file under `system-configs/.codex/profiles/` includes strengths, guardrails, and communication guidance you can tailor to your team.

## Commands

| Command | Purpose | Personas | Skills | Key Inputs |
| --- | --- | --- | --- | --- |
| `/prime` | Summarize repo context, active initiatives, and next actions. | `project-orchestrator`, `fullstack-navigator`, `docs-champion` | `product-discovery`, `git-workflow-rescue`, `documentation-style` | `focus`, `audience` |
| `/test` | Plan validation before merge or release. | `test-engineer`, `ops-responder` | `testing-strategy`, `ci-debugging`, `release-operations` | `scope`, `risk` |
| `/review` | Guide comprehensive code reviews. | `backend-architect`, `docs-champion`, `security-analyst` | `api-design`, `testing-strategy`, `markdown-polish`, `security-audit` | `changeset`, `focus` |
| `/docs` | Refresh product and engineering documentation. | `docs-champion`, `ux-researcher` | `markdown-polish`, `documentation-style`, `user-research-synthesis` | `deliverable`, `audience` |
| `/deps` | Audit and upgrade project dependencies. | `security-analyst`, `backend-architect` | `dependency-health`, `security-audit`, `release-operations` | `packages`, `timeline` |
| `/sync` | Deploy Codex configuration to ~/.codex. | `project-orchestrator`, `ops-responder` | `release-operations`, `git-workflow-rescue` | `dry_run`, `backup` |

Command definitions live in `system-configs/.codex/commands/<name>.yaml`. Custom prompt equivalents live in `system-configs/.codex/prompts/`. Modify personas, skills, or inputs to match new workflows and the dispatcher will pick up the changes automatically.

## Skills

| Slug | Name | Summary | Tags |
| --- | --- | --- | --- |
| `api-design` | API Design Review | Checklist for evolving service contracts safely. | architecture, backend |
| `dependency-health` | Dependency Health Audit | Spot drift, vulnerabilities, and bloat in dependency trees. | security, maintenance |
| `testing-strategy` | Testing Strategy Blueprint | Plan layered automated coverage and ownership. | quality, automation |
| `frontend-accessibility` | Frontend Accessibility Sweep | Ensure UI changes meet accessibility standards. | frontend, accessibility |
| `performance-profiling` | Performance Profiling Playbook | Gather telemetry and optimize bottlenecks data-first. | performance, observability |
| `lint-triage` | Lint Triage Checklist | Reduce lint noise and keep findings actionable. | quality, developer-experience |
| `ci-debugging` | CI Debugging Guide | Diagnose and stabilize failing pipelines. | ci, reliability |
| `git-workflow-rescue` | Git Workflow Rescue | Unstick branching strategies and improve contribution flow. | collaboration, git |
| `security-audit` | Security Audit Lens | Evaluate changes against security guardrails. | security, compliance |
| `release-operations` | Release Operations Cadence | Coordinate release activities and rollback paths. | release, operations |
| `markdown-polish` | Markdown Polish Kit | Polish docs for clarity and consistency. | documentation, style |
| `documentation-style` | Documentation Style Guardrails | Enforce editorial standards across docs. | documentation, governance |
| `product-discovery` | Product Discovery Framework | Structure ambiguous problems into validated bets. | product, strategy |
| `user-research-synthesis` | User Research Synthesis | Turn research artifacts into actionable insights. | research, storytelling |

Skill definitions live under `system-configs/.agents/skills/<slug>/SKILL.md` and sync into `~/.agents/skills`.

## Extending the Library

- Add new personas by copying an existing file in `system-configs/.codex/profiles/` and updating front matter plus guidance.
- Create new commands in `system-configs/.codex/commands/` and reference supporting personas and skills.
- Re-run `make validate` to catch missing references or required fields.
- Update `docs/REFERENCE.md` whenever you introduce new assets so teammates can discover them quickly.

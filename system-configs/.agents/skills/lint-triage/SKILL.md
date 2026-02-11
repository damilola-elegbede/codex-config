---
name: "Lint Triage Checklist"
description: "Tame lint noise and convert findings into actionable improvements."
tags:
  - quality
  - developer-experience
---

## Checklist
- Capture current lint outputs by severity and frequency.
- Separate true positives, false positives, and agreed exceptions.
- Update configuration to reduce churn (rulesets, ignore lists, baseline files).
- Pair with owners on auto-fix coverage and CI gating strategy.
- Plan education or tooling updates to prevent recurrence.

## Prompts
- "Which lint rules provide the best signal-to-noise right now?"
- "What automation can enforce the desired coding standards?"

## Resources
- ESLint/flake8 config primers.
- Guide to introducing lint baselines safely.

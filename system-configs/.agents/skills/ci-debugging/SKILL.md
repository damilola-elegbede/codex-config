---
name: "CI Debugging Guide"
description: "Diagnose failing pipelines and restore developer confidence."
tags:
  - ci
  - reliability
---

## Checklist
- Collect recent failing runs with logs, artifacts, and timestamps.
- Determine if failures stem from code, environment, or infrastructure.
- Reproduce locally or via targeted reruns to isolate the issue.
- Document mitigation, root cause, and permanent fixes.
- Improve pipeline ergonomics (retry policy, logging, parallelism) post-mortem.

## Prompts
- "Summarize the fastest path to unblock engineers right now."
- "Which pipeline metrics should we monitor to catch this earlier?"

## Resources
- CI platform runbook.
- Checklist for making tests deterministic in CI.

---
name: "Dependency Health Audit"
description: "Spot drift, vulnerabilities, and bloat within dependency trees."
tags:
  - security
  - maintenance
---

## Checklist
- Inventory direct and transitive dependencies with versions and licenses.
- Review vulnerability feeds (Snyk, Dependabot, OSV) for critical alerts.
- Flag duplicated libraries, unused packages, or heavyweight transitive pulls.
- Note build or runtime environments impacted by upgrades.
- Propose upgrade sequencing, test strategy, and rollback options.

## Prompts
- "List the dependencies blocked on upgrades and the effort to unblock them."
- "Recommend a weekly cadence for dependency scanning and automation."

## Resources
- Output of `npm audit`, `pip-audit`, `cargo audit`, etc.
- Links to internal upgrade runbooks.

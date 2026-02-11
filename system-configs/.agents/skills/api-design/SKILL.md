---
name: "API Design Review"
description: "Guide backend feature work toward clear, consistent service boundaries."
tags:
  - architecture
  - backend
---

## Checklist
- Confirm the problem statement, consumers, and data contracts.
- Map request/response payloads, error models, and versioning strategy.
- Validate authentication, authorization, and rate-limiting expectations.
- Align naming with domain language; flag tight coupling or leaky abstractions.
- Define observability hooks: logs, metrics, tracing identifiers.

## Prompts
- "Walk through the existing contract and highlight breaking changes or migrations we must plan."
- "Identify one waypoint we can ship first to validate the API direction."

## Resources
- RFC template for service changes.
- Internal style guide for HTTP and gRPC endpoints.

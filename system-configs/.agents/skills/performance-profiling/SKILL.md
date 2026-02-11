---
name: "Performance Profiling Playbook"
description: "Measure hotspots and drive optimizations backed by real telemetry."
tags:
  - performance
  - observability
---

## Checklist
- Reproduce workload under representative traffic and datasets.
- Capture traces, flame graphs, and key metrics (latency, throughput, memory).
- Identify top offenders and quantify potential wins.
- Evaluate caching, batching, and algorithmic options with trade-offs.
- Recommend rollout plus monitoring signals to confirm impact.

## Prompts
- "Break down the request lifecycle and pinpoint where time is spent."
- "Design a canary or feature flag strategy to derisk the optimization."

## Resources
- Profiling quickstart (Chrome DevTools, pprof, perf).
- Performance budget template.

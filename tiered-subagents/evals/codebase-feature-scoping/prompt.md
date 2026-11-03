---
tags: [skill-creator]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Agent, WebFetch, WebSearch, Read, Glob, Grep, Write, Bash]
---

In this repo, find where incoming requests are handled and where logging happens, then write a plan (don't implement it) for adding a per-request correlation ID that appears in every log line and in the response headers. Save the plan to PLAN.md.

Input files: src/server.ts, src/logger.ts, src/routes/users.ts, src/routes/orders.ts, src/db.ts, src/middleware/auth.ts, package.json

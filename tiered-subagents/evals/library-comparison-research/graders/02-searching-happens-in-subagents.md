---
type: llm
focus: trace
weight: 1
---

The top-level session makes no WebSearch calls itself; open-ended searching happens inside subagents, and any direct WebFetch by the top-level session targets a known URL with a narrow question

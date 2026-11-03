---
name: tiered-subagents
description: Run agentic work as a cheap, fast, tiered team. The session's top model only thinks, plans, judges and synthesizes, while subagents on cheaper models (Haiku for web research, searches, file discovery and data extraction; Sonnet for routine implementation, tests and focused reviews) do the legwork in parallel. Use this whenever a task is multi-step development, research, debugging, data gathering, codebase exploration or a comparison that needs several sources. Also use it when the user says "efficient", "cheap", "save tokens", "use subagents", "parallel", "agentic", "fan out" or "delegate", even if they never name this skill. Skip it for one-shot answers that need a handful of tool calls.
---

# Tiered subagents

The session model is the most expensive and capable worker available, so use it only for what
needs it: understanding intent, deep reasoning, planning, judging evidence and writing the final
answer. Hand everything mechanical (fetching pages, searching, reading lots of files, pulling
out data, routine coding, running checks) to subagents on cheaper models, and run them in
parallel.

Why it pays off: every page or file the orchestrator reads lands in its own context, where it is
billed at the top rate and re-read on every later turn. A Haiku worker reads the same page for a
fraction of the cost and sends back ten lines. The orchestrator ends up with conclusions instead
of raw material. It stays sharp, the run finishes sooner because workers run at the same time,
and the bill drops.

## Roles

| Tier | Claude Code `Agent` call | Give it |
|---|---|---|
| **Scout** | `model: "haiku"` (`subagent_type: "Explore"` for read-only code search, `general-purpose` for the web) | Open-ended web research that needs a search and then several hops, docs lookups where the right page is unknown, finding files and symbols across a codebase, reading large logs or many files, extracting facts, numbers or tables, running a command and reporting the result, mechanical edits with an exact spec |
| **Builder** | `model: "sonnet"` | Implementing from a clear spec, writing tests, research that has to weigh several sources against each other, focused code review of a diff, debugging when the repro is known |
| **Orchestrator** | you (or `model: "opus"` for an independent second opinion) | Clarifying requirements, architecture and tradeoffs, deciding what to delegate, writing the plan, judging conflicting results, debugging when the cause is ambiguous, the final answer |

Default to the lowest tier that can plausibly do the job. When a scout's result comes back thin,
contradictory or plainly wrong, send it again one tier up with a sharper brief rather than doing
the reading yourself. Escalating is cheap; doing it yourself is what this skill exists to avoid.

Always set `model` explicitly. If you leave it out, the subagent inherits the session's top
model, and that silently undoes the savings.

**Known URL? Call WebFetch directly.** In Claude Code, WebFetch already runs a small, fast model
over the page and returns only the answer to the prompt you give it. The raw page never enters
your context. So for "what does this one page say about X", a direct WebFetch with a narrow
prompt is cheaper than a subagent wrapped around the same fetch, because every subagent pays its
own startup context. Send scouts out for work that needs searching, several hops or a lot of
reading.

**Cheap per token is not cheap in total.** A scout with no stopping rule will happily make twenty
tool calls and read a million tokens. Measured on a three-library comparison, uncapped Haiku
scouts cost more than the top model doing the fetches itself. Every scout brief needs a budget
and a definition of done (see below).

## Workflow

1. **Think first (orchestrator).** Restate the goal, decide what "done" looks like, and split the
   work into independent questions or units. This short planning step is where the top model
   earns its cost, so don't skip it.
2. **Scout in parallel (Haiku).** Send every independent scout in **one message** with several
   `Agent` calls so they run at the same time. One scout per source, question or area of the
   codebase works well. Run them in the background when you have your own work to do meanwhile.
3. **Synthesize (orchestrator).** Read the compressed reports, reconcile conflicts and make the
   decisions. If a fact is load-bearing (a price, an API signature, a breaking change), confirm it
   with one more cheap check before you rely on it.
4. **Build (Sonnet).** Hand each worker a self-contained spec. Run them in parallel when they
   touch different files. When they would edit the same files, run them one after another or
   give each its own git worktree (`isolation: "worktree"`).
5. **Check (Haiku or Sonnet).** A cheap worker runs the build, tests and linters and reports only
   the failures.
6. **Review and report (orchestrator).** Look over the diff or results with your own judgment,
   then answer the user.

Not every task uses every step. A pure research question stops after step 3, and a small code
change might be: one scout, then a plan, then one builder.

## Writing a brief

A subagent knows only what you put in its prompt, and you see only what it sends back. Both
handoffs lose detail, so the brief is where the quality and the cost are decided.

- **Goal and scope.** What to find or do, and where to stop. Narrow scopes finish faster and
  wander less.
- **Context.** The paths, URLs, versions and constraints it needs, and what you have already
  ruled out. Point it at files rather than pasting them.
- **A budget and a stopping rule.** For example "at most 5 fetches or searches; stop as soon as
  you have the free-tier limits and the cheapest paid price". Name the exact facts you need, so
  the scout knows when it's finished instead of researching everything it can find.
- **A compressed return format.** Ask for the answer itself, not material for you to summarize:
  for example "≤10 bullets, each with the full source URL (https://…) or `file:line`; quote exact
  numbers; say 'not found' rather than guessing". Raw page dumps in the return defeat the
  purpose. Carry the full URLs through into your final answer so the user can check them.
- **No leading hypothesis.** "Find what controls X" gets an honest answer. "Confirm that Y
  controls X" tends to come back confirmed whether or not it's true.

Example scout call:

```
Agent({
  description: "Fetch Neon pricing",
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: "Find Neon's current free-tier limits and cheapest paid plan (price/month, storage,
  compute hours). Start at https://neon.tech/pricing; use at most 4 fetches/searches and stop
  once you have those figures. Return ≤8 bullets with the exact figures and the full URL each
  came from. If something can't be found, say 'not found'; do not guess."
})
```

## When not to delegate

Spawning has overhead: the brief, the subagent's own startup context, and the round trip.

- If a job is one to three tool calls, or a lookup whose target you already know (one file, one
  grep, one known URL through WebFetch), do it yourself. A small repo you can read in a few
  calls doesn't need scouts either.
- Don't spawn a worker to re-check something you could verify in a single call.
- Keep it proportionate. A few well-scoped agents beat many tiny ones, and as a rule of thumb
  stay under about 8 per phase unless the user asked for scale.
- To ask a finished agent a follow-up, use `SendMessage` to that agent instead of starting a new
  one. It still has its context.
- Never invent or predict a pending agent's result. Wait for its report.

## Other harnesses

If you're not in Claude Code, map the tiers onto the cheapest, middle and top models your harness
offers for subagents. If it has no per-subagent model choice, keep the structure anyway: delegate
the reading and fetching so the main context stays small, and keep the orchestrator focused on
judgment.

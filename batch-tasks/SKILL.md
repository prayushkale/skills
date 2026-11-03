---
name: batch-tasks
description: Work through a list of tasks (features, bug fixes, requirements, review feedback) one item at a time, planning and implementing each in its own fresh-context subagent and committing each separately. Use whenever the user pastes or describes several work items at once, says "here's a list", "for each of these, plan then implement", "work through these one by one", or hands over a batch of fixes/changes to execute, even if they never name this skill. Keeps per-task context minimal to save cost and gives one clean commit per item.
---

# Batch tasks

The user hands over a list of work items. Execute them one at a time, each with only the context
that item needs, and leave one clean commit per item. The main session is a thin coordinator; the
thinking and coding happen in fresh subagents so context never accumulates across items.

Why this shape: a single long session carries every earlier item's files, diffs and dead ends into
every later item, which costs tokens and muddies reasoning. A fresh subagent per phase starts
cheap, and a commit per item keeps history reviewable and revertable.

## 1. Set up (main session, short)

1. Parse the list into discrete items. Give each a short slug and a one-line statement of the
   desired outcome. If the user's wording makes two items overlap or one is ambiguous enough that
   a plan would be a guess, ask once, up front, for all such items together. Do not interrupt
   later unless something new blocks you.
2. Order them. Respect dependencies (an item that builds on another goes after it); otherwise keep
   the user's order. Run sequentially: items usually touch overlapping files, and parallel edits
   cause merge pain. Only parallelize if the user asks, and then use one git worktree per item.
3. Learn the project's rules once, cheaply: read the repo's agent instructions (`AGENTS.md` /
   `CLAUDE.md`), `git log --oneline -10` for commit style, and the check commands (build, lint,
   test). Put the commit style and the checks into the brief you give each subagent, so they don't
   rediscover it.
4. If on the default branch, create one branch for the whole batch first. Never push, open PRs or
   touch remote services unless the user asked.
5. Show the user the ordered list in a few lines and start. Don't wait for approval of the list
   unless you reordered or split something.

## 2. For each item: plan, then implement

Use a fresh subagent for each phase. Pass only what that phase needs, never the whole conversation
or the other items' details.

**Plan phase** (read-only subagent, e.g. `Plan`, or `Explore` for lookups):
- Brief: the item's outcome, relevant repo rules, and a 2-3 line handoff note from earlier items
  only if this item depends on them.
- Ask for a short plan: files to touch, approach, tests to add or change, risks. Ask it to read
  only the code the item touches and, for big docs like `plan.md`, only the relevant sections.
- Planning should not edit files.

**Review the plan** (you, briefly): check it matches the item and the project's architecture rules.
Proceed straight to implementation when it does. Pause and ask the user only if the plan changes a
public contract, needs a new dependency, drops part of the item, or the item turned out to be much
bigger than it looked (then propose splitting it).

**Implement phase** (fresh write-capable subagent, e.g. `implementer`; prefer a cheaper model
for it when the plan is concrete):
- Brief: the approved plan plus the commit style and check commands.
- It writes tests first for logic where it fits, implements, runs the project's checks, fixes what
  fails, and makes one commit for this item only. It must not pick up unrelated cleanups or
  neighbouring items.
- It reports back in a few lines: commit hash, files changed, check results, and anything the next
  items should know. Keep only that report; discard the rest.

**Verify** (you): confirm the commit exists (`git log -1 --stat`), the working tree is clean, and the
reported checks passed. If not, send the failure back to a new implementer with just the error and
the plan, at most twice. Then stop and tell the user which item failed and why; don't build later
items on a broken base.

## 3. Wrap up

Give the user a table: item, status, commit hash, and any follow-ups or decisions you made on their
behalf. Mention items skipped or blocked. Don't repeat code or diffs; they are in the commits.
Offer a final whole-branch review or a PR only as a one-line suggestion.

## Keeping it cheap

- The coordinator keeps a tiny ledger (item, status, commit, handoff note), nothing more.
- One planner and one implementer per item. Don't add extra reviewer agents per step.
- Subagents read narrowly: symbols and sections, not whole files or whole docs.
- If the batch is long (more than ~8 items), suggest the user `/clear` between chunks and resume
  from the ledger and `git log`.

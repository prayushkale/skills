# skills

My personal agent skills.

| Skill | What it does |
|---|---|
| [batch-tasks](batch-tasks/SKILL.md) | Work through a list of tasks one at a time, each planned and implemented in a fresh-context subagent with one commit per item. |
| [git-branch-commit-pr](git-branch-commit-pr/SKILL.md) | Ship uncommitted changes end to end: branch, scan for secrets, commit, push and open a PR with `gh`, with safe handling of hooks, forks and existing PRs. |
| [linkedin-max-engagement](linkedin-max-engagement/SKILL.md) | Draft LinkedIn posts, carousels, comments and profiles for maximum reach, based on LinkedIn's 2026 feed architecture and large data studies, with a pre-publish scorecard. |
| [tiered-subagents](tiered-subagents/SKILL.md) | Run agentic work as a cheap, fast, tiered team: the top model plans and judges while budgeted Haiku/Sonnet subagents fetch, search and build in parallel. |
| [x-max-engagement](x-max-engagement/SKILL.md) | Draft X posts, threads, replies and Articles for maximum engagement, scored against X's published 2026 ranking weights, data studies and creator playbooks. |

Install one: `npx skills add prayushkale/skills -g -s <skill-name>` (e.g. `-s tiered-subagents`)

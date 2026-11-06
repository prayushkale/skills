# skills

My personal agent skills.

| Skill | What it does |
|---|---|
| [batch-tasks](batch-tasks/SKILL.md) | Work through a list of tasks one at a time, each planned and implemented in a fresh-context subagent with one commit per item. |
| [git-branch-commit-pr](git-branch-commit-pr/SKILL.md) | Ship uncommitted changes end to end: branch, scan for secrets, commit, push and open a PR with `gh`, with safe handling of hooks, forks and existing PRs. |
| [linkedin-max-engagement](linkedin-max-engagement/SKILL.md) | Draft LinkedIn posts, carousels, comments and profiles for maximum reach, based on LinkedIn's 2026 feed architecture and large data studies, with a pre-publish scorecard. |
| [safe-disk-cleanup](safe-disk-cleanup/SKILL.md) | Free disk space on macOS and Linux without losing anything: a read-only scan, verification of every candidate (unpushed git work, real duplicates, symlinks, locks), a plain explanation of each item, and nothing deleted without your yes for that item. |
| [tiered-subagents](tiered-subagents/SKILL.md) | Run agentic work as a cheap, fast, tiered team: the top model plans and judges while budgeted Haiku/Sonnet subagents fetch, search and build in parallel. |
| [viral-song](viral-song/SKILL.md) | Write, prompt and generate a song built to go viral on TikTok, Reels or Shorts with any AI music generator: pick a lane, write the clip unit first, translate it for the generator, and run a pre-generation checklist. Based on 340 hits; patterns, not a guarantee. |
| [x-max-engagement](x-max-engagement/SKILL.md) | Draft X posts, threads, replies and Articles for maximum engagement, scored against X's published 2026 ranking weights, data studies and creator playbooks. |

Install one: `npx skills add prayushkale/skills -g -s <skill-name>` (e.g. `-s tiered-subagents`)

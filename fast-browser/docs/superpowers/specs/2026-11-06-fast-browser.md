# fast-browser spec (2026-11-06)

Goal: make feed reading for x-max-engagement and linkedin-max-engagement at least 5x faster than Claude in Chrome, and give other agent work a reusable fast, robust browser skill.

Approach: agent-browser 0.27 with one warm session on a dedicated profile; one `eval --stdin` call scrolls and extracts posts as JSON; the LLM only picks and drafts; the user approves every reply; scripts post approved replies and verify them.

## Acceptance checks
Check files: `~/.agents/skills/fast-browser/tests/run.sh`, `~/.agents/skills/fast-browser/tests/fixtures/*`, `~/.agents/skills/fast-browser/tests/expected/*`

- [ ] AC-1 · CHECK: time a 20-post X feed scan with Claude in Chrome (baseline B), then `time fb eval --stdin < scripts/x-feed.js` with N=20 (new T) on the same logged-in account · EXPECT: T ≤ B/5 and 20 posts returned · EVIDENCE:
- [ ] AC-2 · CHECK: the same as AC-1 for the LinkedIn feed · EXPECT: T ≤ B/5 and 20 posts returned · EVIDENCE:
- [ ] AC-3 · CHECK: in a feed-mode run of each engagement skill, count screenshot calls and browser tool calls per scroll batch · EXPECT: 0 screenshots and ≤3 browser calls per batch · EVIDENCE:
- [ ] AC-4 · CHECK: `bash tests/run.sh` · EXPECT: exit 0, both fixtures match expected JSON · EVIDENCE:
- [ ] AC-5 · CHECK: run an extractor against a fixture with the primary selector removed · EXPECT: items still returned via the fallback and `selectorMisses` is non-empty · EVIDENCE:
- [ ] AC-6 · CHECK: post one user-approved reply on X and one comment on LinkedIn via the scripts · EXPECT: each script exits 0 and prints the verified reply/comment URL, which shows the text when opened · EVIDENCE:
- [ ] AC-7 · CHECK: run feed mode and do not approve anything · EXPECT: nothing is posted (no write commands in the transcript) · EVIDENCE:
- [ ] AC-8 · CHECK: run `fb get url` with a logged-out profile (fresh temp dir) on x.com/home · EXPECT: the extractor returns a `loginRequired` error and does not crash or hang · EVIDENCE:
- [ ] AC-9 · CHECK: `grep -n "Feed mode" ~/.agents/skills/{x,linkedin}-max-engagement/SKILL.md` and `grep -n "fast-browser"` in the same files · EXPECT: both match in both files · EVIDENCE:
- [ ] AC-10 · CHECK: user runs feed mode once on each site · EXPECT: user says it feels much faster than before · EVIDENCE:


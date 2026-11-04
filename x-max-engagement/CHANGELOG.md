# Changelog

## 2026-11-04 — v2.1 (eval fixes)
- Banned the negation-contrast pattern in all its forms ("Not X. Y.", "X isn't the problem. Y is.") and added a final self-check that searches drafts for it.
- A thread's last post now carries exactly one CTA.
- Replies are capped at 3 sentences counted explicitly; line breaks don't reset the count.

## 2026-11-03 — v2 (research rewrite)
- Re-verified every weight against the raw `param.rs` and added the ones v1 missed: share 2, click-dwell 0.4, click 0.3, photo expand 0.05, video open 0.02, not-dwelled -0.02, profile click 0, video quality view 0, post video 0. Explained that weights multiply predicted probabilities, not raw counts.
- Corrected the link rule. X said in July 2026 that links aren't deboosted and don't need to go in replies. Bare-link posts still underperform, so the rule is now: value in the post, then the link with a real caption.
- Removed X Communities advice. Communities shut down on 2026-05-30.
- Replaced the "50-120 replies/day" target with a quality-first range of 10-30 a day. X's product lead said low-value replies use up reach, and programmatic replies are now restricted.
- Marked out-of-network 0.75x as 2023-only. Gave the cold-start details: under 50k followers by default, under 200 impressions, under 2 h old, slot 15-16.
- Added the mutual-follow boost history (5-20 test, then 20, then 15), the 2023→2026 comparison, and a myths table (bookmarks, profile clicks, video bonus, the 30-minute window).
- New workflow: intake → angle by goal → draft → 16-point scorecard → 2-3 variants plus a post-publish plan.
- New references: hooks-and-structures (creator templates with sources), formats-and-data (Buffer, Metricool, Ordinal, Sprout), penalties (enforced vs unproven, AI-tell list), and sources with an evidence tier on each.
- Evals moved to `claude plugin eval` format (case.yaml + prompt.md + graders).

## 2026-11-03 — v1
- Initial skill.

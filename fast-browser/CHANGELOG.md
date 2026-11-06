# Changelog

## 2026-11-06 — v0.2 (live-verified on Claude in Chrome)
- X extractor verified live: 20 posts in 0.45s, ad flagged, no errors.
- LinkedIn extractor rewritten for the componentized layout and verified live: 20 posts in 6.7s (comment counts unreliable).
- Removed the agent-browser posting scripts (the dedicated profile did not keep a login and X rejects headless). Primary route is now Claude in Chrome `javascript_tool`.
- Writes through the extension are documented but not yet exercised.

## 2026-11-06 — v0.1
- Initial skill: `fb` wrapper, X and LinkedIn feed extractors, verified reply/comment scripts with `--dry-run`, synthetic-fixture tests.
- Extractors and posting scripts were tested on synthetic X fixtures only. Live validation on x.com and linkedin.com pending first login.

---
name: fast-browser
description: Fast, robust browser automation for agent work that reads or acts on many page items in sequence, such as scanning a social feed, collecting search results, or posting a few approved replies. Use whenever a task means "go through the feed / list / results and do X", scrape structured data from a logged-in site, or the browser step feels slow, and before reaching for Claude in Chrome or screenshots. Ships ready extractors for X and LinkedIn feeds that run in one call through Claude in Chrome (the user's logged-in Chrome) or agent-browser. For one-off clicks on a page you haven't seen, use agent-browser directly.
---

# fast-browser

Why browser agents are slow: every step runs observe, then LLM, then act, with screenshots or whole-page reads in between. This skill removes the LLM and the screenshots from the mechanical parts. Code scrolls and extracts. The LLM only decides and drafts.

Speed comes from four rules. Follow them in order of payoff.

## Rules

1. **Extract with one in-page script, not many tool calls.** One `javascript_tool` call runs an extractor that scrolls, waits for new nodes, dedupes through `window.__fbSeen`, and returns compact JSON for N posts. No screenshots, no `read_page`, no per-post loop.
2. **The LLM decides, code filters.** Pass the JSON to the model, which picks and drafts. Drop `isAd`/`isPromoted`/`isRepost` and old posts in code.
3. **Reuse the logged-in browser.** X rejects headless Chrome and the dedicated agent-browser profile did not keep a login in testing, so the verified route is Claude in Chrome (the user's real, logged-in Chrome). Do not spoof the user agent to get around bot checks.
4. **Batch.** Use `browser_batch` for known sequences (navigate, then run the script). Writes are few, so the slower click-and-type tools are fine for them.

## Scan a feed (verified live, 2026-11-06)
1. `tabs_context_mcp` (createIfEmpty), then use the tab it gives you (or `tabs_create_mcp`).
2. `browser_batch`: `navigate` to `https://x.com/home` (or `https://www.linkedin.com/feed/`), then `javascript_tool` with this text:
   ```
   window.__fbSeen = undefined; window.__FB_N = 20;
   await (<full contents of scripts/x-feed.js or scripts/linkedin-feed.js>)
   ```
   The file is an async IIFE that returns a JSON string, so it needs the `await ( … )` wrapper.
3. Parse `{items, errors, selectorMisses, ms, url}`.
   - `errors: ["loginRequired"]` means the user must log in to that site in Chrome. Stop.
   - A non-empty `selectorMisses` means the markup drifted. Results may still be fine, but fix the selector (see `references/site-recipes.md`).
   - A call returning `{}` means the promise was not awaited.
4. Call again for the next unseen N (leave `__fbSeen` alone), or reset it for a fresh scan.

Measured live: X 20 posts in 0.45s in-page; LinkedIn 20 posts in 6.7s (LinkedIn lazy-loads over the network).

Item shapes:
- X `{id,url,author,handle,text,ageMin,replies,reposts,likes,views,isReply,isRepost,isAd}`
- LinkedIn `{key,url:null,author,headline,text,ageLabel,reactions,comments,isPromoted}`. LinkedIn's current markup has no permalink in the DOM, so identify a post by `key` and comment on it in the feed.

The `javascript_tool` output filter blocks results that contain URLs with query strings. Strip them (`href.split('?')[0]`) and never output cookies.

## Act (writes)
Only post text the user approved in this session. Never auto-post.
- **X reply:** `navigate` to the post URL, `find` the reply box (`[data-testid="tweetTextarea_0"]`), click and type, click `[data-testid="tweetButtonInline"]`, then verify with `javascript_tool` that an article contains the first 40 characters of the reply.
- **LinkedIn comment:** locate the post by `key` (`document.querySelector('[componentkey="<key>"]').closest('div[role=listitem]')`), scroll it into view, click its `Comment` button, type in the editor, click the submit button, then verify the text appears under the post.
- Wait a random 20-60s between posts and respect the daily caps in the platform skill (X: 10-30).
- On any error, report it and check the thread before retrying, since the write may have gone through.

Writes through the extension were **not yet exercised** in this skill's testing.

## agent-browser route (`scripts/fb`, tests)
`scripts/fb` binds agent-browser to a persistent profile (`~/.agent-browser/profiles/social`). It is good for sites that allow headless and for the fixture tests (`bash tests/run.sh`, which uses a throwaway profile). For X and LinkedIn it did not hold a login in testing: after a manual login in Chrome for Testing, `x.com/home` still redirected to the logged-out page, and windows opened by the daemon were not visible. Use it with `eval --stdin` as `(echo 'window.__FB_N=20;'; cat scripts/x-feed.js) | fb eval --stdin`.

## Robustness
- Anchor on `data-testid` / ARIA labels with fallbacks (LinkedIn's class names are obfuscated), and report misses instead of swallowing them.
- Wait on elements (poll for new nodes), never fixed sleeps.
- If a script breaks, inspect one item's structure (attribute names, ARIA labels, no URLs), update the extractor and `references/site-recipes.md`, and add a fixture case.
- Escalation ladder: extractor script, then `find`, then `read_page`, then a screenshot (debugging only).
- Stop and ask the user after 2-3 failed attempts at the same browser step.

## Add a new site
Inspect one item, copy `scripts/x-feed.js`, change the selector lists and item shape, add a fixture and expected JSON in `tests/` (see `tests/make-fixtures.js`), then run `bash tests/run.sh`.

# Site recipes

Selectors are stable-first with fallbacks. Update here and in the extractor together. Last live verification: 2026-11-06 on the user's logged-in Chrome (X and LinkedIn extractors).

## X (x.com)
| Field | Primary | Fallback |
|---|---|---|
| Post container | `article[data-testid="tweet"]` | `article[role="article"]` |
| Permalink / time | `a[href*="/status/"] time` (closest `a`) | `time` |
| Author / handle | `[data-testid="User-Name"]` (name = first line, handle = `@\w+`) | `div[dir="ltr"] > span` |
| Text | `[data-testid="tweetText"]` | `div[lang]` |
| Metrics | `[data-testid="reply" / "retweet" / "like"]` aria-label | n/a |
| Views | `a[href$="/analytics"]` aria-label | n/a |
| Ad | `[data-testid="placementTracking"]` or a standalone "Ad" line | n/a |
| Reply box | `[data-testid="tweetTextarea_0"]` | `find role textbox` |
| Submit | `[data-testid="tweetButtonInline"]` | n/a |
| Login wall | `/i/flow/login` path, `[data-testid="loginButton"]` | n/a |

Quirks: X virtualizes the timeline (off-screen posts leave the DOM), so the extractor collects while scrolling. Metrics show as "1.2K", parsed to numbers.

## LinkedIn (linkedin.com/feed), componentized layout
Class names are obfuscated and there is no `data-urn`, no `/feed/update/` link and no `data-testid`. Anchor on ARIA labels.
| Field | Selector |
|---|---|
| Post | `div[role="listitem"]` that contains `button[aria-label^="Hide post by"]` (other listitems are the share box, "New posts", etc.) |
| Author | the `Hide post by <Name>` aria-label |
| Post key | first non-UUID `[componentkey]` inside the post (length >= 20, not `*replaceable*`, not `*Ref`) |
| Paragraphs | `p` not inside a button, in order: author, " • 1st", headline, age (`6m`, `1h`, `1w`), body (longest) |
| Age | the `p` matching `^\d+\s?(s\|m\|h\|d\|w\|mo\|yr)$` |
| Promoted | a standalone "Promoted" line |
| Action buttons | `Comment`, `Repost`, `Open reactions menu` (aria-labels) |
| Login wall | `/login`, `/authwall`, `#session_key` |

Quirks: the feed lazy-loads, so scroll the last listitem into view and poll for the count to grow. Reactions and comment counts are best-effort (comments read 0 in live testing, so the regex needs work). No permalink is available without opening the post's menu.

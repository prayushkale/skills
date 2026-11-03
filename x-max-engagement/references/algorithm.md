# X For You ranking: the published 2026 mechanics

Sources: [P] `xai-org/x-algorithm`, checked 2026-11-03.
- Weights: `home-mixer/params/param.rs`, https://raw.githubusercontent.com/xai-org/x-algorithm/main/home-mixer/params/param.rs
- Architecture: `README.md`, https://raw.githubusercontent.com/xai-org/x-algorithm/main/README.md
- Cold start: `home-mixer/scorers/author_cold_start.rs`
- Mutual-follow boost history: `docs/BIDIRECTIONAL_BOOST_CHANGE.md`

These are **default** values. X overrides some of them live through feature switches and runs experiments, which the repo says it publishes when they reach about 10% or more of traffic. Re-check the raw file before quoting a number as current.

## Contents
- How the score is computed
- Full weight table
- Pipeline: sourcing, filtering, scoring
- Cold start (small accounts)
- Mutual-follow (bidirectional) boost
- 2023 → 2026 changes
- Myths and corrections

## How the score is computed
The Phoenix transformer predicts, for each viewer and each candidate post, the probability of many actions at once. The final score is `Σ weight × predicted probability`; continuous outputs such as dwell time are also multiplied by their weights. The code comments warn that the weights apply to predictions, not to raw engagement counts, so "a copy-link share is 30 likes" describes the scoring, not what happens when one user shares your post. Candidates are scored independently, so a post's score does not depend on what else is in the batch.

## Full weight table (param.rs defaults)
| Parameter | Default | Note |
|---|---|---|
| ShareViaCopyLinkWeight | 20.0 | Largest positive weight |
| ReplyWeight | 5.0 | |
| QuoteWeight | 5.0 | |
| ShareViaDmWeight | 5.0 | |
| BidirectionalFollowReplyWeightBoost | 15.0 | Added to the reply weight when viewer and author follow each other; original posts only |
| BidirectionalFollowDwellWeightBoost | 0.0 | |
| FollowAuthorWeight | 4.0 | |
| ShareWeight | 2.0 | Other share actions |
| RetweetWeight | 1.0 | |
| FavoriteWeight (like) | 0.66 | |
| ContClickDwellTimeWeight | 0.4 | Time spent after clicking or expanding the post |
| ClickWeight | 0.3 | |
| OpenLinkWeight | 0.2 | |
| DwellWeight | 0.05 | |
| PhotoExpandWeight | 0.05 | |
| QuotedClickWeight | 0.05 | |
| VideoOpenWeight | 0.02 | |
| PostUnexploredWeight | 0.015 | |
| ContDwellTimeWeight | 0.006 | |
| ProfileClickWeight | 0.0 | Does not count toward the score |
| VqvWeight (video quality view) | 0.0 | |
| PostVideoWeight | 0.0 | No built-in bonus for having a video |
| NotDwelledWeight | -0.02 | Scrolled past |
| BlockAuthorWeight | -31.2 | |
| NotInterestedWeight | -52.272 | |
| MuteAuthorWeight | -58.8 | |
| ReportWeight | -234.0 | |

Ratios to a like (0.66): copy-link ≈ 30×, reply/quote/DM ≈ 7.6×, mutual reply (20) ≈ 30×, follow ≈ 6×, mute ≈ −89×, not-interested ≈ −79×, report ≈ −355×.

## Pipeline
1. **Sourcing.**
   - In-network posts (accounts the viewer follows) come from Thunder.
   - Out-of-network posts come from Phoenix embedding retrieval and SimClusters.
   - A shared list of popular recent posts is added on top.
2. **Filtering.** Removed before ranking:
   - duplicates
   - posts older than **48 hours**
   - the viewer's own posts
   - posts the viewer has already seen
   - muted or blocked authors and muted keywords
   - out-of-network reposts and replies
   - for new viewer accounts, out-of-network posts below an engagement threshold
   - posts removed by visibility filtering
3. **Scoring.**
   - Phoenix predictions multiplied by the weights above.
   - Author diversity: each later post from the same author is multiplied by a decaying factor down to a floor.
   - Out-of-network discount: posts from accounts the viewer doesn't follow, and replies and reposts from accounts the viewer does follow, are multiplied by a factor below 1. No number is published in 2026.
   - A new-author (cold start) boost.
4. **Grox** runs when a post is published. Its classifiers cover spam, adult content, and violent media, and it builds text and image embeddings. The repo doesn't publish the prompts.

## Cold start (the small-account boost)
`author_cold_start.rs` plus the param defaults:
- **Eligibility:**
  - the author has at most 50,000 followers (`cold_start_follower_cap`; a test fixture uses 1,000, and the live value can differ)
  - the post has under 200 impressions
  - it is under 7,200 s (2 h) old
  - it is an original post, not a reply or repost
- **Effect:** at most one eligible post per feed request is moved up to a target slot around rank 15-16. This is a floor, not a multiplier, and Thompson sampling chooses among candidates.
- **Implication:** original, niche-specific posts from small accounts get a real but small discovery lottery in their first 2 hours. Make each original count, because a weak post wastes the slot.

## Mutual-follow (bidirectional) boost history
Source: `docs/BIDIRECTIONAL_BOOST_CHANGE.md`.
- 2026-07-10: A/B test of values 5-20.
- 2026-07-13: shipped broadly at 20.
- 2026-07-24: reduced to 15, the current default.

The boost applies only to replies on **original posts** where viewer and author follow each other. **Practical effect:** follow back people in your niche who reply with substance. Their predicted replies on your future posts then score 20 instead of 5.

## 2023 → 2026 changes
Source: the 2023 `twitter/the-algorithm` repo, via a secondary reading at https://ernests.github.io/the-algorithm [S].

| Signal | 2023 | 2026 |
|---|---|---|
| Reply | 13.5 | 5.0 |
| "Reply engaged by author" | 75.0 | removed; replaced by the mutual-follow boost (+15) |
| Like | 0.5 | 0.66 |
| Report | -369 | -234 |
| Copy-link share, DM share, quote, follow | not weighted | 20 / 5 / 5 / 4 |
| Out-of-network | 0.75× | "factor below 1", no number |

The big shift: **sharing now dominates**, while replies are still strong but no longer dwarf everything.

## Myths and corrections
| Myth | Reality |
|---|---|
| "Links are penalized; always put them in the first reply" | X said links were not deboosted, and in July 2026 that "you do not need to put the links in replies anymore" [P via news]. Bare-link posts still get the lowest engagement [S]. |
| "Out-of-network posts get 0.75×" | That figure is from the 2023 code. 2026 says only "below 1". |
| "Bookmarks are a ranking signal" | Bookmarks are not in the 2026 weights. Optimize for shares instead. |
| "Profile clicks boost a post" | The weight is 0.0. |
| "Video gets a built-in boost" | `PostVideoWeight` and `VqvWeight` are 0.0. Video helps only if it earns dwell and shares. |
| "The first 30 minutes decide everything" | No such window exists in the code. The cutoff is 48 h, and cold start runs for 2 h. Early engagement still feeds the predictions. |
| "Phoenix is Grok" | The repo describes Phoenix as a transformer and Grox as content classifiers. Calling Phoenix "Grok-based" is secondary-source wording. |
| "Premium gets a ranking multiplier" | There is no Premium weight in the published code. Premium accounts show much higher median reach in studies [S], likely through reply ranking, verification, and other surfaces. |
| "Communities give small accounts reach" | X shut down Communities on 2026-05-30. |

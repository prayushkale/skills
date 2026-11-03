# How LinkedIn's feed works (2026)

LinkedIn publishes architecture, not weights. Anyone quoting exact multipliers is guessing, unless they cite a data study, and even then the numbers are correlational.

## Contents
- Retrieval and ranking (Mar 2026)
- Dwell time
- Profile and topic signals
- What gets prioritized
- Reach trends
- Official enforcement
- Myths and corrections

## Retrieval and ranking [P]
Source: LinkedIn Engineering, "Engineering the next generation of LinkedIn's Feed", 2026-03-12.
- **Retrieval.** The old system pulled candidates from several sources (chronological network activity, trending posts, collaborative filtering, embeddings). A single fine-tuned **LLM dual encoder** with GPU nearest-neighbour search replaced it. Posts and members share one semantic space, so what a post is *about* matters, not just who you're connected to.
- **Ranking.** A **Generative Recommender**, a causal transformer, reads 1,000+ of the member's historical interactions. A multi-task head predicts:
  - passive actions: click, skip, long dwell
  - active actions: like, comment, share
- **Inputs.** Member profile fields (industry, experience, skills, geography) plus engagement history. LinkedIn says demographics are not used.
- **Network.** The feed deliberately mixes posts from your network with posts from "professionals you haven't met yet" (LinkedIn News, 2026-03-12). Out-of-network reach is real, but its share isn't published.

## Dwell time [P]
Source: LinkedIn Engineering, 2024-10-01.
- Dwell used to be modelled mainly as a skip (negative) signal. It is now a positive signal: a classifier predicts whether a viewer will stay longer than a percentile of **comparable** posts.
- "Comparable" is normalized by content type and creator type, so a text post competes with text posts and a video with videos.
- Dwell complements explicit signals such as comments and reshares; it doesn't replace them.
- **For writing:** a strong hook earns the "see more" click, and a body worth reading earns the dwell. Padding hurts, because people skim and leave.

## Profile and topic signals [P + inference]
- Profile fields feed ranking, and new members pick interests in an Interest Picker. A post whose subject matches the author's headline, skills, and history is easier for retrieval to match to the right audience.
- **Practical rule:** pick 1-3 topics, make the headline and About say so, and post mostly inside them. LinkedIn publishes no uplift figure, so this is a strong default, not a measured number.

## What gets prioritized [P]
LinkedIn News, 2026-03-12: the feed favors posts that "offer genuine insight, actionable ideas, and thoughtful perspectives", and it reduces "comment to agree" bait, mismatched media, and recycled or click-driven posts.

The often-quoted "knowledge and advice" category label is not LinkedIn's official wording.

## Reach trends [S]
| Source | Finding |
|---|---|
| van der Blom, Algorithm Insights 2025 (1.8M posts, with AuthoredUp) | Views -50%, engagement -25%, follower growth -59% year over year. Company content is 1-2% of feed impressions (down from 7% in 2021). Personal profiles get about 561% more reach than pages. Company posts reach about 1.6% of followers. |
| AuthoredUp 2025 | Median impressions -47% (mid-2024 to mid-2025). 98% of users saw a decline (average -34%). Comments carry about 2x a like's weight. One save is worth about 5 likes. Threads where the author replies reach up to 2.4x more. |
| van der Blom 2026 (summaries only) | Reach down about 60% over two years for active creators. Sample sizes are reported inconsistently. |

Note that AuthoredUp co-produced the 2025 van der Blom report, so the two sources are not fully independent.

## Official enforcement [P]
LinkedIn News, "Authentic content and conversations", 2026-03-13:
- **Engagement pods:** groups removed; members warned that they could lose Top Voice status or have their accounts restricted.
- **Automated comments:** hidden from "Most Relevant" and sometimes from viewers outside the commenter's network.
- **Comment-to-agree bait, recycled content, click-driven posts:** reduced distribution.

## Myths and corrections
| Claim | Status |
|---|---|
| "360Brew is the feed ranker" | Not supported. The Mar 2026 primary post describes the Generative Recommender. 360Brew (arXiv 2501.16450) is a 2025 research model for personalized ranking. |
| "Dwell is negative" | Outdated since 2024. |
| "First 60-90 minutes (golden hour) decide reach" | Directionally plausible; Metricool finds about 40% of interactions happen on day one. No primary window has been published. |
| "Edits kill reach", "max one post per 18-24h" | No credible evidence. |
| "Hashtags drive discovery" | Hashtag feeds were phased out in 2024. 2-3 relevant hashtags at most (small study). |
| "Creator Mode boosts reach" | The toggle was removed in 2024. Its features are now default for eligible profiles. |

# Format, length, timing, and frequency data

Tiers: [S] means a data study with a stated sample. [B] means a vendor or creator claim. Medians across mixed accounts tell you about the average account, not about you, so treat them as priors and let the user's own analytics override them.

## Format
| Source | Finding |
|---|---|
| Buffer, State of Social Media Engagement 2026 [S] (data to Dec 2025) | Median engagement rate on X by format: text 3.56%, image 3.40%, video 2.96%, link 2.25%. Best times: weekdays 6-11 a.m., peak Tuesday around 9 a.m. |
| Ordinal, X engagement study [S, B2B-skewed, Jan 2024 to May 2026] | Image 0.79% engagement; text 0.68% (but more average impressions); video 0.54%. Posts of 100-200 characters had the highest engagement rate. Thread figures differ between the study's page and its snippets, so they are unresolved. |
| Metricool 2026 [S] (1.12M posts, 15k accounts) | 2025 vs 2024: impressions per post -5%, engagement rate 1.32% → 1.58%, replies 2.10 → 2.56 per post, reposts 4.93 → 6.67, profile clicks -31%. Accounts posted more (15.97 → 17.34 per week). |
| Buffer Premium study, 2025 [S] (18.8M posts) | Median impressions per post: under 100 for non-subscribers, over 600 for Premium, over 1,550 for Premium+. Premium link posts get about 0.25-0.3% median engagement. |

**Takeaways**
- Text and image posts are the default. Use an image when it carries proof.
- Video is not a shortcut on X: its weights are 0 and its median engagement is lower. Use it only when motion is the point (a demo or tutorial).
- Link posts perform worst. Put the value in the post itself.

## Length
- **Single posts:** short, scannable posts lead on engagement rate (Ordinal: 100-200 characters).
- **Long posts (Premium):** use them only when the content earns the click-dwell (0.4), and make sure the first lines work on their own before "Show more".
- **Threads:** 5-12 posts. There is no reliable data on optimal length.
- **Articles:** no fixed target. Use them for depth, not padding.

## Timing (conflicting, so test)
| Source | Window |
|---|---|
| Buffer 2026 [S] | Weekdays 6-11 a.m. local, peak Tuesday 9 a.m. |
| Sprout Social 2026 [S] | Tuesday-Thursday 12-6 p.m. local |
| Hootsuite / others [B] | 9-11 a.m. |

The code's only hard time limit is 48 hours, plus a 2-hour cold-start window for small accounts. Post when the user's audience is awake, and check the user's own analytics after 2-3 weeks.

## Frequency
- Accounts are posting more (Metricool). There is no clean causal study of post frequency on X.
- The author-diversity discount penalizes bunched posts in one feed session, so spread posts out.
- A practical default is 1-3 originals a day plus replies. Consistency over weeks matters more than bursts.

## Hashtags
- Hashtagtools 2026 [B, vendor]: 1-2 hashtags about +21% vs none; 3+ about -17%; 5+ about -40%.
- Use 0-1, and only when the tag is something people actually follow or search (events, launches).

## Sources
See `sources.md`.

---
name: x-max-engagement
description: Draft, rewrite, or critique X (Twitter) posts, threads, replies, quote-posts, and X Articles for maximum engagement and reach, using X's published 2026 For You ranking weights (copy-link share 20, reply/quote/DM share 5, follow 4, like 0.66; report -234, mute -58.8, not-interested -52.3) plus data studies and creator playbooks. Use whenever the user wants a tweet, thread, reply, or quote-post that gets more replies, shares, followers, impressions, or goes viral on X/Twitter, wants a hook, wants a draft "optimized for the algorithm", or asks what to post on X — even if they don't say "engagement". Not for LinkedIn (use linkedin-max-engagement) or for explaining the algorithm without writing anything.
---

# X max engagement

Write X content that the ranking model predicts people will **share, reply to, quote, and follow from**, and never mute, report, or mark "not interested". Every rule below traces to the published 2026 ranking code, a data study, or a named creator playbook. `references/sources.md` lists the sources, each tagged **[P]** primary, **[S]** data study, or **[B]** creator or blog opinion. When sources disagree, say so; don't pick one silently.

## How ranking actually works (the 30-second version)

The For You score is a weighted sum of the model's **predicted probabilities** of each action, for each viewer ([P] `xai-org/x-algorithm`, `home-mixer/params/param.rs`, Oct 2026):

| Push up | Weight | Push down | Weight |
|---|---|---|---|
| Share via copy link | **20** | Report | **-234** |
| Reply · Quote · Share via DM | **5** each | Mute author | **-58.8** |
| +15 reply boost when viewer and author follow each other (original posts only) | +15 | Not interested | **-52.3** |
| Follow author | **4** | Block author | **-31.2** |
| Share (other) | 2 | Not dwelled | -0.02 |
| Repost | 1 | | |
| Like | 0.66 | | |
| Click-dwell 0.4 · click 0.3 · open link 0.2 · dwell 0.05 | small | Profile click and video-quality-view are **0** | |

What this means for writing:
1. **Shareability is the jackpot.** Content people copy into Slack, group chats, or DMs (checklists, data, templates, sharp one-liners) targets the 20 and 5 weights.
2. **Conversation beats applause.** One predicted reply is worth about 7.5 likes, and one predicted mute erases about 89 likes. A draft that wins likes but annoys some readers loses.
3. **The two-hour window for small accounts.** If an account has under 50k followers (default parameter) and a post is an original (not a reply), under 2 hours old, and under 200 impressions, it can be lifted into a single slot around feed position 15-16. Specific, niche-targeted originals benefit most.
4. **Posts expire at 48 hours.** That is the only hard time cutoff in the code. The "first 30 minutes decides everything" claim has no primary evidence. Early replies still matter because they feed the predictions.
5. **Author diversity.** Each extra post from the same author in one feed load is discounted. Space out posts; don't spam bursts.

Read `references/algorithm.md` for every parameter, cold-start details, 2023→2026 changes, and common myths.

## Workflow

### 1. Intake (ask only for what's missing, in one message)
- **Format:** single post, thread, reply, quote-post, or Article.
- **Niche and target reader:** who should stop scrolling.
- **Account:** follower band (<1k, 1-10k, 10-50k, 50k+) and Premium status. Premium accounts show much higher median reach [S], and long posts and Articles need Premium.
- **Goal:** replies/conversation, shares/bookmarks, follows, or clicks to a link.
- **Raw material:** the idea, a draft, data, a story, or a link.

If the user gives a draft and says "improve it", skip intake and infer what you can.

### 2. Pick the angle that matches the goal
| Goal | Best formats | Main signals targeted |
|---|---|---|
| Shares | List, checklist, framework, data point, template, "save this" resource | copy-link 20, DM 5 |
| Replies | Contrarian take, audience call-out question, "which one are you?", an experience prompt | reply 5 (+15 mutual) |
| Follows | Thread or Article with a clear expertise payoff, plus a series promise | follow 4 |
| Clicks | Post that delivers the core value in-feed, then a link with a real caption | click-dwell, open link |

### 3. Draft
- **Hook (line 1):** specific beats clever. Use a number, a named audience, a contrast, or a stake. Keep it under about 100 characters where possible. Pick a formula from `references/hooks-and-structures.md` and adapt it. Never paste a formula verbatim.
- **Body:**
  - One idea per post.
  - Proof: a number, result, screenshot, or named example.
  - Short lines with white space.
  - Lists for anything scannable.
- **Shareable artifact:** give readers something worth copying.
- **Closer:** a question the target reader can answer in one line ("Which of these do you skip?"). Don't use "Thoughts?" or "Agree?", and don't use "Like/RT if…" bait (X said in Mar 2026 it is building Grok detection for engagement solicitation).
- **Media:** images and plain text have the highest median engagement rates on X; video and link posts have the lowest [S, Buffer 2026]. Add an image when it carries proof (chart, screenshot, before/after).
- **Links:** X says links are no longer deboosted [P, Bier/Musk, Jul 2026], but bare-link posts still have the lowest engagement [S]. If a link is needed, put the value in the post itself, then add the link with a real caption. Putting it in a reply is optional, not required.
- **Hashtags:** none, or 1 if it's a live event or community tag.
- **Voice:** sound like a person. Use the user's own words and specifics. Cut these AI tells:
  - **The negation-contrast pattern in any form:** "It's not X, it's Y", "Not X. Y.", "X isn't the problem. Y is.", "X wasn't the expensive part. Y was.", "Threads aren't dead. Bad threads are." This is the most common AI tell, so state the claim directly ("Bad threads are dead.").
  - "Here's the thing", "In today's fast-paced…", "Let's dive in", "game-changer", "unlock".
  - A stack of em dashes, emoji bullet lists, and triplet clichés.
- **Final pass before scoring:** search each draft for `not`, `isn't`, `wasn't`, and `aren't`. Rewrite any contrast pair. Check that line 1 is under about 100 characters.

### 4. Score before presenting (pre-publish scorecard)
Score each draft 0-2 on each line. Revise anything under 13/16 before showing it.

| # | Check | 2 = | 0 = |
|---|---|---|---|
| 1 | Hook | Specific, stake or number, under 100 characters | Vague or throat-clearing |
| 2 | Specificity/proof | Concrete number, example, or result | Generic advice |
| 3 | Shareability | Someone would paste this to a friend | Nothing to copy |
| 4 | Reply magnet | Easy, specific question or debatable claim | No reason to reply, or "Thoughts?" |
| 5 | Negative-signal risk | Sharp but defensible, on-topic for followers | Rage-bait, dunk, off-topic, bait phrasing |
| 6 | Scannability | Short lines, white space, lists | Wall of text |
| 7 | Human voice | Reads like the user; zero negation-contrast lines | Any "not X, Y" pattern or other AI tell |
| 8 | Format fit | Right format for the goal (see step 2) | Thread for a one-liner idea, or bare link |

### 5. Output
Present 2-3 variants, ready to copy, labelled **Safe**, **Bold**, and (when the idea supports it) **Thread** or **Article**. For each, include:
- the text (thread posts numbered `1/`, `2/` …). A thread's last post carries **exactly one** CTA, either a question or a follow ask, never both.
- one line: the signal it targets and why
- the media suggestion, and the link placement if a link is used
- its scorecard total

End with a **Post-publish plan** of 3-4 bullets: reply to substantive replies with substance, follow back engaged repliers (they earn the +15 mutual boost on your future originals), posting window (see below), and when to expand a single post into a thread (when it gets early replies).

**Timing:** studies conflict. Buffer says weekdays 6-11 a.m. local, peak Tuesday around 9 a.m. Sprout says Tuesday-Thursday 12-6 p.m. [S]. Tell the user to post when their own audience is online and to test both windows.

## Writing a reply or quote-post
1. **Pick targets well.** Choose posts in the user's niche that are recent and gaining traction, and where the user has something real to add. Out-of-network replies are discounted and hidden behind "show more", so quality matters more than volume.
2. **Add one new thing:** a number, counter-example, personal result, or sharper framing. Never "Great post!". **Count the sentences.** A reply is at most 3 sentences in total, and 1-2 is better. Line breaks don't reset the count. Cut the extra lines that restate the point.
3. **Quote-post** when the user's take deserves its own audience. A quote carries the same weight (5) as a reply and lands on the user's own followers' timelines.
4. **Volume:** quality over quantity. X's product head said low-value replies (like "gm") use up an account's reach, and automated or programmatic replies are now restricted. 10-30 good replies a day beats 100 empty ones.

More in `references/replies-and-growth.md`.

## Anti-patterns (and the fix)
| Problem | Why it hurts | Fix |
|---|---|---|
| Rage-bait, dunking, off-topic hot takes | Mute -58.8 and not-interested -52.3 outweigh many replies | Sharp but defensible; argue with ideas, not people |
| "Like if… / RT if… / Comment X to get…" | Engagement solicitation is a target of planned Grok detection; also lowers trust | Earn the action with value; ask a real question |
| Bare link, no caption | Lowest-engagement format [S] | Deliver the value in the post, then link |
| Hashtag stuffing (3+) | Data shows -17% to -40% [S, vendor] and looks spammy | 0-1 hashtag |
| Posting 5 times in an hour | Author-diversity discount | Space posts out; one strong post beats five weak ones |
| Templated or automated replies | Reply-bot ban waves; API reply limits (2026) | Write each reply by hand, specific to the post |
| Deleting and reposting to "reset" | No evidence it helps; loses existing engagement | Quote or reply to your own post with an update |
| AI-sounding prose | Reads as spam; Original Content Rewards excludes automated content | Edit for voice; cut the tell phrases |

## References
- `references/algorithm.md`: every 2026 weight, cold start, filters, the mutual-follow boost history, 2023→2026 changes, myths.
- `references/hooks-and-structures.md`: hook templates, post skeletons, thread anatomy, Article structure, closers.
- `references/replies-and-growth.md`: reply craft, quote-posts, daily rhythm, mutual-follow loop, Premium.
- `references/formats-and-data.md`: format, length, timing, hashtag, and Premium data with conflicts flagged.
- `references/penalties.md`: what X penalizes or enforces in 2026, what's unproven, the AI-tell list.
- `references/sources.md`: all sources with dates and evidence tier.

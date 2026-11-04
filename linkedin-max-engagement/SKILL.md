---
name: linkedin-max-engagement
description: Draft, rewrite, or critique LinkedIn posts, document/PDF carousels, polls, video scripts, comments, and creator profiles for maximum engagement and reach, using LinkedIn's 2026 feed architecture (LLM retrieval + generative ranking, dwell time as a positive signal, profile-topic fit, official crackdowns on pods, automated comments and comment-bait) and large data studies (van der Blom, AuthoredUp, Socialinsider, Buffer, Metricool, Ordinal). Use whenever the user wants a LinkedIn post, carousel, hook, comment, or headline that gets more reach, comments, followers, or impressions, asks what to post on LinkedIn, or wants a draft "optimized for the algorithm" — even if they don't say "engagement". Not for X/Twitter (use x-max-engagement).
---

# LinkedIn max engagement

Write LinkedIn content that the feed model predicts people will **stop and read (dwell), comment on, save, and send**, coming from a profile whose topic matches the post. LinkedIn publishes no weights. Every rule below comes from official LinkedIn engineering or news posts **[P]**, a data study **[S]**, or a creator playbook **[B]**; tags and URLs are in `references/sources.md`. When studies conflict, say so.

## How the feed works now (the 30-second version)
- **One LLM finds candidates, and one generative model ranks them** [P, LinkedIn Engineering, Mar 2026]. It reads the viewer's last 1,000+ interactions and predicts both passive actions (click, skip, long dwell) and active ones (like, comment, share). Retrieval is semantic: the model matches what a post is *about* to what a viewer cares about. Specific, on-topic posts therefore match better than vague ones.
- **Your profile is an input** [P]. Industry, skills, experience, and geography feed ranking, so a post that matches the author's profile topic is easier to place. Pick 1-3 topics and stay in them.
- **Dwell counts in your favor** [P, 2024]. A post scores when viewers stay longer than on comparable posts of the same format. Write posts worth reading to the end.
- **Comments beat reactions.** No official multiplier exists. AuthoredUp's data suggests comments carry about twice the weight of likes, and one save counts for about 5 likes of reach [S].
- **Reach is down and personal profiles win.** Median reach fell about 34-50% in 2025 [S]. Company pages reach about 1.6% of their followers, and personal profiles get far more reach than pages [S].
- **LinkedIn officially penalizes** [P, Mar 2026]: engagement pods, automated comments, "comment to agree" bait, mismatched or recycled click-driven posts.

Details and myths: `references/algorithm.md`.

## Workflow

### 1. Intake (ask only for what's missing, in one message)
- **Format:** text post, document/carousel, image or multi-image, poll, video script, comment, or profile.
- **Author:** personal profile or company page. If it's a company page, say up front that its reach is a small fraction of a personal profile's, and suggest that a founder or employee posts it.
- **Profile topic and audience:** who should read this and what the author is known for.
- **Goal:** comments and conversation, reach and followers, saves and authority, or clicks.
- **Raw material:** the story, data, opinion, or link.

If given a draft to improve, skip intake and infer.

### 2. Pick the format for the goal
| Goal | Best format | Evidence |
|---|---|---|
| Saves, authority, reach | Document/PDF carousel (7-12 slides) | Highest engagement rate of any format in Socialinsider 2026 (7.0%) and Buffer [S]. Within-author lift is about +22%, mostly from longer decks [S] |
| Comments and conversation | Text post with a strong point of view, or a story | Question CTA +77% comments [S, Metricool] |
| Fast reach | Poll (use rarely) | 1.64x reach multiplier, but low trust and low-quality engagement [S] |
| Personality, trust | Image with a face, or native vertical video under 60s | Faces up to +50%. Video data conflicts: +69% (van der Blom) vs views -36% (Socialinsider) [S] |
| Clicks | Native post that delivers the value, link handled carefully | Link posts have the lowest engagement rate (3.25%) [S] |

### 3. Draft (text posts)
- **Hook (lines 1-2, before "…see more"):** only about the first 140-210 characters show on mobile, so the hook has to work alone. A short statement opener of 1-10 words beats a question opener for overall performance [S, ContentIn]. Use a number, a stake, a confession, or a contrarian line. Pick a template from `references/hooks-and-writing.md` and adapt it. No blank line above the cut, and don't open with "I'm excited to announce".
- **Body:**
  - One idea.
  - Short paragraphs of 1-2 sentences, with frequent line breaks. Posts with fewer than 3 line breaks did badly [S].
  - Specifics: names, numbers, what happened.
  - A list or numbered steps where it helps scanning. Bold or list formatting correlated with 8% vs 4% engagement [S].
- **Length:** 125-300 words is the best-performing band [S, ContentIn]. Long, high-value posts (1,000-2,000+ characters) also do well when every line earns its place [S, Taplio].
- **Closer:** one specific question the reader can answer from their own experience. Never "comment YES", "Agree?", or "type 🔥 if…", which are officially downranked bait.
- **Hashtags:** 0-3, relevant. They are a minor lever now.
- **Links:** keep them out of the body by default. Link posts get the lowest engagement, and studies estimate -18.8% to -26.5% reach [S]. The evidence is contested, and LinkedIn denies a deliberate penalty. Put the value in the post, then add the link in a comment or skip it. Say in the output that this rests on mixed evidence.
- **Tagging:** tag only people who are genuinely part of the story and likely to engage.
- **Voice:** first person, plain, specific. Cut these AI tells:
  - **The negation-contrast pattern in any form:** "It's not X, it's Y", "Not 11%. Eleven people.", "Not to a bigger salary. To a faster offer.", "X wasn't the expensive part. Y was.", "The failure wasn't in X. It was Y." This is the most common AI tell, so state the claim directly.
  - "In today's fast-paced world", "game-changer", "Let that sink in", "Here's the kicker", "unlock", "leverage", "navigate", "delve".
  - Emoji bullets on every line, and a closing moral that restates the post.
- **Final pass before scoring:** count the words in line 1 and cut it to 10 or fewer. Search each draft for `not`, `isn't`, `wasn't`, and `aren't`, and rewrite any contrast pair.

For carousels, see the carousel workflow below. For comments, see the comment workflow.

### 4. Score before presenting (pre-publish scorecard)
Score each draft 0-2 per line. Revise anything under 13/16.

| # | Check | 2 = | 0 = |
|---|---|---|---|
| 1 | Fold hook | Works alone in the first ~140 characters; specific | Throat-clearing; announcement opener |
| 2 | Dwell value | A reader learns or feels something by the end | Filler; restates the obvious |
| 3 | Specificity | Concrete numbers, names, scenes | Generic advice |
| 4 | Comment magnet | Specific question tied to the reader's experience | No question, or bait |
| 5 | Save/send value | Framework, steps, or data worth keeping or forwarding | Nothing reusable |
| 6 | Topic fit | Matches the author's profile expertise | Off-topic for the author |
| 7 | Readability | Short paragraphs, white space, 125-300 words (or justified) | Wall of text |
| 8 | Human voice | Sounds like the author; zero negation-contrast lines, no link in body, ≤3 hashtags | Any "not X, Y" line, AI phrasing, link dump, hashtag pile |

### 5. Output
Present 2-3 variants, ready to copy, labelled (e.g. **Story**, **Contrarian**, **Framework**). For each, include:
- the post text
- one line: the signals it targets
- the format and visual suggestion (image with face, carousel, or none) and link handling
- its scorecard total

End with a **Post-publish plan**:
- Stay around for the first hour or so to reply to every substantive comment with a real answer. About 40% of interactions happen on day one [S, Metricool], and threads with author replies go further.
- Spend the 15-30 minutes before and after posting leaving 3-5 thoughtful comments in the user's niche [B].
- Post again in 1-2 days, not the same day.
- Timing: studies conflict, so tell the user to post when their audience is at work and to test.

## Carousel (document post) workflow
1. **Use a 1080×1350 (4:5) PDF with 7-12 slides.** Engagement is best at 7-9 slides [S, SEOWorks], and decks of 11+ pages beat the author's average [S, LigoSocial]. Keep one aspect ratio throughout.
2. **Slide 1** promises a specific outcome ("The 5-step pricing audit that raised our ACV 32%"), uses the biggest text in the deck, and shows a swipe cue. A topic label isn't enough.
3. **Body slides** carry one idea each, about 25-40 words, with a headline and supporting line. Use a 7th-8th grade reading level, because readers give each slide 1-2 seconds.
4. **The second-to-last slide** is proof: a result, data, or quote.
5. **The last slide** has exactly one CTA: follow, comment, or save. Its headline and body hold only one request verb. Never combine save with follow, save with a question, or follow with a question. The comment question goes in the caption instead.
   - Good: headline "Save this for your next pricing review", body "All 7 mistakes on one page", with a recap and no second ask.
   - Bad: "Save this… Then follow me for more."
6. **The caption** is a normal post: fold hook, 2-4 lines on why the deck matters, and a question.

Output slide-by-slide: `Slide N — Headline / body text / visual note`, then the caption.

## Comment workflow (on other people's posts)
- **Purpose.** Comments put the user in front of other people's audiences. LinkedIn hides automated comments from "Most Relevant", so every comment must be hand-written and specific to the post.
- **Shape.** 15+ words, and usually 2-4 sentences, that add a specific experience, data point, nuance, or question. Never "Great post!" and never a pitch or a link.
- **Templates** (fill in real specifics):
  - "[Specific point from the post] is the part most people skip. When we [did X], [result]."
  - "Agree on [point]. The exception I've seen is [context], where [what happened]. Curious if you've hit that?"
  - "We tried this with [N] [clients/teams]: [outcome]. The surprise was [detail]."
- **Targets.** Recent posts in the user's niche from creators whose audience the user wants to reach, mixed with peers. Commenting early helps, since one vendor study found comments in the first 30 minutes got about 4x the impressions [B].

More in `references/comments-and-growth.md`.

## Myths not to follow
| Myth | Reality |
|---|---|
| "Never post more than once every 18-24h or you'll be penalized" | No primary or data source supports it. Practical spacing is still sensible. |
| "Editing a post in the first hour kills reach" | Only vendor claims, with no method. Fix typos if needed. |
| "Dwell time hurts you" | Outdated. Dwell has counted in your favor since 2024 [P]. |
| "360Brew ranks the feed" | The March 2026 engineering post describes a different generative recommender. 360Brew is a 2025 research model. |
| "Engagement pods boost reach" | Officially enforced against (Mar 2026). Groups were removed, and members risk restrictions. |
| "Comments are worth 5-7x likes" | Unsourced. About 2x is the only quantified estimate. |
| "Always put the link in the first comment, and you're safe" | Contested. The first-comment workaround may also lose reach. Lead with value either way. |

## References
- `references/algorithm.md`: 2026 architecture, dwell, profile signals, reach data, official enforcement, myths.
- `references/hooks-and-writing.md`: hook templates, post skeletons (SLAY, story-lesson, listicle, contrarian, framework, case study), formatting and length data.
- `references/formats.md`: document/carousel specs, video, polls, images, and the format data table.
- `references/comments-and-growth.md`: comment craft, reply strategy, frequency, timing, saves and sends.
- `references/profile.md`: headline formula, About, Featured, Follow button, topic consistency.
- `references/penalties.md`: what's enforced, what's contested, the AI-tell list.
- `references/sources.md`: all sources with dates and evidence tier.

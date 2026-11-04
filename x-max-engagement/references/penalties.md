# What hurts reach on X (2026)

## The math of negative signals
From the 2026 weights:
- One predicted **report** (-234) cancels about 355 predicted likes.
- One predicted **mute** (-58.8) cancels about 89 predicted likes.
- One predicted **not interested** (-52.3) cancels about 79 predicted likes.

These signals are predicted per viewer, so content that a slice of your audience finds annoying, off-topic, or hostile lowers its score for every viewer the model thinks is similar. This is why rage-bait can feel like it works (it gets replies) and still shrink the account over time.

## Confirmed or enforced (multi-source)
| Behavior | Status | Source |
|---|---|---|
| Visibility filtering for spam and policy labels | Built into the pipeline; separate from ranking | [P] repo README |
| Grox spam classifier runs on every new post | In code | [P] repo README |
| Apps that pay users to post or engage | Banned from the API, Jan 2026 | [S/news] |
| Programmatic replies outside @mentions and quotes | API-restricted, Feb 2026 | [S/news] |
| Reply bots | Mass ban waves, Apr 2026 | [S/news] |
| Original Content Rewards eligibility | Excludes copied, automated, Community-Noted, or misleading content | [S/news] |

## Announced but not confirmed shipped
- **Engagement-bait detection:** in March 2026, X's head of product said Grok is "very close" to identifying posts that solicit engagement ("like if", "RT if", "comment X") for downranking. Write as if it has shipped.

## Unproven (don't state these as fact)
- An "AI text penalty": no primary evidence. It is still worth avoiding AI tells, because people mute and scroll past slop, and that is penalized.
- Hashtag penalties: vendor data only.
- Tweet deletion "resetting" or "hurting" an account: no evidence.
- "Shadowbans": X's term is visibility filtering, and third-party shadowban checkers are unreliable.
- Link deboost: X says it was removed. Low link-post engagement comes from user behavior.

## AI-tell checklist (cut these from every draft)
- The negation-contrast pattern in every form: "It's not X. It's Y.", "This isn't about X — it's about Y.", "Not X. Y.", "X isn't the problem. Y is.", "X wasn't the hard part. Y was." Models produce this constantly, even after being told to avoid the literal phrase, so search for not/isn't/wasn't/aren't and rewrite each one as a direct claim.
- "Here's the thing:" / "Let that sink in." / "Read that again."
- "In today's fast-paced world" / "In an era of…"
- "Let's dive in" / "Buckle up" / "🧵👇" on every post
- "Game-changer", "unlock", "supercharge", "leverage", "navigate the landscape", "delve"
- Three-item rhythm everywhere ("fast, simple, and powerful")
- Em dashes in every sentence
- Emoji bullets (🚀 ✅ 💡) on every line
- Generic praise in replies
- Ending every post with the same CTA

Fix: use the user's actual numbers, names, and phrasing. Read the draft aloud, and if it sounds like a press release, rewrite it.

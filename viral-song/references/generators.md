# Translating the song to a generator

Find which input shape your generator takes, and use that adapter. Whatever the shape, the
clip unit comes first.

## (a) Style tags + tagged lyrics — ACE-Step, Suno, Udio, MiniMax, Mureka
- **Style/tags:** 6–10 comma-separated tags, in this order:
  1. genre
  2. BPM as a number (`118 bpm`)
  3. vocal (`female vocals, unison girl group`)
  4. energy (`high energy, punchy drums from the first bar`)
  5. 2–3 signature sounds
  6. `catchy chant hook`
  7. `loopable`
- **Lyrics:** use the generator's section tags.
  - ACE-Step uses lowercase tags: `[intro]`, `[verse]`, `[chorus]`, `[bridge]`, `[outro]`.
    Others accept `[Pre-Chorus]` and `[Post-Chorus]`.
  - To start on the hook, open with `[chorus]` (or `[intro]` holding the chant lines). ACE-Step
    has no time codes, so the order of the sections *is* the timing.
- **Words per second:** about 2–2.5 sung words per second. A 60 s song is about 90–130 words,
  and a 30 s song about 45–65, repeats included. Too many lyrics get rushed or cut off; too few leave instrumental gaps.
- **Seed:** if the generator takes one, fix it, and record it with the exact inputs.

## (b) One prompt only — Lyria, Stable Audio, Sonilo, ElevenLabs simple mode
Write one paragraph that covers, in this order:
1. genre and BPM
2. the vocal
3. "starts immediately on the hook: <hook words>"
4. the structure with seconds. Lyria reads section markers with time ranges, with the lyrics
   under each, for example:
   `[0:00-0:08] Hook: <lines>` then `[0:08-0:18] Verse: <lines>` and so on.
5. the energy
6. "ends on the hook, loops cleanly"
7. the total length ("a 30-second track")

Instrumental-only models can't sing lyrics. Say so, and deliver the beat with a chant cue sheet.

## (c) Composition plan — ElevenLabs music v2/v2.5 (`composition_plan.chunks`)
Each chunk has:
- `text`: a section name in brackets, then the lyric lines, for example `[Chorus]\nNach le na…`
- `duration_ms`: 3,000–120,000
- `positive_styles`: a list of style phrases

The first chunk's styles set the genre for the whole song, so put the full style there. A seed
works only in this mode. Make the chunk durations add up to the target length.

For a 60 s song:
1. hook, 8 s
2. verse, 14 s
3. chorus, 16 s
4. post-chorus chant, 10 s
5. hook, 12 s

For a 30 s song:
1. hook, 8 s
2. verse, 8 s
3. chorus, 8 s
4. hook, 6 s

## Short songs (under 90 s)
- Never spend more than 4 s before the first vocal.
- Leave out the bridge.
- The last section is the hook, ending on the beat.

---
name: impossible-site
description: End-to-end workflow for websites that feel impossible, built with AI agents and generated media - one signature idea per surface, generated stills and clips used as scrub sources or motion references (never as the final effect, never carrying text), scroll and pointer-scrubbed footage, a WebGL/shader pass, and a screenshot-and-fix loop. Use when the user wants an award-level, cinematic, "how did they do that" site or wants to upgrade an existing site to feel that way, even if they only say "make it amazing", "more wow", "cinematic", "scroll animation" or "feels impossible". Routes to motionsites-web-builder (heroes, prompts, technique code), the threejs-* skills (3D and shaders) and the fal MCP (media).
---

# Impossible-feeling websites

Sites feel impossible when three things line up: **one idea the visitor can't explain**, **real media that carries the mood**, and **someone who kept looking at the result until it was right**. Generated media is the raw material, not the trick. The trick is always code: scrubbing, compositing, shaders and continuity.

This workflow comes from the MotionSites Academy lessons (2026), with the gaps they leave (ffmpeg, smooth scroll, postprocessing, cost control, text) filled in. Code recipes are in `references/recipes.md`.

## Hard rules
1. **Generated media never carries text.** Video models garble paragraphs at every tier, and image models are unreliable past a word or two. Every prompt says *"no text, no letters, no logos, no UI, blank pages"*. Every readable word is DOM, or a real screenshot used as a texture and composited in. If a shot must show a page, use a first/last-frame model with **real screenshots as both end frames**, keep the motion between them fast or defocused, and crossfade the real screenshot in at rest.
2. **Generated clips are scrub sources or motion references, not autoplay wallpaper.** "Use generated video as a motion reference, not as the final effect." Scroll or the pointer drives them, or they show an agent what to build in WebGL.
3. **One heavy signature per viewport**, plus 2-4 quiet supports. If two effects fight for attention, cut one.
4. **Research models before generating, and let the user choose.** Leaderboards move monthly. Check Arena and Artificial Analysis (image-to-video), the fal catalog (`search_models`) and prices (`get_pricing`). Present 3-4 options with price per take, then generate.
5. **Cost ledger.** Run `estimate_cost` before every job, append each job to `docs/fal-ledger.md` (endpoint, seconds, $), and stop at the agreed cap.
6. **Never skip the look-and-fix loop.** The first version is never the best one.

## Workflow

### 1. Find the one idea
Write one sentence for what the visitor won't be able to explain. Good ones turn a metaphor into something you can touch. For example, "the page you're reading is a frame of film on a light table", "the product assembles itself as you scroll", or "the camera never cuts between sections". Then give each surface (gate or hero, section transitions, the main scene, the outro) its own signature, and keep continuity between them: the same camera, the same material, the same light.

### 2. Reference, then still
- Gather 3-5 references for mood, type and motion. Use them for direction, never copy them.
- Generate or edit the **key still** with a strong image model. Use direct edit instructions ("replace X with Y, make the background closer to image 2"), and use existing site assets as references.
- For 3D objects, generate **multi-view references** ("the same object from the front, back, left and right, plain background") and run image-to-3D. Export a GLB with 1K-2K textures.

### 3. Still to clip
- Image-to-video, 4-8 s, 16:9, text-free. Use first and last frame when the clip must start and end on known states.
- Write the camera move as one verb plus its speed: "slow dolly in", "lazy 30° orbit", "the strip lifts and curls".
- Take 1-2 takes per shot. Review a **contact sheet** before using a clip (recipe in references): look for garbled glyphs, morphing and flicker.
- Post-process with ffmpeg (exact commands in references):
  - An all-intra H.264 version, so seeking is smooth.
  - A ≤ 90-frame WebP sequence at 960 px (540 px on mobile).
  - A poster frame.

### 4. UI first, effects second
Build the layout, type and copy with the clip as a flat placeholder. The Academy prompt: *"Match this as closely as possible. Just build the UI for now. We will build the 3D interaction as a second step."* If the project has a DESIGN.md, it wins.

### 5. Wire the driver
- **Scroll-scrubbed footage:** use a canvas frame cache with lerp 0.12. Fall back to seeking the video, with a 0.04 s threshold. Cap DPR at 2. Leave a spacer (about 80vh) so the scrub has room. Never autoplay.
- **Pointer-scrubbed footage:** scale the pointer delta by `/ innerWidth * 0.8 * duration`, clamp it, and queue seeks through `onSeeked`. This is desktop only; on touch it becomes drag or a still.
- **Smooth scroll:** Lenis driven from GSAP's ticker, with `lagSmoothing(0)` and `ScrollTrigger.update` on scroll.

### 6. The 3D and shader pass
Do this in a separate pass with a dedicated prompt, for example *"Turn this into an actual 3D scene: rebuild the background with WebGL shaders, real lighting and depth."* Always:
- Apply **tone mapping** (ACES or AgX) and use the sRGB output colour space. Without them, models render dark and muddy.
- Postprocessing: at most 3-4 passes. Bloom or halation, grain, vignette, and one signature pass (refraction, distortion, chromatic aberration).
- Quality tiers: full, lite (no postprocessing, lower DPR) and static (poster images). Choose the tier from GPU, memory and `prefers-reduced-motion`.
- Use the `threejs-*` skills and Context7 for current APIs. Inspect the live scene with threejs-devtools.

### 7. Refine with small, single-change prompts
One change per prompt: "Reduce the headline size by 15%." "Keep the centre of this section empty so the animation stays visible." "Keep the current layout, typography, colours, animations and responsive behaviour; only change X."

### 8. Look and fix (mandatory)
- Shoot desktop (1440) and mobile (390) at every key scroll position with agent-browser in a private session.
- Score with `motionsites-web-builder/references/review.md`. Fix the three weakest areas, then shoot again. Stop at an average of 8+ with nothing under 7, or after 3 rounds.
- Then check:
  - Frame rate: aim for 60 fps on desktop, using threejs-devtools `perf_monitor`.
  - `prefers-reduced-motion`.
  - No horizontal scroll at 390.
  - Text is never over an unprotected bright area.
  - Contact sheets show no glyphs.

### 9. Ship
Deploy a preview first, then verify on the live URL: fonts, muted autoplay where it is used, scrub mapping, and the mobile tier. Deploy to production only with approval.

## Where things live
- Hero prompts, the technique code library (58 recipes) and the review rubric: `motionsites-web-builder`.
- 3D, shaders, postprocessing and performance: the `threejs-*` skills, starting from `threejs-game-director` for scenes.
- Media generation: the fal MCP (`search_models`, `get_pricing`, `estimate_cost`, `submit_job`).
- Design taste checks: `impeccable` critique, and the AI-slop severity rules in the global AGENTS.md.

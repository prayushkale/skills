# Recipes

Tested patterns behind the workflow. Before pasting a library API, check it against current docs (Context7).

## ffmpeg: prepare a generated clip

```bash
# 1. Contact sheet: one frame per second, 4 across. Review it for glyphs, morphing and flicker.
ffmpeg -i in.mp4 -vf "fps=1,scale=480:-1,tile=4x2" -frames:v 1 sheet.jpg

# 2. All-intra H.264 for smooth seeking (every frame is a keyframe), muted, web-ready.
ffmpeg -i in.mp4 -an -c:v libx264 -preset slow -crf 20 -g 1 -keyint_min 1 \
  -pix_fmt yuv420p -movflags +faststart -vf "scale=1920:-2" scrub.mp4

# 3. Frame sequence for a canvas cache: ≤ 90 frames, 960 px wide (540 px for mobile).
N=90; D=$(ffprobe -v error -show_entries format=duration -of csv=p=0 in.mp4)
ffmpeg -i in.mp4 -vf "fps=$N/$D,scale=960:-2" -c:v libwebp -quality 72 frames/f_%03d.webp

# 4. Poster frame (the first frame, or the one the static tier shows).
ffmpeg -ss 0 -i in.mp4 -frames:v 1 -vf "scale=1920:-2" -c:v libwebp -quality 80 poster.webp

# 5. Boomerang loop for a clip that doesn't loop on its own.
ffmpeg -i in.mp4 -filter_complex "[0:v]reverse[r];[0:v][r]concat=n=2:v=1[v]" -map "[v]" -an loop.mp4
```

## Scroll-scrubbed frame cache (vanilla TS)

```ts
// progress 0..1 → frame index. Lerp 0.12. ImageBitmap cache. DPR ≤ 2.
export function scrubber(canvas: HTMLCanvasElement, urls: string[], getProgress: () => number) {
  const ctx = canvas.getContext('2d')!;
  const frames: (ImageBitmap | undefined)[] = [];
  let smoothed = 0, raf = 0, last = -1;
  // Load in order, low frames first, so the start works immediately.
  urls.forEach((u, i) =>
    fetch(u).then(r => r.blob()).then(createImageBitmap).then(b => { frames[i] = b; }));
  const fit = () => {
    const dpr = Math.min(devicePixelRatio, 2);
    canvas.width = canvas.clientWidth * dpr; canvas.height = canvas.clientHeight * dpr;
    last = -1;
  };
  const draw = (i: number) => {
    // Walk back to the nearest loaded frame.
    let j = i; while (j > 0 && !frames[j]) j--;
    const f = frames[j]; if (!f || j === last) return; last = j;
    const s = Math.max(canvas.width / f.width, canvas.height / f.height); // cover
    const w = f.width * s, h = f.height * s;
    ctx.drawImage(f, (canvas.width - w) / 2, (canvas.height - h) / 2, w, h);
  };
  const tick = () => {
    smoothed += (getProgress() - smoothed) * 0.12;
    draw(Math.round(smoothed * (urls.length - 1)));
    raf = requestAnimationFrame(tick);
  };
  fit(); addEventListener('resize', fit); tick();
  return () => { cancelAnimationFrame(raf); removeEventListener('resize', fit); frames.forEach(f => f?.close()); };
}
```

Video-seek fallback, for when frames aren't cached yet: `if (Math.abs(target - v.currentTime) > 0.04) v.currentTime = smoothed * (v.duration - 0.05)`.

## Pointer-scrubbed video (desktop)

```ts
const SENS = 0.8; let prevX: number | null = null, target = 0, seeking = false;
addEventListener('pointermove', e => {
  if (prevX !== null) {
    const d = (e.clientX - prevX) / innerWidth * SENS * video.duration;
    target = Math.min(video.duration, Math.max(0, target + d));
    if (!seeking) { seeking = true; video.currentTime = target; }
  }
  prevX = e.clientX;
});
video.addEventListener('seeked', () => {
  seeking = false;
  if (Math.abs(video.currentTime - target) > 0.03) { seeking = true; video.currentTime = target; }
});
```

Use the all-intra encode (`-g 1`), otherwise seeks stutter.

## Lenis + GSAP ScrollTrigger

```ts
import Lenis from 'lenis';
import gsap from 'gsap'; import { ScrollTrigger } from 'gsap/ScrollTrigger';
gsap.registerPlugin(ScrollTrigger);
const lenis = new Lenis({ autoRaf: false });
lenis.on('scroll', ScrollTrigger.update);
gsap.ticker.add(t => lenis.raf(t * 1000));
gsap.ticker.lagSmoothing(0);
// Reduced motion: don't construct Lenis at all.
```

Scroll velocity for shaders: `lenis.on('scroll', ({ velocity }) => uniforms.uVel.value = velocity)`.

## Three.js render setup that doesn't look muddy

```ts
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping; // or AgXToneMapping
renderer.toneMappingExposure = 1.0;
renderer.setPixelRatio(Math.min(devicePixelRatio, tier === 'full' ? 2 : 1.25));
```

## Shader moves that read as "impossible"
- **Refractive lens or loupe:** offset UVs by a normal from a spherical height `sqrt(1 - r²)`, sample R, G and B at slightly different offsets (chromatic aberration), and add a Fresnel rim.
- **Develop or reveal mask:** mix a negative image (`1 - col`, warm-tinted) with the positive using `smoothstep` on the distance from the cursor plus noise. Time-integrate the mask so revealed areas stay developed.
- **Halation:** threshold the highlights, blur them, tint red-orange (`vec3(1., .35, .15)`) and add back. This is the film look, not generic bloom.
- **Gate weave and jitter:** offset the whole frame by `noise(t * 8.) * 0.002 * uVel`, and add a vertical sprocket flicker.
- **Velocity bend:** a vertex shader with `pos.z += sin(uv.x * PI) * uVel * k`, so the material reacts to how hard you scroll.
- **Continuity:** animate the camera, never cut. Map DOM rects to world space so a DOM element can hand off to a WebGL plane at the same pixel position (screen-space matching).

## Generation prompt skeleton (stills and clips)

```
[subject + material], [camera: lens, angle, one move + speed], [light: source, colour temperature, falloff],
[surface detail], [mood in 3 words]. Photoreal, shallow depth of field.
No text, no letters, no numbers, no logos, no UI, blank pages.
```

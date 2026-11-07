# Video models for driver-led dance (fal.ai, tested Nov 2026)

One data point per row. Re-test before relying on it.

| Model | Result | Notes |
|---|---|---|
| Seedance 2.5 reference-to-video (`bytedance/seedance-2.5/us/reference-to-video`) | **Winner.** Very expressive faces; on a full 30 s run it followed the driver's camera cuts bar by bar | Hair colour drifted (blonde-to-lilac became all lilac). Ignored cuts in a 5 s run, so test long |
| H3 Max Recast | Truest to the character image | Arm heart about 0.75 s late; costs $0.30/s at 768p, $0.45/s at 1080p |
| Kling v3 Motion Control | Neutral faces | Copies the *image's* aspect ratio (3:4 in, portrait out) |
| Wan | Removed from fal | |

## Seedance limits and billing
- Output 4–30 s. Each reference video 1.8–30.2 s, combined at most 30.2 s, 24–60 fps. Image refs are free.
- `tokens = out_h × out_w × (input_video_s + output_s) × 24 / 1024`, times 0.6 when a video
  reference is given. About $0.0214 per 1K tokens at 480p/720p. A 30 s 720p video-to-video cost
  about $16.6, roughly twice a 30 s text-to-video, because input seconds are billed.
- Read the model page for any "per unit" price; fal's pricing API can list a unit without defining it.

## Safety filter
A short dress plus dance render got a 422 "Output video has sensitive content". The same image
edited to a knee-length skirt and opaque tights, with a plain prompt, passed. The exact trigger is
unknown. Report the reason to the user; don't resubmit unchanged.

## Backdrop
A prompt for "plain white studio" returned light grey with a visible cyc-wall corner. Match the
driver's background to the final graphics backdrop, or plan the whitening pass.

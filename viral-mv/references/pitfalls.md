# Pitfalls

## Whiten a grey AI-video backdrop without regenerating
Gentle levels: white point = 80th percentile of the border luma, **one value for the whole clip**
(no per-frame flicker). Then a luma/saturation key toward white (luma 170 to 205, saturation
0.05 to 0.11) so skin, hair and bows are untouched. Border luma went from 185–194 to 233–248.
A faint grey in the darkest corners can be accepted. Show a before/after grid and crops, and let
the user pick.

## Mureka (via fal)
- $0.15 per song with lyrics; `duration` takes only 120–300 s, so generate the full song and cut it.
- It skips comma-separated "Dot, dot," at the start of a line but sings "Dot! Dot!" on its own line.
- It ignores "no instrumental breaks"; cut whole bars out of vocal-free gaps instead.
- Its `lyrics_sections` word timestamps are a good first draft for the tap editor.

## three-vrm spring bones
`reset()` uses each joint's *cached* parent matrix, so a per-frame reset leaks the previous frame.
Simulate continuously from t = 0 on a fixed 1/60 s grid and restart only when going backwards.
That keeps frame-exact renders deterministic and the hair natural.

## fal MCP
- Always pass a `submission_key`. `run_model` can return `pending` with no request ID; recover it
  with `get_submission`.
- Run `check_job` in a response of its own; alongside other calls an auto-mode classifier
  sometimes refuses it.
- Image `image_size` for Seedream takes `{width, height}` (1536×2048 for 3:4).

## Tooling
- Some ffmpeg builds have no `drawtext`. Render text with PIL to PNG and overlay it.
- Log long exports to a file; piping through `tail` hid a crash at frame ~626.
- Check what you do not commit: media, driver video, models, `node_modules`.

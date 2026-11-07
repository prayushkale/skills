# Graphics rules

Text and graphics never go through a video model. Render them from the same time-driven studio and
composite afterwards (overlay mode: alpha, character hidden, face position still projected).

1. **Nothing drawn over the face.** Test every item against the projected face circle and move it
   (`hitsCircle` / `avoidFace`). Band wipes and a see-through heart over the body are fine.
2. **No text outside the frame.**
3. **A filled shape never uses the backdrop colour behind it.** In overlay mode white and cream
   fills fall back to a third palette colour (butter).
4. **No full-frame cards.** The character stays visible.
5. Cuts happen every bar; pulse on beat 3; punch-ins on hits.
6. Check the final composite at 2 fps by contact sheet for rule 1 before showing the user.

Order the user's feedback arrived in (a good default build order): more groove, a cut every bar,
tighter framing, diagonal stripes and split backdrops, nothing over the face, colours that differ
from the backdrop, a two-thumb typing gesture with no phone, an arm heart with the elbows wide.

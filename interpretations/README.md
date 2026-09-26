# interpretations/

One markdown file per image, named after the CSV stem — `image1.md` for
`data/image1.csv`. The contents are pasted verbatim into that image's section of
the site, after the `u1` / `z1` plots.

Each file covers the two things that cannot be computed:

1. **What `u1` and `z1` actually show for this image** — `u1` is the dominant
   weighting across pixel columns, `z1` is how strongly each row expresses that
   profile. Written after looking at the rendered plots, referring to the
   measured features printed above them.
2. **The value of `k` that is good enough, and why** — tied to where the error
   curve flattens and to the point in the k = 1…10 grid where the picture stops
   visibly improving. A judgment, not a formula. Record the same number in
   `config/k_choices.R` so it is marked on the error curve.

If a file is missing, the site renders a visible "not written yet" callout in
its place rather than silently omitting the section.

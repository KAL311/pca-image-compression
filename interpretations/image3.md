### Reading u1 and z1

This one is an actual photograph, a puppy lying against a sleeve and a light
bedspread, so unlike the first two images the leading component is describing
real picture content.

`u1` stays positive across all 345 columns but swings by about a factor of four,
from 0.0201 up to 0.0778. The shape is what's interesting. It's low and fairly
flat, around 0.020 to 0.030, across columns 1 to 75, then climbs steeply and
stays high through the middle of the frame: a broad plateau near 0.065 around
columns 90 to 130, a peak of 0.075 at column 162, a dip to 0.048 near column
213, its maximum of 0.0778 at column 263, and then a slide back down to 0.029 at
the right edge. Line those ranges up against the original and they make sense.
The quiet left-hand region is the evenly lit bedding and sleeve; the raised
middle and right is where the dog actually is.

Worth remembering that the pixel values here are roughly zero-centred, running
from -2.20 to 1.52, so $X'X$ is measuring energy rather than brightness. That
means `u1` reads as a contrast profile. It's large exactly where a column
contains strong departures from mid-grey, which is the dark fur and the white
chest and paw, and small where a column is uniformly mid-toned.

`z1` is much easier to read. It's essentially row brightness, correlating 0.9963
with the row means. It starts at 7, rises to about 12 by row 30, crosses zero
near row 62, drops to its minimum of -28 somewhere around rows 100 to 130,
climbs back through zero near row 215, wobbles for a while, then rises steadily
to 17 by the bottom of the frame. That's a fair description of the photograph
read top to bottom: light background up top, the dark mass of the dog filling
the band from roughly row 62 to row 215, and the bright bedspread across the
bottom third. The longest unbroken run of negative `z1` is rows 62 to 215, 154
rows, which is the dog.

So the rank-1 image is a horizontal three-band brightness pattern, light then
dark then light, modulated by a fixed left-to-right contrast profile. That's
precisely what the k = 1 panel looks like: no shapes at all, just banding. The
dog's outline doesn't show up until k = 3 or 4, and the eye and muzzle not until
around k = 8.

### How far would I go with k?

I'd stop at k = 40.

There's no sharp elbow in this error curve. It's a smooth convex decay, which is
what you get from a natural photograph, because real images spread their energy
across many scales instead of concentrating it in a few directions. So the
decision has to come from looking at the pictures, with the curve as a check.

Working through the panels: k = 10, at a relative error of 0.220, is clearly a
dog but soft, with obvious vertical banding and a face you can't resolve. k = 20
at 0.138 has a readable eye, but the fur is smeared and the bedding is visibly
striped. k = 30 at 0.106 is the first panel I'd call a good likeness, with the
eye, muzzle, ear boundary and the fold in the bedspread all in the right place.
k = 40 at 0.088 tidies up what k = 30 leaves behind: the residual banding in the
bedding mostly goes away and fur texture starts to be there rather than merely
implied. Beyond that the returns collapse. k = 60 at 0.068 is better on fine
texture, but I had to put the two side by side to see it, and it isn't a
difference that would change what anyone could tell you about the photo.

The storage numbers point the same way. With $n = 376$ and $p = 345$, storage is
$721k / 129{,}720$, so k = 20 costs 11.1% of the raw image, k = 30 costs 16.7%,
k = 40 costs 22.2% and k = 60 costs 33.4%. Going from 30 to 40 buys a visible
improvement for 5.5 points of storage. Going from 40 to 60 costs another 11
points for something I can barely make out. That asymmetry is where I'd draw the
line.

Break-even, where the compressed form stops being smaller than the original,
lands at $k = np/(n+p) = 180$, so k = 40 leaves plenty of headroom. This image
compresses genuinely well: a 78% cut in stored numbers for an 8.8% Frobenius
error and a picture that still reads as the same photograph.

One caveat that's visible in the panels and worth saying out loud. Scattered
pure-white speckles appear in the dark fur from k = 4 onward and are still there
at k = 60. They aren't a plotting artefact. They're places where the
reconstruction overshoots above the original's brightest pixel, and since every
panel is drawn on the original's grey scale they clip to white. They shrink as
k grows, and they're a reminder that a rank-k approximation isn't constrained to
stay inside the original range of values.

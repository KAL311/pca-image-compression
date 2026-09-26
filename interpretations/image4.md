### Reading u1 and z1

This is an overhead view: a diagonal track running from the upper right down
toward the lower left across textured ground, with a bright elongated object
sitting on it and a larger bright rectangle carrying dark markings lower in the
frame.

`u1` has the most structure of the four, and it's the only one that changes
sign. It opens near 0.03 for columns 1 to 15, falls through zero around column
18, bottoms out at -0.045 across columns 33 to 40, comes back to zero near
column 55, then rises very steeply to 0.155 by column 64 and on to its maximum
of 0.218 at column 85, five times the size of anything in the left half, before
dropping just as sharply back to 0.03 by column 96 and drifting near 0.045 out
to the right edge. Only 68.9% of its entries are positive.

A signed eigenvector is doing something different from the first three images.
It's encoding a contrast between two bands of columns rather than a profile they
share. The narrow high-magnitude band at columns 60 to 95 is where both bright
objects sit, and the negative lobe at columns 33 to 40 is the darker ground off
to their left. The first component is effectively saying that these columns are
bright when those ones are dark. That fits with the correlation between `u1` and
the column means being 0.026, which is to say nothing at all. Unlike image3,
this leading component isn't a brightness profile.

`z1` is spiky rather than smooth. It hovers between -8 and 4 through most of the
frame, with a sharp isolated peak of 10.5 at row 61 and a much bigger plateau
reaching 22 across rows 140 to 155, then falls to -10 by row 210. Those two
positive excursions are the two bright objects, the elongated one on the track
near the top and the large marked rectangle below it. 61% of rows have a
negative `z1`, so the default state of a row is no bright object, and `z1` only
fires where there is one.

Read together, the rank-1 approximation is a bright horizontal bar at the rows
and columns where the largest bright object lives, which is exactly what the
k = 1 panel gives you: the rectangle shows up as a crude glowing strip before
any terrain is visible at all.

### How far would I go with k?

I'd stop at k = 30, and here it's the storage cost rather than the picture that
decides it.

This is the hardest of the four to compress, and the eigenvalues explain why.
The first component holds only 40.5% of $\operatorname{trace}(X'X)$, against
61.8% for image3 and over 80% for the two synthetic matrices. The content is
mostly high-frequency ground texture, which isn't low-rank in any direction. It
takes 10 components to reach 93.9% and 20 to reach 98.2%.

Visually the improvement is steady rather than sudden. k = 10, at a relative
error of 0.246, gives you the bright objects and a vague sense of light and
dark. k = 20 at 0.133 resolves them properly, but the ground is a smooth wash.
k = 30 at 0.091 is where the diagonal track becomes a continuous, unmistakable
feature and the small bright objects separate from one another. k = 40 at 0.068
brings the grainy ground texture back, and k = 60 at 0.037 is very close to the
original.

If storage were free I'd take 40 or 60. It isn't. With $n = 213$ and $p = 119$
this is a small, nearly square matrix, and $(n+p)k / np = 332k / 25{,}347$ grows
fast: k = 20 costs 26.2% of the raw image, k = 30 costs 39.3%, k = 40 costs
52.4% and k = 60 costs 78.6%. Break-even, where the compressed form stops being
smaller than just storing the pixels, arrives at only $k = np/(n+p) = 76$.
There's far less room to work with here than in image3, where break-even sat
at 180.

So k = 40 would mean paying half the original storage to get texture back, and
k = 60 would mean paying nearly four fifths, which is close to pointless. k = 30
keeps every feature that carries information, the track, both bright objects and
the broad light and dark regions, for 39% of the storage and a 9.1% Frobenius
error. That's the last point on this curve where compressing is still clearly
worth doing, which is why I wouldn't push higher on this image even though I
happily would on image3.

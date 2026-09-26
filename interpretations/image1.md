### Reading u1 and z1

`u1` isn't really a profile. It's a spike. For 99 of the 100 pixel columns it
sits within rounding distance of zero, hugging the axis somewhere between
-0.008 and 0.008, and then at column 78 it jumps to 0.9989. The next largest
entry anywhere in the vector is 0.0079, smaller by a factor of 126. When a unit
eigenvector puts essentially all of its length on a single coordinate, it's
telling you the dominant column profile is that one column and nothing else.

`z1` says the same thing from the other side. It's a flat band of noise centred
on 19.95 with a standard deviation of only 0.96, drifting between about 17 and
22.6 with no trend and no visible structure from the first row to the
thousandth. Since `z1` measures how strongly each row expresses `u1`, a constant
`z1` means every row expresses it equally. Column 78 is uniformly bright the
whole way down, and the small wobble in `z1` is just that column's own noise.

So the rank-1 approximation is a single vertical stripe, and that really is all
the structure this image has. The column means confirm it: column 78 averages
19.93 while every other column averages somewhere between -0.16 and 0.00, and
all 100 columns have a standard deviation near 1. This is standard normal noise
with a constant of about 20 added to one column. The k = 1 panel shows that
stripe, and k = 2 through 10 are indistinguishable from it, because after the
first component there's nothing left but noise to fit.

### How far would I go with k?

k = 1, and I'd argue it's the only defensible answer here. Not because the
reconstruction is good, but because nothing better is on offer at any price.

The error curve makes the case. Error(1) is already down to 0.445 of
$\lVert X \rVert_F$, so that one stripe accounts for 55% of the image's total
magnitude in a single step. After that the curve is a straight line. It sheds
roughly 0.86% of its remaining height per component from k = 1 to k = 6, drifts
down more or less linearly through the middle, and only falls off a cliff in the
last handful of components. There's no elbow anywhere, no point where it flattens
out and tells you to stop. A straight error curve is what isotropic noise looks
like: every remaining direction holds about the same energy, so no place to cut
is better than any other.

The eigenvalues put it more bluntly. $\lambda_1 = 3.99 \times 10^5$ against
$\lambda_2 = 1.68 \times 10^3$, a 238-fold gap, and then
$\lambda_2$ through $\lambda_6$ come in at 1680, 1650, 1610, 1590 and 1590,
which is to say they're all the same number. One real component, ninety-nine
noise components.

Two more reasons to stay put. Visually, the k = 15 through k = 60 panels look
like k = 1, because you can't see noise being reconstructed at this scale, so
extra components buy nothing you can perceive. And the storage arithmetic caps
the whole exercise anyway: $(n+p)k / np = 1100k / 100{,}000$ crosses 100% at
k = 91, meaning from there on the compressed form is bigger than the image it
replaces. Even at the very top of the usable range the error has only fallen
from 0.445 to about 0.12, which is nowhere near faithful.

k = 1 costs 1.1% of the original storage and captures everything that's
actually there. Everything after it is paying full freight to memorise noise.

### Reading u1 and z1

`u1` is a straight line. It climbs from 0.0006 at column 1 to 0.1722 at column
100 with no curvature I can see, and regressing it on the column index gives an
$R^2$ of 0.99992. Every entry is positive. The dominant column profile is just a
ramp from left to right: whatever a row contains, it contains a lot more of it
at the right edge than at the left.

`z1` is the opposite in character. It's row-to-row noise, swinging between
-4034 and 3570 with a standard deviation of 1188 and a lag-1 autocorrelation of
0.02, meaning one row tells you nothing at all about the next. It takes both
signs freely.

Together those two explain the banding you can see in the original. Every row is
the same ramp, scaled by its own random number. Rows with a positive `z1` run
dark on the left to bright on the right, rows with a negative `z1` run the other
way, and rows near zero come out flat grey. Stack a thousand of those in random
order and you get exactly the dense horizontal striping the image shows. The
correlation between `z1` and the row means is 1.0000, so `z1` is nothing more
than each row's overall level.

This image is an outer product with a bit of dressing: a random row vector times
a linear column ramp.

### How far would I go with k?

k = 2, and for once this isn't really a judgment call. It's a fact about the
matrix.

The rank of $X$ is 2. The eigenvalues go $\lambda_1 = 1.41 \times 10^9$,
$\lambda_2 = 4.2$, and then $\lambda_3 = 1.09 \times 10^{-7}$, which is a drop
of eight orders of magnitude into what is plainly floating-point dust. Error(2)
comes out at $3.5 \times 10^{-9}$ against $\lVert X \rVert_F = 37{,}539$, so two
components reproduce the image exactly as far as double precision can tell. The
error curve is flat on the floor from k = 2 onward and the k = 3 through 10
panels aren't approximations of anything, they're the original.

The question worth asking is whether k = 1 would do, and visually it would.
Error(1) is 2.05 in absolute terms, which is 0.0055% of $\lVert X \rVert_F$, and
the k = 1 panel is indistinguishable from the original by eye. That second
component is carrying a correction small enough that nobody would miss it.

I'd still take k = 2, because exactness is nearly free. k = 1 stores 1,100
numbers, or 1.1% of the raw 100,000; k = 2 stores 2,200, or 2.2%. For an extra
1,100 numbers, about a hundredth of the original image, the approximation stops
being an approximation at all. Choosing the lossy version to save 1.1% strikes
me as a bad trade.

One thing worth noticing next to image1. Both matrices are 1000 by 100, and in
both the first component dominates the trace. The difference is what's left
behind: here the remaining 98 directions are genuinely empty, there they were
full of noise. It's the size of the gap between $\lambda_1$ and $\lambda_2$ that
separates the two cases, not the share the first component holds.


source(file.path("R", "pca_compress.R"))

pass <- 0L; fail <- 0L
check <- function(label, ok) {
  if (isTRUE(ok)) { pass <<- pass + 1L; cat("  PASS  ", label, "\n") }
  else            { fail <<- fail + 1L; cat("  FAIL  ", label, "\n") }
}

set.seed(311)
n <- 60; p <- 25
X <- matrix(runif(n * p, 0, 255), n, p)
d <- pca_decomp(X)

cat("\n-- Verification 1: rank p reproduces X exactly ------------------------\n")
full <- pca_compress(X, k = p, decomp = d)
cat(sprintf("   Error(p = %d) = %.3e   (scale ||X||_F = %.2f)\n",
            p, full$error, norm(X, type = "F")))
check("Error(p) is ~0 relative to ||X||_F",
      full$error / norm(X, type = "F") < 1e-12)

cat("\n-- Verification 2: Error(k)^2 == sum(lambda[(k+1):p]) -----------------\n")
err <- pca_error_curve(X, decomp = d)
tail_sum <- rev(cumsum(rev(d$lambda)))
theory   <- c(sqrt(tail_sum[-1]), 0)
cat(sprintf("   %-4s %-16s %-16s %s\n", "k", "Error(k)", "sqrt(tail lambda)", "abs diff"))
for (k in c(1, 2, 3, 5, 10, p - 1, p)) {
  cat(sprintf("   %-4d %-16.8f %-16.8f %.3e\n",
              k, err[k], theory[k], abs(err[k] - theory[k])))
}
check("max |Error(k) - sqrt(tail lambda)| is at numerical tolerance",
      max(abs(err - theory)) < 1e-8 * max(1, norm(X, type = "F")))

cat("\n-- Verification 3: Error(k) is monotonically non-increasing -----------\n")
dif <- diff(err)
cat(sprintf("   largest increase between consecutive k: %.3e\n", max(dif)))
check("no k where Error(k+1) > Error(k)", all(dif <= 1e-9))

cat("\n-- pca_compress(k) agrees with the incremental curve ------------------\n")
spot <- sapply(c(1, 4, 9, 17, p), function(k) pca_compress(X, k, decomp = d)$error)
check("vectorised Zk %*% t(Uk) matches rank-1 accumulation",
      max(abs(spot - err[c(1, 4, 9, 17, p)])) < 1e-8)

cat("\n-- U is orthonormal, X = Z U' -----------------------------------------\n")
check("U'U = I", max(abs(crossprod(d$U) - diag(p))) < 1e-10)
check("Z U' = X", max(abs(d$Z %*% t(d$U) - X)) < 1e-9)

cat("\n-- Input validation ---------------------------------------------------\n")
errs <- function(expr) inherits(try(expr, silent = TRUE), "try-error")
check("rejects k = 0",            errs(pca_compress(X, 0)))
check("rejects k = p + 1",        errs(pca_compress(X, p + 1)))
check("rejects k = 2.5",          errs(pca_compress(X, 2.5)))
check("rejects k = NA",           errs(pca_compress(X, NA)))
check("rejects data.frame input", errs(pca_compress(as.data.frame(X), 2)))
check("rejects character matrix", errs(pca_compress(matrix("a", 3, 3), 2)))
check("rejects NA pixels",        errs(pca_compress(replace(X, 1, NA), 2)))
check("accepts k = 1",            !errs(pca_compress(X, 1)))

cat("\n-- Non-square both ways (n < p and n > p) ----------------------------\n")
for (dims in list(c(12, 30), c(30, 12))) {
  A  <- matrix(rnorm(prod(dims)), dims[1], dims[2])
  ee <- pca_compress(A, k = ncol(A))$error / norm(A, type = "F")
  check(sprintf("n=%d p=%d : Error(p) ~ 0 (rel %.1e)", dims[1], dims[2], ee),
        ee < 1e-12)
}

cat("\n-- Compression ratio --------------------------------------------------\n")
cr <- pca_compression_ratio(100, 80, 10)
check("(n+p)k / np computed correctly",
      cr$stored == 1800 && cr$original == 8000 && abs(cr$ratio - 0.225) < 1e-12)

cat(sprintf("\n=====  %d passed, %d failed  =====\n", pass, fail))
if (fail > 0L) quit(status = 1L)

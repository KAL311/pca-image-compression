pca_decomp <- function(x) {
  if (!is.matrix(x) || !is.numeric(x)) {
    stop("`x` must be a numeric matrix.", call. = FALSE)
  }
  if (anyNA(x)) {
    stop("`x` contains NA/NaN; eigen() cannot handle missing pixels.", call. = FALSE)
  }

  V <- crossprod(x)
  e <- eigen(V, symmetric = TRUE)
  lambda <- pmax(e$values, 0)

  list(U = e$vectors, lambda = lambda, Z = x %*% e$vectors)
}


pca_compress <- function(x, k, decomp = NULL) {

  if (!is.matrix(x) || !is.numeric(x)) {
    stop("`x` must be a numeric matrix.", call. = FALSE)
  }
  p <- ncol(x)
  if (p == 0L || nrow(x) == 0L) {
    stop("`x` must have at least one row and one column.", call. = FALSE)
  }
  if (!is.numeric(k) || length(k) != 1L || is.na(k)) {
    stop("`k` must be a single non-missing number.", call. = FALSE)
  }
  if (k != as.integer(k)) {
    stop("`k` must be a whole number.", call. = FALSE)
  }
  k <- as.integer(k)
  if (k < 1L || k > p) {
    stop(sprintf("`k` must be between 1 and ncol(x) = %d; got %d.", p, k),
         call. = FALSE)
  }

  if (is.null(decomp)) {
    decomp <- pca_decomp(x)
  } else if (!all(c("U", "lambda", "Z") %in% names(decomp)) ||
             ncol(decomp$U) != p || nrow(decomp$Z) != nrow(x)) {
    stop("`decomp` does not match `x`; pass pca_decomp(x) or leave it NULL.",
         call. = FALSE)
  }

  Zk <- decomp$Z[, seq_len(k), drop = FALSE]
  Uk <- decomp$U[, seq_len(k), drop = FALSE]
  xk <- Zk %*% t(Uk)

  list(
    approximation = xk,
    error         = norm(x - xk, type = "F"),
    k             = k,
    decomp        = decomp
  )
}


pca_error_curve <- function(x, decomp = NULL) {
  if (is.null(decomp)) decomp <- pca_decomp(x)
  p <- ncol(x)

  resid <- x
  err   <- numeric(p)
  for (k in seq_len(p)) {
    resid  <- resid - tcrossprod(decomp$Z[, k], decomp$U[, k])
    err[k] <- norm(resid, type = "F")
  }
  err
}


pca_compression_ratio <- function(n, p, k) {
  stored   <- (n + p) * k
  original <- n * p
  list(stored   = stored,
       original = original,
       ratio    = stored / original,
       saving   = 1 - stored / original)
}

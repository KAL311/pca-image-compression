show_image <- function(m, main = "", zlim = range(m, finite = TRUE),
                       cex_main = 1) {
  n <- nrow(m); p <- ncol(m)
  op <- par(mar = c(0.4, 0.4, 1.8, 0.4))
  on.exit(par(op), add = TRUE)
  image(x = seq_len(p), y = seq_len(n),
        z = t(m)[, n:1, drop = FALSE],
        zlim = zlim,
        col  = grey(seq(0, 1, length.out = 256)),
        asp  = 1, axes = FALSE, xlab = "", ylab = "",
        main = main, cex.main = cex_main, useRaster = TRUE)
  box(col = "grey70")
  invisible(NULL)
}


plot_error_curve <- function(err, mark = NULL, main = "Frobenius error vs k") {
  p <- length(err)
  op <- par(mar = c(4.2, 4.4, 2.6, 1))
  on.exit(par(op), add = TRUE)
  plot(seq_len(p), err, type = "l", lwd = 2, col = "#1f5c99",
       xlab = "k (number of principal components)",
       ylab = expression(paste("||X - X"[(k)], "||"[F])),
       main = main)
  if (!is.null(mark)) {
    abline(v = mark, lty = 3, col = "#c0392b")
    axis(3, at = mark, labels = mark, tick = FALSE, line = -0.8,
         col.axis = "#c0392b", cex.axis = 0.8)
  }
  grid(col = "grey88")
  invisible(NULL)
}


plot_u1_z1 <- function(u1, z1) {
  op <- par(mfrow = c(1, 2), mar = c(4.2, 4.4, 2.6, 1))
  on.exit(par(op), add = TRUE)

  plot(seq_along(u1), u1, type = "l", lwd = 2, col = "#1f5c99",
       xlab = "pixel column (1 .. p)", ylab = expression(u[1]),
       main = expression(paste("First eigenvector ", u[1])))
  abline(h = 0, col = "grey60"); grid(col = "grey88")

  plot(seq_along(z1), z1, type = "l", lwd = 2, col = "#2e7d32",
       xlab = "pixel row (1 .. n, top to bottom)", ylab = expression(z[1]),
       main = expression(paste("First PC score ", z[1])))
  abline(h = 0, col = "grey60"); grid(col = "grey88")
  invisible(NULL)
}


describe_pc1 <- function(x, decomp, err) {
  u1 <- decomp$U[, 1]; z1 <- decomp$Z[, 1]
  if (sum(u1) < 0) { u1 <- -u1; z1 <- -z1 }
  total <- sum(decomp$lambda)
  list(
    n = nrow(x), p = ncol(x),
    range_x       = range(x),
    var_share_1   = decomp$lambda[1] / total,
    var_share_10  = sum(decomp$lambda[seq_len(min(10, length(decomp$lambda)))]) / total,
    u1_sign_frac  = mean(u1 > 0),
    u1_range      = range(u1),
    u1_peak_col   = which.max(abs(u1)),
    u1_flatness   = sd(u1) / mean(abs(u1)),
    z1_range      = range(z1),
    z1_peak_row   = which.max(abs(z1)),
    z1_min_row    = which.min(z1),
    err_rel       = err / err[1],
    u1 = u1, z1 = z1
  )
}

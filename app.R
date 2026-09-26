library(shiny)

source(file.path("R", "pca_compress.R"))

library(png)
library(jpeg)

MAX_DIM <- 320L


to_gray <- function(a) {
  if (length(dim(a)) == 2L) return(a)
  ch <- dim(a)[3]
  if (ch >= 3L) {
    g <- 0.299 * a[, , 1] + 0.587 * a[, , 2] + 0.114 * a[, , 3]
    if (ch == 4L) g <- g * a[, , 4] + (1 - a[, , 4])
    g
  } else {
    a[, , 1]
  }
}


downsample <- function(m, max_dim = MAX_DIM) {
  n <- nrow(m); p <- ncol(m)
  if (max(n, p) <= max_dim) return(m)
  f  <- max(n, p) / max_dim
  ri <- unique(round(seq(1, n, length.out = max(2, floor(n / f)))))
  ci <- unique(round(seq(1, p, length.out = max(2, floor(p / f)))))
  m[ri, ci, drop = FALSE]
}


read_upload <- function(path, name) {
  ext <- tolower(tools::file_ext(name))
  m <- switch(ext,
    png          = to_gray(png::readPNG(path)),
    jpg  = ,
    jpeg         = to_gray(jpeg::readJPEG(path)),
    csv          = {
      df <- utils::read.csv(path, check.names = FALSE)
      data.matrix(df)
    },
    stop("Unsupported file type '.", ext, "'. Use png, jpg, jpeg or csv.")
  )
  m <- unname(as.matrix(m))
  if (!is.numeric(m)) stop("File did not parse as a numeric matrix.")
  if (anyNA(m))       stop("File contains ", sum(is.na(m)), " missing values.")
  if (nrow(m) < 2 || ncol(m) < 2) stop("Matrix is too small to be an image.")
  downsample(m)
}


draw_image <- function(m, zlim = range(m, finite = TRUE)) {
  n <- nrow(m); p <- ncol(m)
  op <- par(mar = c(0, 0, 0, 0)); on.exit(par(op), add = TRUE)
  image(x = seq_len(p), y = seq_len(n),
        z = t(m)[, n:1, drop = FALSE],
        zlim = zlim, col = grey(seq(0, 1, length.out = 256)),
        asp = 1, axes = FALSE, xlab = "", ylab = "", useRaster = TRUE)
}


ui <- fluidPage(
  title = "PCA Image Compression",
  tags$head(tags$style(HTML("
    body { font-family: system-ui, -apple-system, 'Segoe UI', sans-serif; }
    h2 { margin-top: .4rem; }
    .panel-lab { font-weight: 600; margin-bottom: .25rem; color: #333; }
    .metric { font-variant-numeric: tabular-nums; }
    .metric b { font-size: 1.15rem; }
    .hint { color: #666; font-size: .85rem; }
  "))),

  h2("PCA Image Compression"),
  p(class = "hint",
    "Upload a PNG, JPEG or CSV matrix. The image is converted to grayscale, ",
    "decomposed as X'X = UΛU' with no centering, and rebuilt from its first ",
    "k principal components."),

  sidebarLayout(
    sidebarPanel(
      width = 3,
      fileInput("file", "Image or CSV",
                accept = c(".png", ".jpg", ".jpeg", ".csv",
                           "image/png", "image/jpeg", "text/csv")),
      uiOutput("k_ui"),
      hr(),
      htmlOutput("metrics"),
      hr(),
      p(class = "hint",
        sprintf("Images larger than %d px on the longest side are downsampled so the
                 eigendecomposition (O(p³)) stays interactive.", MAX_DIM))
    ),

    mainPanel(
      width = 9,
      uiOutput("status"),
      fluidRow(
        column(6, div(class = "panel-lab", textOutput("lab_orig", inline = TRUE)),
                  plotOutput("orig", height = "440px")),
        column(6, div(class = "panel-lab", textOutput("lab_comp", inline = TRUE)),
                  plotOutput("comp", height = "440px"))
      ),
      br(),
      div(class = "panel-lab", "Frobenius error across all k"),
      plotOutput("curve", height = "230px")
    )
  )
)


server <- function(input, output, session) {

  img <- reactive({
    req(input$file)
    tryCatch(read_upload(input$file$datapath, input$file$name),
             error = function(e) structure(conditionMessage(e), class = "upload_error"))
  })

  ok <- reactive(is.matrix(img()))

  dcm <- reactive({
    req(ok())
    withProgress(message = "Decomposing X'X ...", value = 0.5, {
      pca_decomp(img())
    })
  })

  err_curve <- reactive({
    req(ok())
    pca_error_curve(img(), decomp = dcm())
  })

  output$status <- renderUI({
    if (is.null(input$file))  return(p(class = "hint", "Waiting for a file …"))
    if (!ok())                return(div(class = "alert alert-danger", img()[1]))
    NULL
  })

  output$k_ui <- renderUI({
    req(ok())
    p_ <- ncol(img())
    sliderInput("k", "Components kept (k)",
                min = 1, max = p_,
                value = min(10, p_), step = 1, ticks = FALSE,
                width = "100%")
  })

  approx <- reactive({
    req(ok(), input$k)
    pca_compress(img(), k = input$k, decomp = dcm())
  })

  zl <- reactive(range(img(), finite = TRUE))

  output$lab_orig <- renderText({
    if (!isTRUE(ok())) return("Original")
    sprintf("Original — %d × %d, rank %d", nrow(img()), ncol(img()),
            sum(dcm()$lambda > max(dcm()$lambda) * 1e-12))
  })
  output$lab_comp <- renderText({
    req(ok(), input$k); sprintf("Reconstructed from k = %d", input$k)
  })

  output$orig  <- renderPlot({ req(ok()); draw_image(img(), zl()) })
  output$comp  <- renderPlot({ draw_image(approx()$approximation, zl()) })

  output$curve <- renderPlot({
    req(ok())
    e <- err_curve()
    op <- par(mar = c(4, 4.4, 0.6, 1)); on.exit(par(op), add = TRUE)
    plot(seq_along(e), e, type = "l", lwd = 2, col = "#1f5c99",
         xlab = "k", ylab = "Frobenius error")
    grid(col = "grey88")
    if (!is.null(input$k)) {
      abline(v = input$k, col = "#c0392b", lty = 2)
      points(input$k, e[input$k], pch = 19, col = "#c0392b")
    }
  })

  output$metrics <- renderUI({
    req(ok(), input$k)
    n <- nrow(img()); p_ <- ncol(img())
    cr <- pca_compression_ratio(n, p_, input$k)
    e  <- approx()$error
    HTML(sprintf(
      "<div class='metric'>
         Frobenius error<br><b>%.2f</b>
         <span class='hint'>(%.2f%% of ‖X‖<sub>F</sub> = %.1f)</span><br><br>
         Stored numbers<br><b>%s</b>
         <span class='hint'>= (n + p)&middot;k</span><br>
         Raw image<br><b>%s</b>
         <span class='hint'>= n&middot;p</span><br><br>
         Compression ratio<br><b>%.1f%%</b>
         <span class='hint'>of original (%.1f%% saved)</span>
       </div>",
      e, 100 * e / norm(img(), type = "F"), norm(img(), type = "F"),
      format(cr$stored, big.mark = ","), format(cr$original, big.mark = ","),
      100 * cr$ratio, 100 * cr$saving))
  })
}

shinyApp(ui, server)

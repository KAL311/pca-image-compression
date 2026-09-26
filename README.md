# Image Compression with Principal Components

Rank-$k$ image compression using PCA on the uncentered cross product
$X'X = U\Lambda U'$, $Z = XU$, $X_{(k)} = z_1u_1' + \cdots + z_ku_k'$.

- Analysis site: https://KAL311.github.io/pca-image-compression/
- Shiny app: https://kal311.shinyapps.io/pca-image-compression/
- App design write-up: https://KAL311.github.io/pca-app-design/

## Layout

| Path | What it is |
|---|---|
| `R/pca_compress.R` | Part 1, the compression function plus the decomposition and error-curve helpers |
| `R/plot_helpers.R` | Grayscale rendering and the diagnostic plots |
| `index.qmd` | Part 2, the analysis site (renders to `docs/`) |
| `_image_template.qmd` | Per-image section, knit once for each CSV found in `data/` |
| `interpretations/*.md` | The written reading of `u1` and `z1` and the choice of `k`, one file per image |
| `config/k_choices.R` | The chosen `k` per image |
| `app.R` | Part 4, the Shiny app; sources `R/pca_compress.R` rather than duplicating it |
| `tests/test_pca_compress.R` | Math and validation checks on throwaway matrices |
| `data/` | The four image CSVs, committed so the site can be re-rendered |
| `docs/` | Rendered site, which is what GitHub Pages serves |

## The data

Any number of `data/*.csv` files gets picked up automatically. Each has to be a
plain numeric grid with no metadata columns. If `data/` is empty or a file is
malformed the render stops with an error rather than carrying on.

The four supplied images are deliberately different from each other, and the
site treats them as four separate compression problems rather than four
photographs:

| File | Size | What it is | Chosen `k` |
|---|---|---|---|
| `image1.csv` | 1000 × 100 | Standard normal noise with a constant offset on column 78 | 1 |
| `image2.csv` | 1000 × 100 | Exactly rank 2: a random row vector times a linear column ramp | 2 |
| `image3.csv` | 376 × 345 | Photograph of a puppy | 40 |
| `image4.csv` | 213 × 119 | Overhead view of a track with bright objects | 30 |

The pixel values aren't on a 0-255 scale, they're roughly zero-centred floats,
so $X'X$ measures energy rather than brightness. That changes how `u1` reads,
and the per-image write-ups say so where it matters.

## Running things

```bash
Rscript tests/test_pca_compress.R
quarto render
R -e "shiny::runApp()"
```

`quarto render` refuses to run if any image has more than `MAX_P` (1200) columns,
since `eigen()` on a $p \times p$ matrix is $O(p^3)$. Raise it in the setup chunk
of `index.qmd` if you really want to.

## Deploying the Shiny app

From an R console, once, using a token from
<https://www.shinyapps.io/admin/#/tokens>:

```r
install.packages("rsconnect")
rsconnect::setAccountInfo(name = "kal311", token = "<token>", secret = "<secret>")
```

Then from the repository root:

```r
rsconnect::deployApp(
  appDir        = ".",
  appFiles      = c("app.R", "R/pca_compress.R"),
  appName       = "pca-image-compression",
  appTitle      = "PCA Image Compression",
  account       = "kal311",
  forceUpdate   = TRUE
)
```

`appFiles` is what keeps the bundle down to two files. Without it `deployApp()`
would try to upload `data/` and `docs/` as well.

## Publishing the site

GitHub Pages serves from the `main` branch, `docs` folder, so `docs/` is
committed rather than ignored. After any change, run `quarto render` and commit
`docs/` along with everything else.

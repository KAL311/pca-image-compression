# data/

The grayscale image CSVs from Canvas go here: `image1.csv`, `image2.csv`, …

Every `data/*.csv` is picked up automatically by `index.qmd` — the number of
files is not hard-coded anywhere. Each file must be a plain numeric grid
(n rows x p columns) of pixel values, header row allowed, no ID or label
columns, no missing values.

If this folder is empty the render stops with an error. Nothing synthetic is
substituted.

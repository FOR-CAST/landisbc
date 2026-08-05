# Select analogue BEC labels within a distance cut-off

The companion to
[`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md):
turns a ranking into the semicolon-delimited string that
`include_bec_labels` in the ground-plot filter table expects.

## Usage

``` r
bec_analogue_labels(analogues, max_distance, drop_sparse = TRUE)
```

## Arguments

- analogues:

  A tibble from
  [`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md).

- max_distance:

  Numeric. Cut-off; labels at or below it are kept.

- drop_sparse:

  Logical. Exclude labels flagged `sparse`.

## Value

A single semicolon-delimited character string.

## See also

Other growth calibration helpers:
[`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md)

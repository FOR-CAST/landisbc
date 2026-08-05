# Rank BEC labels by climatic similarity to a target

Ground-plot coverage for any one BEC variant is often too thin to fit a
growth curve against. Widening the pool to "the same zone" is the
obvious move and the wrong one: BEC zones span large climatic ranges, so
a same-zone plot can be less like the target than a plot from a
neighbouring zone. This ranks every label by actual climate instead.

## Usage

``` r
bec_climate_analogues(
  climate,
  target,
  vars = c("MAT", "MAP", "MSP", "MCMT", "MWMT", "TD"),
  min_plots = 5L
)
```

## Arguments

- climate:

  A data frame with one row per plot, a `bec_label` column, and one
  column per climate variable.

- target:

  Named numeric vector giving the target climate, or the name of a
  `bec_label` whose median climate is used.

- vars:

  Character. Climate variables to compare on.

- min_plots:

  Integer. Labels with fewer plots than this still appear, but are
  flagged `sparse`, since a median over three plots is not a climate.

## Value

A tibble ordered by `distance`, with `bec_label`, `n_plots`, `distance`,
`sparse`, and the median of each variable.

## Details

Distance is Euclidean over climate variables standardised by their
spread ACROSS LABELS, so each variable contributes comparably regardless
of its units. Temperature in degrees and precipitation in millimetres
are otherwise incommensurable, and precipitation would dominate purely
through its larger numeric range.

Choosing the target is the consequential decision and is deliberately
left to the caller. Anchoring on the plots labelled as the target
variant is the obvious choice and can be badly wrong where those plots
are few: a handful of plots carrying a variant's name may sit well away
from the landscape actually being modelled, in which case anchoring on
that landscape's own climate is the better option. Compute both and
compare before committing.

## See also

Other growth calibration helpers:
[`bec_analogue_labels()`](https://for-cast.github.io/landisbc/reference/bec_analogue_labels.md)

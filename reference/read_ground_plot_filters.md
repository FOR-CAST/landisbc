# Read the per-species ground-plot filters

Which ground plots are admissible evidence for a species is a
per-species judgement, not a global one: a species well represented in
the target BEC zone can be restricted to it, while one absent from that
zone has to borrow plots from elsewhere or have none at all. Keeping
those choices in a versioned table rather than buried in plotting or
scoring code means the figures, the fit statistics and any write-up all
state the same thing.

## Usage

``` r
read_ground_plot_filters(path)
```

## Arguments

- path:

  Character. Path to `ground_plot_filters.csv`.

## Value

A tibble, one row per species.

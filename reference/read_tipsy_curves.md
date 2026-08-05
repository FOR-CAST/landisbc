# Read the TIPSY yield curves

Values are Mg C ha^-1; see the units note in
`params/forcs/growth_reference/tipsy_run_metadata.csv`.

## Usage

``` r
read_tipsy_curves(path)
```

## Arguments

- path:

  Character. Path to `tipsy_curves.csv`.

## Value

A tibble with `series_id`, `species`, `bec_group`, `age`, `value`.

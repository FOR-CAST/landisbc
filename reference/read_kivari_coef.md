# Read the Kivari volume-to-biomass conversion factors

Subalpine and amabilis fir share one coefficient set, stored as `Ba_Bl`.

## Usage

``` r
read_kivari_coef(path)
```

## Arguments

- path:

  Character. Path to `kivari_volume_to_biomass.csv`.

## Value

A tibble with `species_group` and the five component factors.

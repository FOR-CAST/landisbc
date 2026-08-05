# Assemble plot-visit records from the cached FAIB tables

Joins header, visit, compiled-summary, and site-age tables and restricts
to the requested Timber Supply Areas at the 4 cm close-utilization
level.

## Usage

``` r
assemble_faib_ground_plots(
  files,
  tsas = .faib_tsas,
  util = 4,
  exclude_sample_types = .faib_excluded_sample_types
)
```

## Arguments

- files:

  Character vector of cached file paths, from
  [`fetch_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/fetch_faib_ground_plots.md).

- tsas:

  Character vector of Timber Supply Area names to retain.

- util:

  Numeric. Close-utilization level to retain.

- exclude_sample_types:

  Character vector of `SAMPLE_ESTABLISHMENT_TYPE` values to drop.
  Defaults to `"PSP_R"`; see the note above that constant.

## Value

A tibble, one row per plot visit.

## Details

`UTIL == 4` is not incidental: the Kivari volume-to-biomass factors are
specified at the 4.0 cm utilization level, so any other level would pair
volumes with the wrong conversion.

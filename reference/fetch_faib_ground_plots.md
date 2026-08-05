# Download the FAIB ground-plot tables

Fetches the four plot-level tables for both compilations, caching each
file under `dest`. Existing files are reused unless `overwrite = TRUE`,
so a repeat build does no network I/O.

## Usage

``` r
fetch_faib_ground_plots(dest, tsas = .faib_tsas, overwrite = FALSE)
```

## Arguments

- dest:

  Character. Cache directory.

- tsas:

  Character vector of Timber Supply Area names for the non-PSP
  compilation (which is partitioned by TSA).

- overwrite:

  Logical. Re-download files that are already cached.

## Value

Character vector of the cached file paths.

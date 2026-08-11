# Split cached FAIB file paths by compilation

The two compilations are published on different footprints – PSP as
province-wide flat files, non-PSP partitioned by Timber Supply Area – so
a pool that is province-wide in one and local in the other has to
assemble them separately. This keeps the file-naming convention that
[`fetch_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/fetch_faib_ground_plots.md)
writes inside the package that writes it, rather than making every
caller re-derive it.

## Usage

``` r
faib_split_compilations(files)
```

## Arguments

- files:

  Character vector of cached file paths, from
  [`fetch_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/fetch_faib_ground_plots.md).

## Value

A list with `psp` and `non_psp` character vectors.

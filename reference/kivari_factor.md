# Look up volume-to-biomass conversion factors

Convenience accessor over
[kivari_volume_to_biomass](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md):
takes BC species codes and BEC zones and returns the matching factors,
resolving the species group with
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md).

## Usage

``` r
kivari_factor(
  species_code,
  bec_zone,
  component = c("total", "bole", "branches", "bark", "foliage")
)
```

## Arguments

- species_code:

  Character vector of BC tree species codes.

- bec_zone:

  Character vector of BEC zone codes, recycled against `species_code`.

- component:

  Which coefficient to return: `"total"` (the default, all four
  components summed) or one of the individual components.

## Value

Numeric vector the length of `species_code`.

## Details

Vectorised and length-preserving, so it can be used inside a `mutate()`
on a table of plot records. Rows whose species or zone has no entry come
back `NA` rather than being dropped, so a caller can see and count what
did not convert instead of silently losing it.

## See also

Other volume-to-biomass conversion:
[`kivari_correlation`](https://for-cast.github.io/landisbc/reference/kivari_correlation.md),
[`kivari_sample_frequency`](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md),
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md),
[`kivari_sp0_codes`](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md),
[`kivari_volume_to_biomass`](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md)

## Examples

``` r
kivari_factor(c("FD", "PL", "SW"), "SBS")
#> [1] 0.5804 0.5793 0.5393
kivari_factor("FD", c("SBS", "IDF", "ICH"))
#> [1] 0.5804 0.5884 0.5707
```

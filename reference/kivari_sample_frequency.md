# Sample-tree frequency behind the volume-to-biomass factors

Number of sample TREES per species group and BEC zone. The thin strata
are where the conversion factors deserve least trust – alder in MS, for
instance, carries a branch coefficient of 0.7003 against 0.1299 in ICH.
`NA` where the report printed no value.

## Usage

``` r
kivari_sample_frequency
```

## Format

A tibble with 224 rows and 3 columns:

- sp0:

  Species group code.

- bec_zone:

  BEC zone code.

- n_trees:

  Number of sample trees, or `NA`.

## Source

As
[kivari_volume_to_biomass](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md);
report Table 3.

## See also

Other volume-to-biomass conversion:
[`kivari_correlation`](https://for-cast.github.io/landisbc/reference/kivari_correlation.md),
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md),
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md),
[`kivari_sp0_codes`](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md),
[`kivari_volume_to_biomass`](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md)

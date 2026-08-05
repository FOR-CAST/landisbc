# Species-group (`sp0`) codes used by the volume-to-biomass factors

The 16 groups the conversion factors are keyed on, with the rule that
assigns a BC tree species code to each.
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md)
implements the rules; this table carries them in the report's own words
so a caller can check the implementation against the source.

## Usage

``` r
kivari_sp0_codes
```

## Format

A tibble with 16 rows and 4 columns:

- sp0:

  Species group code.

- genus:

  Single-letter genus code.

- interpretation:

  The report's plain-language description.

- rule:

  The report's rule for assigning species codes to this group.

## Source

As
[kivari_volume_to_biomass](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md);
report Table 2.

## See also

Other volume-to-biomass conversion:
[`kivari_correlation`](https://for-cast.github.io/landisbc/reference/kivari_correlation.md),
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md),
[`kivari_sample_frequency`](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md),
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md),
[`kivari_volume_to_biomass`](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md)

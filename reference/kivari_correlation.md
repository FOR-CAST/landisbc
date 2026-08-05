# Correlation coefficients for the volume-to-biomass relationships

How well each fitted biomass component tracks whole-stem volume, per
species group and BEC zone. Use it to judge whether a conversion factor
is well supported in the stratum you are applying it to. `NA` where the
report printed no value.

## Usage

``` r
kivari_correlation
```

## Format

A tibble with 896 rows and 4 columns:

- sp0:

  Species group code.

- bec_zone:

  BEC zone code.

- component:

  One of `"bole"`, `"branches"`, `"bark"`, `"foliage"`.

- r:

  Correlation coefficient, or `NA`.

## Source

As
[kivari_volume_to_biomass](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md);
report Tables 5, 14, 15 and 16.

## Details

The report's prose states that correlations "ranged from 0.3708 to
1.0000", but its own foliage table prints 0.0023 for birch in SBPS and
0.3226 for white pine in MH, both below that stated floor. The values
here are as printed; the prose is not reproduced.

A missing correlation does NOT imply a missing stratum:
[kivari_sample_frequency](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md)
counts TREES while these are computed over PLOTS, so a stratum can hold
many trees in too few plots to correlate (spruce in AT: 183 trees, no
bole correlation).

## See also

Other volume-to-biomass conversion:
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md),
[`kivari_sample_frequency`](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md),
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md),
[`kivari_sp0_codes`](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md),
[`kivari_volume_to_biomass`](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md)

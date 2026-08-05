# Assign BC tree species codes to volume-to-biomass species groups

Implements the report's own assignment rules
([kivari_sp0_codes](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md)).
Most are "anything starting with this letter", with a handful of
explicit exceptions that matter: `AT` is its own group rather than
falling in with the other `A` codes, the pines split four ways, and `CP`
/ `CY` go to yellow cedar rather than to cedar.

## Usage

``` r
kivari_sp0(species_code)
```

## Arguments

- species_code:

  Character vector of BC tree species codes. Case is ignored.

## Value

Character vector of `sp0` codes, `NA` where the code is empty or matches
no rule (the report's `blank` row, "invalid code").

## Details

Matching is on the leading letters of the code, so both the
two-character forms the ground-plot compilations use (`"FD"`, `"PL"`,
`"SW"`) and the longer VRI forms (`"FDI"`, `"PLI"`, `"SXW"`) resolve
correctly.

## See also

Other volume-to-biomass conversion:
[`kivari_correlation`](https://for-cast.github.io/landisbc/reference/kivari_correlation.md),
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md),
[`kivari_sample_frequency`](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md),
[`kivari_sp0_codes`](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md),
[`kivari_volume_to_biomass`](https://for-cast.github.io/landisbc/reference/kivari_volume_to_biomass.md)

## Examples

``` r
kivari_sp0(c("FD", "FDI", "PLI", "PA", "PY", "SW", "AT", "AC", "CW", "CY"))
#>  [1] "F"  "F"  "PL" "PA" "PY" "S"  "AT" "AC" "C"  "Y" 
```

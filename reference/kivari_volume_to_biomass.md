# Volume-to-biomass conversion factors for British Columbia forests

Regression coefficients converting stand whole-stem volume to
aboveground biomass components, by species group and BEC zone. Fitted by
regression without intercept, so biomass is simply
`volume * coefficient`:

## Usage

``` r
kivari_volume_to_biomass
```

## Format

A tibble with 224 rows and 7 columns:

- sp0:

  Species group code; see
  [kivari_sp0_codes](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md)
  and
  [`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md).

- bec_zone:

  BEC zone code.

- bole:

  Bole (wood) coefficient (report Table 4).

- branches:

  Branch coefficient (report Table 11).

- bark:

  Bark coefficient (report Table 12).

- foliage:

  Foliage coefficient (report Table 13).

- total:

  Sum of the four components. Total aboveground biomass.

## Source

Kivari, A., Xu, W., and Otukol, S. 2010 (revised January 2011). *Volume
to Biomass Conversion for British Columbia Forests.* DRAFT. Forest
Analysis and Inventory Branch, BC Ministry of Forests and Range. Tables
4, 11, 12 and 13.
<https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/stewardship/forest-analysis-inventory/growth-yield/volume_to_biomass_conversion_report_edit_mp_jan_31_2011.pdf>

The report is marked DRAFT; confirm no superseding version exists before
relying on it for published work. The tables are published only as a PDF
– a BC Data Catalogue search returns no machine-readable version – so
they were parsed programmatically and checked against values
independently in use. A plain-text copy is installed at
`system.file("extdata", "kivari_volume_to_biomass.csv", package = "landisbc")`.

## Details

    biomass_t_ha <- wsv_m3_ha * total

**Utilization level.** These convert whole-stem volume of trees with
`Dbh >= 4.0 cm` to biomass of trees with `Dbh >= 4.0 cm`. Pairing them
with volume compiled at any other utilization level pairs volumes with
the wrong conversion; the FAIB ground-plot compilations record this as
`UTIL`, and
[`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md)
filters to `UTIL == 4` for exactly this reason. The source report also
publishes factors for the 7.5, 12.5, 17.5 and 22.5 cm levels, which are
NOT included here.

**Units.** Volume is m^3 ha^-1 and biomass is tonnes ha^-1, i.e.
oven-dry mass. To get CARBON, apply a carbon fraction yourself – the
coefficients do not include one.

**Coverage.** All 16 species groups x 14 BEC zones are populated, with
no gaps. Where the report had too little data to fit a (group, zone)
stratum it fell back to that group pooled over all zones, so a value
being present is not on its own evidence that it was fitted on local
data. Judge that with
[kivari_sample_frequency](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md)
and
[kivari_correlation](https://for-cast.github.io/landisbc/reference/kivari_correlation.md).

## See also

Other volume-to-biomass conversion:
[`kivari_correlation`](https://for-cast.github.io/landisbc/reference/kivari_correlation.md),
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md),
[`kivari_sample_frequency`](https://for-cast.github.io/landisbc/reference/kivari_sample_frequency.md),
[`kivari_sp0()`](https://for-cast.github.io/landisbc/reference/kivari_sp0.md),
[`kivari_sp0_codes`](https://for-cast.github.io/landisbc/reference/kivari_sp0_codes.md)

## Examples

``` r
# Douglas-fir in the Sub-Boreal Spruce zone
subset(kivari_volume_to_biomass, sp0 == "F" & bec_zone == "SBS")
#> # A tibble: 1 × 7
#>   sp0   bec_zone  bole branches   bark foliage total
#>   <chr> <chr>    <dbl>    <dbl>  <dbl>   <dbl> <dbl>
#> 1 F     SBS      0.364    0.105 0.0713  0.0396 0.580
```

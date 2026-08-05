# Fit dNBR thresholds that reproduce BC's burned-class area fractions

The "Option B" calibration step: computes the area fractions of BC's Low
/ Medium / High burned classes, extracts the CanLaBS dNBR values inside
the BC-assessed polygons (the 2015+ overlap window, by construction),
and returns the two dNBR breakpoints whose quantiles reproduce those
fractions. Higher dNBR is taken to mean higher severity, so ascending
dNBR quantiles align with Low \< Medium \< High.

## Usage

``` r
fit_canlabs_thresholds(canlabs_dnbr, bc_polys)
```

## Arguments

- canlabs_dnbr:

  `SpatRaster` from
  [`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
  (scope-level).

- bc_polys:

  `sf` BC burn-severity polygons from
  [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md).

## Value

A list with `thresholds` (named numeric `c(lowmed =, medhigh =)`),
`bc_fractions` (the Low/Medium/High area fractions used), and
`n_pixels`.

## See also

Other CanLaBS fire severity:
[`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md),
[`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md),
[`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md),
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)

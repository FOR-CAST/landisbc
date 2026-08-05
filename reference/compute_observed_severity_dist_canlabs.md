# Observed severity-class distribution from CanLaBS dNBR

Classifies CanLaBS dNBR into BC's Low/Medium/High via `thresholds`, maps
the area onto LANDIS-II Dynamic Fire's 5-class scheme with the same
trapezoid kernel used for the BC layer
([`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md)),
and normalises to sum 1. The return contract matches
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md)
so it is a drop-in for `landisutils::save_observed_fire_targets()`'s
`severity_dist`.

## Usage

``` r
compute_observed_severity_dist_canlabs(canlabs_dnbr, thresholds)
```

## Arguments

- canlabs_dnbr:

  `SpatRaster` from
  [`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
  (full record).

- thresholds:

  Output of
  [`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md).

## Value

Named numeric vector of length 5 (names "1".."5") summing to 1.

## See also

Other CanLaBS fire severity:
[`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md),
[`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md),
[`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md),
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)

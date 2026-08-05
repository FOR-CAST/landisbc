# Classify CanLaBS dNBR into BC burned classes and return area by class

Classify CanLaBS dNBR into BC burned classes and return area by class

## Usage

``` r
classify_canlabs_dnbr(canlabs_dnbr, thresholds)
```

## Arguments

- canlabs_dnbr:

  `SpatRaster` from
  [`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md).

- thresholds:

  Output of
  [`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md)
  (or a bare `c(lowmed =, medhigh =)` numeric vector).

## Value

Named numeric vector `c(Low =, Medium =, High =)` of burned area (ha).

## See also

Other CanLaBS fire severity:
[`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md),
[`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md),
[`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md),
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)

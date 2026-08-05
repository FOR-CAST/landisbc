# CanLaBS v2 layer filenames

The three GeoTIFF layers distributed with CanLaBS v2 (national mosaic,
Canada Lambert Conformal Conic / NAD83). These are large; download once
and cache under `canlabs_dir` (as for the NBAC archive). The filenames
embed the product version date and may change on a future release –
override the `files` argument of
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
if so.

## Usage

``` r
canlabs_v2_files()
```

## Value

Named character vector with elements `dnbr`, `salvage`, `fireyear`.

## See also

Other CanLaBS fire severity:
[`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md),
[`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md),
[`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md),
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)

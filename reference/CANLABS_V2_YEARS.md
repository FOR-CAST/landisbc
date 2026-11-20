# Fire years CanLaBS v2 covers

The product maps dNBR for the fires of 1985-2024, the years in its file
names
([`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md)).
A perimeter from any other year can still hold dNBR, wherever a covered
fire later burned the same ground, and that value is the later fire's.
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
therefore drops fire years outside this range instead of keeping their
perimeters.

## Usage

``` r
CANLABS_V2_YEARS
```

## See also

Other CanLaBS fire severity:
[`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md),
[`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md),
[`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md),
[`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md),
[`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)

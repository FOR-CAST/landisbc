# Compute observed severity-class distribution for the calibration loss

Computes the area-weighted distribution of BC severity ratings over the
input polygon set, drops "Unburned" / "Unknown", then projects onto
LANDIS-II Dynamic Fire's 5-class scheme via
[`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md)
and normalises to sum to 1.

## Usage

``` r
compute_observed_severity_dist(burn_severity_polys)
```

## Arguments

- burn_severity_polys:

  `sf` object returned by
  [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md).

## Value

Named numeric vector of length 5 (names "1".."5") summing to 1. This is
the format that `landisutils::save_observed_fire_targets()`'s
`severity_dist` argument expects.

## Details

The input is the full BC severity polygon set within the calibration
scope (typically the fire-regime ecoregion(s), not a single study area);
no fire- perimeter intersection is applied because BC severity is so
sparse spatially that intersecting at study-area scope collapses to a
handful of polygons (see
[`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
for the scope rationale). The resulting distribution is a regional
reference for the ecoregion's historical fire severity, not a
study-area-specific one.

## See also

Other BC fire severity:
[`BC_SEVERITY_FIRST_YEAR`](https://for-cast.github.io/landisbc/reference/BC_SEVERITY_FIRST_YEAR.md),
[`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md),
[`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)

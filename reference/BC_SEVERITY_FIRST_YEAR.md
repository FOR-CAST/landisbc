# First fire year with BC Fire Burn Severity coverage

The layer is derived from pre/post-fire Landsat differencing and simply
does not extend earlier: querying `FIRE_YEAR` 2010 or 2014 returns no
records, 2015 onward do (verified against the live layer). Fire windows
in this project routinely start decades earlier, so
[`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
drops the uncovered years instead of enumerating them in the
`CQL_FILTER` for nothing – a 1950:2024 window is 75 enumerated values of
which 65 can never match.

## Usage

``` r
BC_SEVERITY_FIRST_YEAR
```

## See also

Other BC fire severity:
[`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md),
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md),
[`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)

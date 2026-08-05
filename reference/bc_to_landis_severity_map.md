# BC -\> LANDIS Dynamic Fire severity-class mapping

Returns the weights used by
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md)
to map BC's 4-class burn-severity scheme (Unburned, Low, Medium, High)
onto LANDIS-II Dynamic Fire's 5-class scheme (integers 1..5). "Unburned"
is dropped – simulated severities are only logged for burned cells, so
the observed reference must exclude unburned area.

## Usage

``` r
bc_to_landis_severity_map()
```

## Value

Named list keyed by BC severity rating (Low / Medium / High); each
element is a numeric vector of weights over LANDIS classes 1..5.

## Details

Mapping rationale: BC has 3 burned-class bins, LANDIS has 5, so each BC
bin is split across the LANDIS bins it brackets:

- Low -\> 50% LANDIS-1 + 50% LANDIS-2

- Medium -\> 100% LANDIS-3

- High -\> 50% LANDIS-4 + 50% LANDIS-5

This trapezoid smoothing avoids hard zero bins in LANDIS classes 2 and 4
(which inflate the chi-squared loss artificially) while still respecting
the ordering of the BC classification.

## See also

Other BC fire severity:
[`BC_SEVERITY_FIRST_YEAR`](https://for-cast.github.io/landisbc/reference/BC_SEVERITY_FIRST_YEAR.md),
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md),
[`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)

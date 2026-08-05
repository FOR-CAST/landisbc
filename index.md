# landisbc

`landisbc` collects Province of British Columbia study-area
data-preparation helpers for LANDIS-II forest-landscape simulation
workflows. It is the BC-specific companion to
[`landisutils`](https://github.com/FOR-CAST/landisutils) (the
study-area-agnostic LANDIS-II tooling): anything that depends on a
particular BC data source or classification lives here so it can be
reused across British Columbia projects.

## Current contents

- **Fire severity** – derive an observed fire-severity-class
  distribution from the BC Fire Burn Severity (Historical) layer, in the
  5-class format `landisutils::save_observed_fire_targets()` expects for
  Dynamic Fire calibration:
  [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md),
  [`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md),
  [`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md).

## Installation

Installed from local source via `renv` in the projects that vendor it as
a submodule; or:

``` r

# install.packages("remotes")
remotes::install_github("FOR-CAST/landisbc")
```

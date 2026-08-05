# Load CanLaBS v2 dNBR over a scope, salvage-masked and year-filtered

Reads the staged CanLaBS v2 GeoTIFFs, crops and masks the dNBR layer to
`scope_polys`, drops salvage-logged pixels, and (optionally) restricts
to fires in `fire_years`. Returns dNBR in the CanLaBS CRS (Canada
Lambert / NAD83); reprojecting the small scope polygon into the raster
CRS avoids resampling the national mosaic.

## Usage

``` r
get_canlabs_dnbr(
  canlabs_dir,
  scope_polys,
  nbac_polys = NULL,
  fire_years = NULL,
  drop_salvage = TRUE,
  files = canlabs_v2_files()
)
```

## Arguments

- canlabs_dir:

  Directory holding the staged CanLaBS v2 GeoTIFFs.

- scope_polys:

  `sf`/`sfc` scope (e.g. the fire-regime polygons).

- nbac_polys:

  `sf` NBAC perimeters with a year column; required if `fire_years` is
  used for temporal filtering.

- fire_years:

  Integer vector of years to keep, or `NULL` for all.

- drop_salvage:

  Logical; if `TRUE` (default) sets salvage-logged pixels (mask value 1)
  to `NA`.

- files:

  Named character vector of layer filenames; see
  [`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md).

## Value

A single-layer `terra` `SpatRaster` (`dNBR`) in the CanLaBS CRS.

## Details

Year filtering uses the caller's NBAC perimeters (a known year column)
rather than the CanLaBS fire-year raster, whose pixel encoding is not
documented in the product readme; pass the project's NBAC polygons as
`nbac_polys`.

## See also

Other CanLaBS fire severity:
[`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md),
[`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md),
[`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md),
[`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md)

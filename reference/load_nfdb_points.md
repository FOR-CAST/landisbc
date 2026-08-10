# Load NFDB fire points, clipped + EcoCode-tagged to a study area

Loads National Fire DataBase (NFDB) fire points, filters to the
study-area fire years and `SIZE_HA >= 1` ha, projects to the
fire-ecoregions grid, and (optionally) tags each fire with its
fire-ecoregion `EcoCode` extracted from a fire-ecoregions raster. When
`fire_eco_map_path` is supplied, fires that do not land on a mapped zone
are dropped – this is what restricts the national NFDB to the study
area, generalised over the N zones (no hard-coded zone). The year column
is detected tolerantly (`YEAR` or `FIRE_YEAR`) so the loader works
across projects.

## Usage

``` r
load_nfdb_points(nfdb_shp, fire_eco_map_path = NULL, fire_years)
```

## Arguments

- nfdb_shp:

  Path(s) to the NFDB point shapefile(s).

- fire_eco_map_path:

  Optional path to a fire-ecoregions raster. When supplied, points are
  reprojected to its CRS, tagged with `EcoCode`, and restricted to the
  mapped zones (see Details). `NULL` (default) skips the EcoCode
  tagging, leaving the points untagged and uncropped.

- fire_years:

  Integer vector of fire years to keep.

## Value

A `SpatVector` of NFDB points within the study area (and, when
`fire_eco_map_path` is supplied, carrying an integer `EcoCode` column
whose values are all \>= 1).

## Which points count as "in the study area"

A point is kept only when its extracted `EcoCode` is both non-`NA` and
non-zero. Both conditions are load-bearing, and dropping the second is a
silent, consequential bug:

- `NA` means the point fell outside the raster altogether.

- `0` is LANDIS-II's reserved INACTIVE-cell code. LANDIS-II reads raw
  raster cell values and ignores the GDAL NoData flag, so a
  fire-ecoregions map marks everything outside the simulated landscape
  with `0` rather than `NA`.

A raster is rectangular but a study area is not, so filtering on `NA`
alone keeps every point in the map's bounding box. In a downstream fire
calibration that took the bounding box rather than the landscape, this
admitted roughly twice the ignitions the simulated landscape actually
holds; the resulting observed ignition rate was unreachable by
construction and the ignition-count loss degenerated into a constant
that dragged the fitted ignition probabilities to their bounds.

Callers that key on a zone table (`zones$EcoCode`) are incidentally
immune, since `0` is not a zone. Callers that consume the returned point
set WHOLESALE – counts, rates, seasonal splits – are not, which is why
the filter belongs here rather than in each caller.

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
[`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md),
[`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md),
[`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md),
[`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md),
[`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md),
[`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md),
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

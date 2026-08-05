# Load NFDB fire points, clipped + EcoCode-tagged to a study area

Loads National Fire DataBase (NFDB) fire points, filters to the
study-area fire years and `SIZE_HA >= 1` ha, projects to the
fire-ecoregions grid, and (optionally) tags each fire with its
fire-ecoregion `EcoCode` extracted from a fire-ecoregions raster. When
`fire_eco_map_path` is supplied, fires outside the study-area zones (NA
`EcoCode`) are dropped – this is what restricts the national NFDB to the
study area, generalised over the N zones (no hard-coded zone). The year
column is detected tolerantly (`YEAR` or `FIRE_YEAR`) so the loader
works across the BC_HRV and gitanyow-partial-harvest projects.

## Usage

``` r
load_nfdb_points(nfdb_shp, fire_eco_map_path = NULL, fire_years)
```

## Arguments

- nfdb_shp:

  Path(s) to the NFDB point shapefile(s).

- fire_eco_map_path:

  Optional path to a fire-ecoregions raster. When supplied (the BC_HRV
  path), points are reprojected to its CRS and tagged with `EcoCode`;
  points outside any zone are dropped. `NULL` (default) skips the
  EcoCode tagging.

- fire_years:

  Integer vector of fire years to keep.

## Value

A `SpatVector` of NFDB points within the study area (and, when
`fire_eco_map_path` is supplied, carrying an integer `EcoCode` column).

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

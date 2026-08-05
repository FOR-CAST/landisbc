# Labelled area-by-fuel-type summary of the provincial fuel raster

Computes a labelled area-by-fuel-type summary of the (undisturbed)
provincial fuel raster. Labels are summarised on the IN-MEMORY factor
raster
([`terra::freq()`](https://rspatial.github.io/terra/reference/freq.html)'s
value column holds the label), so no stored-raster labels and no
hardcoded integer-to-label map are needed. Hectares uses the true cell
area computed from the raster resolution (e.g. a 120 m pixel = 1.44 ha),
not a hardcoded per-cell area.

## Usage

``` r
fuel_types_distribution(fuel_types, recent_disturb, study_area, rtm)
```

## Arguments

- fuel_types:

  `sf` of provincial fuel-type polygons (from
  [`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md)).

- recent_disturb:

  `SpatRaster` of recent disturbance (inverse mask), or `NULL` to skip
  masking.

- study_area:

  `sf` or `SpatVector` study-area polygon.

- rtm:

  A rasterToMatch `SpatRaster`.

## Value

A data frame with columns `fuel_type` (character FBP label) and
`hectares` (numeric area).

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
[`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md),
[`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md),
[`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md),
[`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md),
[`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md),
[`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md),
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

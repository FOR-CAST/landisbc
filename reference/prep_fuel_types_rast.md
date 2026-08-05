# Rasterise the provincial fuel layer to the rasterToMatch

Rasterises the provincial fuel layer to the rasterToMatch, clips to the
study area, and optionally masks recently-disturbed cells. Returns a
CATEGORICAL raster
([`terra::freq()`](https://rspatial.github.io/terra/reference/freq.html)
summarises FBP labels).

## Usage

``` r
prep_fuel_types_rast(fuel_types, recent_disturb, study_area, rtm)
```

## Arguments

- fuel_types:

  `sf` of provincial fuel-type polygons with a factor `FUEL_TYPE_CD`
  column (from
  [`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md)).

- recent_disturb:

  `SpatRaster` of recent disturbance (used as an inverse mask), or
  `NULL` to skip masking.

- study_area:

  `sf` or `SpatVector` study-area polygon.

- rtm:

  A rasterToMatch `SpatRaster`.

## Value

A categorical `SpatRaster` of FBP fuel types, clipped to the study area
and optionally masked of recently-disturbed cells.

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
[`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md),
[`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md),
[`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md),
[`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md),
[`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md),
[`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md),
[`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md),
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

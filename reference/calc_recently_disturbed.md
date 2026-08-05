# Rasterise the most-recent stand-replacing disturbance to the rasterToMatch

Rasterises the most-recent stand-replacing disturbance (since
`recent_year`) to the rasterToMatch. `MRSRD_Y` = year of the most recent
stand-replacing disturbance; `MRSRD_A` = its cause (CUT or BRN).

## Usage

``` r
calc_recently_disturbed(for_dist, rtm, recent_year)
```

## Arguments

- for_dist:

  `sf` or `SpatVector` of forest-disturbance polygons carrying `MRSRD_Y`
  and `MRSRD_A` columns.

- rtm:

  A rasterToMatch `SpatRaster`.

- recent_year:

  Integer cutoff year; only disturbances after it are kept.

## Value

A `SpatRaster` of the most-recent disturbance year, aligned to `rtm`.

## See also

Other BC fire and fuel data:
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
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

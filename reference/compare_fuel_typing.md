# Confusion matrix and overall agreement between bcwsft and provincial fuel types

Assigns each bcwsft polygon the provincial code it most overlaps
(largest-overlap spatial join), then tabulates agreement.

## Usage

``` r
compare_fuel_typing(bcwsft_sf, provincial_sf)
```

## Arguments

- bcwsft_sf:

  `sf` with a `FUEL_TYPE_CD` column from
  [`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md).

- provincial_sf:

  `sf` with a `FUEL_TYPE_CD` column (a provincial fuel-types layer).

## Value

A list with `confusion` (table), `agreement` (proportion of matched
polygons), and `n` (number of compared polygons).

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
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

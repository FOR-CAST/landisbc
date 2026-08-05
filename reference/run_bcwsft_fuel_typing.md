# Run the bcwsft R port over a VRI sf and attach the assigned FBP fuel type

Run the bcwsft R port over a VRI sf and attach the assigned FBP fuel
type

## Usage

``` r
run_bcwsft_fuel_typing(vri, season = "growing", current_year = NULL)
```

## Arguments

- vri:

  `sf` of VRI polygons (from
  [`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md)).

- season:

  `"growing"` or `"dormant"`.

- current_year:

  Integer reference year (defaults to the current year).

## Value

`vri` with added `FUEL_TYPE_CD` (factor, normalised to the provincial
vocabulary via
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md))
and `bcwsft_branch` columns.

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
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md)

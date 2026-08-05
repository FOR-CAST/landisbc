# Pull the VRI attributes the bcwsft decision tree needs, over a study area

Queries the VEG_COMP Rank 1 layer, which carries every bcwsft input
attribute directly (including `BEC_ZONE_CODE`, `BEC_SUBZONE` and
`COAST_INTERIOR_CD`), so no separate BEC spatial join is needed. The WFS
query is done in BC Albers (EPSG:3005) – the WFS cannot interpret a
custom simulation CRS – and the result is reprojected back to the
study-area CRS.

## Usage

``` r
get_vri_for_fuel_typing(study_area)
```

## Arguments

- study_area:

  `sf` or `SpatVector` study-area polygon (typically the buffered
  simulation area).

## Value

An `sf` of VRI polygons carrying (at least)
[`bcwsft::bcwsft_input_columns`](https://rdrr.io/pkg/bcwsft/man/bcwsft_input_columns.html).

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
[`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md),
[`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md),
[`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md),
[`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md),
[`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md),
[`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md),
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

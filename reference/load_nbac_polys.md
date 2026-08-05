# Load NBAC fire perimeters, harmonised + clipped to a study area

Loads National Burned Area Composite (NBAC) fire perimeters and
harmonises them to the NFDB-poly schema used downstream: `SIZE_HA` is
taken from the adjusted burned area (NBAC's canonical burned-area
figure, excluding unburned islands/water) and `YEAR` from the NBAC year
field. Both the year and the burned-area columns are detected tolerantly
(year: `YEAR` or `FIRE_YEAR`; area: `ADJ_HA`, `POLY_HA`, or `HECTARES`),
so the loader works across NBAC vintages and across the BC_HRV and
gitanyow-partial-harvest projects. Filtered to the fire years and
`SIZE_HA >= 1` ha, projected + clipped to the study area.

## Usage

``` r
load_nbac_polys(nbac_shp, study_area_path, fire_years)
```

## Arguments

- nbac_shp:

  Path to the NBAC polygon shapefile.

- study_area_path:

  Path to the study-area vector (defines the clip geometry + output
  CRS).

- fire_years:

  Integer vector of fire years to keep.

## Value

A `SpatVector` of NBAC perimeters clipped to the study area, in the
study-area CRS, carrying harmonised `YEAR` + `SIZE_HA` columns.

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
[`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md),
[`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md),
[`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md),
[`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md),
[`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md),
[`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md),
[`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md),
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

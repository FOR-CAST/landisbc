# Load NFDB fire polygons, filtered + clipped to a study area

Loads National Fire DataBase (NFDB) fire polygons via
[`fireregimetools::load_nfdb_polys()`](https://rdrr.io/pkg/fireregimetools/man/load_nfdb_polys.html)
– which binds the record's multi-year partitions, tolerates the
year/size column differences between release vintages, repairs invalid
geometries, filters to the fire years and `min_size_ha`, and projects +
clips to the study area – and adds the `JULIAN_DAY` column the seasonal
splits key on.

## Usage

``` r
load_nfdb_polys(nfdb_shp, study_area_path, fire_years, min_size_ha = 1)
```

## Arguments

- nfdb_shp:

  Character vector of NFDB polygon shapefile path(s) (the NFDB poly
  record ships multiple multi-year partitions).

- study_area_path:

  Path to the study-area vector (defines the clip geometry + output
  CRS).

- fire_years:

  Integer vector of fire years to keep.

- min_size_ha:

  Minimum reported fire size in hectares to keep (default `1`); records
  with a missing (`NA`) size are kept regardless.

## Value

A `SpatVector` of NFDB polygons clipped to the study area, in the
study-area CRS.

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
[`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md),
[`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md),
[`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md),
[`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)

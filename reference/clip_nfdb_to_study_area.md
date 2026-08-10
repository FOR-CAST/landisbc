# Clip national NFDB fire points to a study area

Projects NFDB points to a study-area rasterToMatch CRS and keeps those
falling on its ACTIVE (non-`NA`) cells.

## Usage

``` r
clip_nfdb_to_study_area(nfdb_points, rtm_path)
```

## Arguments

- nfdb_points:

  A `SpatVector` of NFDB points, or a path to read with
  [`terra::vect()`](https://rspatial.github.io/terra/reference/vect.html).

- rtm_path:

  Path to the study-area rasterToMatch (defines the CRS and, through its
  non-`NA` cells, the study area).

## Value

A `SpatVector` of NFDB points within the study area, in the
rasterToMatch CRS.

## Details

Restricting to the extent is not the same thing and is not enough: a
rasterToMatch is rectangular, a study area is not, and the gap between
the two is whatever the bounding box adds around an irregular boundary –
for a typical natural-resource district, over a third of the box. Since
this feeds observed targets for fire calibration, admitting that surplus
inflates every rate derived from it while looking entirely plausible.
This function previously cropped to the extent alone.

Takes the active mask from `NA`, which is the rasterToMatch convention.
Note this differs from a LANDIS-II fire-ecoregions map, where inactive
cells carry the reserved code `0` instead – see
[`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md).

## See also

Other BC fire and fuel data:
[`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md),
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

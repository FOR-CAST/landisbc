# Load NBAC fire perimeters, harmonised + clipped to a study area

A thin pass-through to
[`fireregimetools::load_nbac_polys()`](https://rdrr.io/pkg/fireregimetools/man/load_nbac_polys.html),
kept so BC projects reach the whole fire-record set through one package.
That loader harmonises NBAC to the `YEAR` + `SIZE_HA` schema used
downstream (`SIZE_HA` from the adjusted burned area, NBAC's canonical
figure excluding unburned islands/water), tolerating the year and
burned-area column differences between vintages, and filters, projects +
clips to the study area. Nothing BC-specific is added on top, unlike the
two NFDB loaders here.

## Usage

``` r
load_nbac_polys(nbac_shp, study_area_path, fire_years, min_size_ha = 1)
```

## Arguments

- nbac_shp:

  Path to the NBAC polygon shapefile.

- study_area_path:

  Path to the study-area vector (defines the clip geometry + output
  CRS).

- fire_years:

  Integer vector of fire years to keep.

- min_size_ha:

  Minimum reported fire size in hectares to keep (default `1`); records
  with a missing (`NA`) size are kept regardless.

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

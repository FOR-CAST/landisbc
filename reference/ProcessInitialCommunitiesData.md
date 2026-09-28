# Convert the VRI–grid intersection to a (MapCode, SpeciesCode, Age) data frame

Removes sliver polygons below SliverThreshold % of a full cell area,
bins ages to the nearest AgeBinSize midpoint, standardises species codes
via
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md)
using the supplied `species_mapping`, drops absent or zero-age records,
and deduplicates.

## Usage

``` r
ProcessInitialCommunitiesData(
  InitialCommunitiesData,
  AgeBinSize,
  grid_size,
  SliverThreshold,
  species_mapping = species_map_bc_vri,
  n_species = 2L,
  missing_age = c("drop", "leading")
)
```

## Arguments

- InitialCommunitiesData:

  SpatVector from CreateInitialCommunitiesData().

- AgeBinSize:

  Age bin width in years (e.g. 20).

- grid_size:

  Cell side length in metres (used to compute sliver threshold).

- SliverThreshold:

  Minimum intersecting area as % of one full cell (e.g. 5).

- species_mapping:

  Named character vector passed through to
  [`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md).
  Names are raw VRI codes; values are the cleaned target codes that
  appear in the study area's LANDIS-II `species.txt`. Defaults to the
  province-wide
  [species_map_bc_vri](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md);
  layer study-area-specific lumping on top via a named-vector merge.

- n_species:

  Number of species/age field pairs to detect (default 2).

- missing_age:

  What to do with a species listed after the leading one without an age
  of its own (`PROJ_AGE_N` missing or zero). `"drop"` (the default, and
  the original Python tool's behaviour) discards it. `"leading"` gives
  it the leading species' age. BC VRI records ages for the first two
  species only; in one extract examined, `PROJ_AGE_2` was blank for most
  second species and, where recorded, almost always equal to
  `PROJ_AGE_1`, so `"drop"` removed the second species from three stands
  in four. The leading species itself is dropped when its own age is
  missing, under either setting.

## Value

data.frame with columns: MapCode (character), SpeciesCode, Age
(integer).

## See also

Other BC VRI to LANDIS-II initial communities:
[`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
[`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md),
[`CreateInitialCommunitiesCSVFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesCSVFile.md),
[`CreateInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesData.md),
[`CreateInitialCommunitiesMap()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesMap.md),
[`CreateInitialCommunitiesTextFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesTextFile.md),
[`CreateLandisFiles()`](https://for-cast.github.io/landisbc/reference/CreateLandisFiles.md),
[`CreateLandisGrid()`](https://for-cast.github.io/landisbc/reference/CreateLandisGrid.md),
[`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md),
[`GetNonVegData()`](https://for-cast.github.io/landisbc/reference/GetNonVegData.md),
[`MapCodeDataHash()`](https://for-cast.github.io/landisbc/reference/MapCodeDataHash.md),
[`MergeVRI1andVRI2Data()`](https://for-cast.github.io/landisbc/reference/MergeVRI1andVRI2Data.md),
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

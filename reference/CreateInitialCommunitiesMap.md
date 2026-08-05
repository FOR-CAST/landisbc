# Write the LANDIS-II initial communities raster

Applies canonical clean codes and non-veg codes (6000–8000) to grid
cells, then rasterizes to an INT4S GeoTIFF. Cells with no VRI data
default to 7000 (exposed land). The full fishnet template extent from
CreateLandisGrid() is used as the rasterization template.

## Usage

``` r
CreateInitialCommunitiesMap(
  LandisGrid,
  grid_size,
  InitialCommunitiesMap,
  dicNonVegMapCodes,
  dicCleanMapCodes
)
```

## Arguments

- LandisGrid:

  SpatVector from CreateLandisGrid().

- grid_size:

  Cell side length in metres.

- InitialCommunitiesMap:

  Output file path for the INT4S GeoTIFF.

- dicNonVegMapCodes:

  Named list from GetNonVegData().

- dicCleanMapCodes:

  Named list from CleanMapCodes().

## Value

Invisibly, the rasterized SpatRaster.

## See also

Other BC VRI to LANDIS-II initial communities:
[`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
[`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md),
[`CreateInitialCommunitiesCSVFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesCSVFile.md),
[`CreateInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesData.md),
[`CreateInitialCommunitiesTextFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesTextFile.md),
[`CreateLandisFiles()`](https://for-cast.github.io/landisbc/reference/CreateLandisFiles.md),
[`CreateLandisGrid()`](https://for-cast.github.io/landisbc/reference/CreateLandisGrid.md),
[`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md),
[`GetNonVegData()`](https://for-cast.github.io/landisbc/reference/GetNonVegData.md),
[`MapCodeDataHash()`](https://for-cast.github.io/landisbc/reference/MapCodeDataHash.md),
[`MergeVRI1andVRI2Data()`](https://for-cast.github.io/landisbc/reference/MergeVRI1andVRI2Data.md),
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

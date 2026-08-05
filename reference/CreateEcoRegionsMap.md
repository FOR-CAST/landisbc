# Write the LANDIS-II ecoregions raster

Finds the dominant BEC zone/subzone for each grid cell, assigns the
integer code from GetBECCodes() sequencing, and rasterizes to an INT2S
GeoTIFF. Non-vegetated cells and cells in dicNonVegMapCodes receive code
0 (inactive in LANDIS-II).

## Usage

``` r
CreateEcoRegionsMap(
  LandisGrid,
  BECFilePath,
  grid_size,
  EcoRegionsMap,
  dicNonVegMapCodes
)
```

## Arguments

- LandisGrid:

  SpatVector from CreateLandisGrid().

- BECFilePath:

  File path or c(dsn, layer) for the BEC polygon layer.

- grid_size:

  Cell side length in metres.

- EcoRegionsMap:

  Output file path for the INT2S GeoTIFF.

- dicNonVegMapCodes:

  Named list from GetNonVegData().

## Value

Invisibly, the rasterized SpatRaster.

## See also

Other BC VRI to LANDIS-II initial communities:
[`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
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
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

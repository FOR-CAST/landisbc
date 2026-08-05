# Create all LANDIS-II initial communities and ecoregions files

Main orchestrator. All file path arguments accept either a plain file
path string or c(dsn, layer) for geodatabase layers.

## Usage

``` r
CreateLandisFiles(
  StudyAreaFilePath,
  VRI1FilePath,
  VRI2FilePath,
  BECFilePath,
  grid_size,
  AgeBinSize,
  UseVRI2,
  SliverThreshold,
  InitialCommunitiesMap,
  InitialCommunitiesTxt,
  EcoRegionsMap,
  EcoRegionsTxt,
  species_mapping = species_map_bc_vri,
  n_species = 2L
)
```

## Arguments

- StudyAreaFilePath:

  File path or c(dsn, layer) for the study area polygon.

- VRI1FilePath:

  File path or c(dsn, layer) for the primary VRI layer.

- VRI2FilePath:

  File path or c(dsn, layer) for the secondary VRI layer (used if
  UseVRI2 = TRUE).

- BECFilePath:

  File path or c(dsn, layer) for the BEC polygon layer.

- grid_size:

  Grid cell side length in metres.

- AgeBinSize:

  Age bin width in years.

- UseVRI2:

  Logical; if TRUE VRI2 records are merged with VRI1.

- SliverThreshold:

  Minimum intersecting area as % of one full cell.

- InitialCommunitiesMap:

  Output path for the initial communities GeoTIFF.

- InitialCommunitiesTxt:

  Output path for the initial communities text file.

- EcoRegionsMap:

  Output path for the ecoregions GeoTIFF.

- EcoRegionsTxt:

  Output path for the ecoregions text file.

- species_mapping:

  Named character vector (raw VRI code -\> cleaned `species.txt` code)
  passed to
  [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md).
  Defaults to the province-wide
  [species_map_bc_vri](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md);
  layer study-area lumping on top.

- n_species:

  Number of species/age field pairs per VRI feature (default 2).

## Value

Invisibly NULL (writes four files as a side effect).

## See also

Other BC VRI to LANDIS-II initial communities:
[`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
[`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md),
[`CreateInitialCommunitiesCSVFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesCSVFile.md),
[`CreateInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesData.md),
[`CreateInitialCommunitiesMap()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesMap.md),
[`CreateInitialCommunitiesTextFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesTextFile.md),
[`CreateLandisGrid()`](https://for-cast.github.io/landisbc/reference/CreateLandisGrid.md),
[`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md),
[`GetNonVegData()`](https://for-cast.github.io/landisbc/reference/GetNonVegData.md),
[`MapCodeDataHash()`](https://for-cast.github.io/landisbc/reference/MapCodeDataHash.md),
[`MergeVRI1andVRI2Data()`](https://for-cast.github.io/landisbc/reference/MergeVRI1andVRI2Data.md),
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

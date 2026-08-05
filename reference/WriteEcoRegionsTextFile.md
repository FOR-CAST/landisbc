# Write the LANDIS-II ecoregions.txt input file

Materialises the LANDIS-II ecoregions.txt parameter file from the BEC
code lookup produced by
[`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md).

## Usage

``` r
WriteEcoRegionsTextFile(dicBECCodes, EcoRegionsTxt)
```

## Arguments

- dicBECCodes:

  Named integer vector from
  [`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md).

- EcoRegionsTxt:

  Output file path for the ecoregions.txt file.

## Value

Invisibly, the path written.

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
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

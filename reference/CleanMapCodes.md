# Assign canonical map codes, collapsing duplicate communities

Grid cells with identical species/age composition receive the same clean
code. Vegetated codes (\>= 10000) are renumbered starting at 10000;
non-vegetated codes (\< 10000) are preserved as-is.

## Usage

``` r
CleanMapCodes(InitialCommunitiesDataList)
```

## Arguments

- InitialCommunitiesDataList:

  data.frame from ProcessInitialCommunitiesData() or
  MergeVRI1andVRI2Data(), with columns MapCode, SpeciesCode, Age.

## Value

Named list mapping original MapCode (character keys) to canonical
integer codes.

## See also

Other BC VRI to LANDIS-II initial communities:
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
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

# Canonical hash of (SpeciesCode, Age) pairs within one map code

Returns a stable string used to deduplicate map codes whose species/age
composition is identical. Equivalent to `MapCodeDataHash()` in the
original Python `LandisSupportFunctions.py`.

## Usage

``` r
MapCodeDataHash(mapcode_data)
```

## Arguments

- mapcode_data:

  data.frame with SpeciesCode and Age columns.

## Value

Character scalar. Newline-separated, tab-delimited sorted pairs.

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
[`MergeVRI1andVRI2Data()`](https://for-cast.github.io/landisbc/reference/MergeVRI1andVRI2Data.md),
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md),
[`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

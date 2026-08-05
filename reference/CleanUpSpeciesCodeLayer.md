# Standardise BC VRI species code variants against a user-supplied mapping

Looks up a Province of BC VRI `SPECIES_CD_N` code (e.g. `"HW"`, `"PLI"`,
`"SXS"`) in a user-supplied named-character mapping and returns the
cleaned LANDIS-II species.txt code. Codes not in the mapping trigger an
informative [`stop()`](https://rdrr.io/r/base/stop.html) so unknown
codes fail loudly at IC build time, not at LANDIS-II sim time. `NA`,
`""`, and the literal string `"NA"` return `""` so VRI rows without a
second species drop cleanly downstream.

## Usage

``` r
CleanUpSpeciesCodeLayer(SpeciesCode, mapping)
```

## Arguments

- SpeciesCode:

  Character scalar. One raw VRI species code.

- mapping:

  Named character vector. Names are raw VRI codes (e.g. `"HW"`,
  `"PLI"`); values are the cleaned target codes that appear in the
  LANDIS-II `species.txt` for the study area (e.g. `"Hw"`, `"Pl"`).

## Value

Character scalar. Either the cleaned code or `""` for NA / empty.

## Details

Pass
[species_map_bc_vri](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)
(the province-wide one-to-one VRI code normalisation) as `mapping`,
optionally layered with study-area-specific lumping via a named-vector
merge (see
[species_map_bc_vri](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)
for the structure, or `c(landisbc::species_map_bc_vri, <new codes>)` to
override or extend it for a particular study area's `species.txt`).

## See also

[species_map_bc_vri](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)

Other BC VRI to LANDIS-II initial communities:
[`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
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

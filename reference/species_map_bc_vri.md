# BC VRI species code -\> canonical Title-case form (one-to-one)

Named character vector mapping Province of BC Vegetation Resource
Inventory (VRI) `SPECIES_CD_N` codes to their Title-case canonical form.
The mapping is strictly one-to-one – each raw VRI code (e.g. `"HW"`,
`"PLI"`, `"SXS"`) maps to its own distinct Title-case form (`"Hw"`,
`"Pli"`, `"Sxs"`). No species-variant lumping or trait-group
substitution is done here; that information is preserved so consuming
projects can decide how to handle each variant based on their study
area's LANDIS-II `species.txt`.

## Usage

``` r
species_map_bc_vri
```

## Format

Named `character` vector of length 30 (currently). Names are raw VRI
`SPECIES_CD_N` codes (uppercase); values are the Title-case canonical
form.

## Source

Province of British Columbia tree species codes,
<https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/tree-seed/tree-seed-centre/seed-testing/codes>

## Details

Each entry carries an inline common-name comment. Names marked `(BC)`
are the `Description` field of the Province of BC tree species code
list; the remainder are genus-level or unspecified VRI codes that the
provincial list does not enumerate, and their names are informational
only. Take care with the broadleaf codes in particular: `DR` is red
alder (*Alnus rubra*), NOT a Douglas-fir code, and `SXS` is a Sitka
hybrid rather than an interior-spruce hybrid.

Pass this map directly to
[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md)
/
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md)
only if your study area has a `species.txt` slot for every Title-case
form here. In practice every study area collapses some variants (e.g.
`PLI`/`PLC` -\> `Pl`; lumping `Lw` / `Fd` into trait-group equivalents
when those species are absent from the local `species.txt`). Layer those
decisions on top via a named-vector merge in the consuming project,
keeping the rationale as inline comments where the decisions are made:

    ## In a consuming project's target / R script:
    vri_species_mapping <- c(
      landisbc::species_map_bc_vri,

      ## ---- study-area-specific lumping (overrides above) ----
      ## Western larch -> Pl: no Larix slot in species.txt; closest
      ## trait-group is the fire-adapted conifer Pinus contorta.
      LW = "Pl",

      ## Douglas-fir -> Bl: no Pseudotsuga slot in species.txt.
      FD = "Bl",

      ## ... etc, with one comment per decision so reviewers see the WHY.
    )

This separation keeps biological provenance intact in the package (you
can always inspect `species_map_bc_vri` to see the original VRI codes),
while making study-area-specific modelling decisions first-class
artifacts in their consuming projects where they can be reviewed
alongside the rest of the study-area parameterisation.

## See also

[`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
[`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md)

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
[`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md)

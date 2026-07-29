## Exported BC VRI species code mapping table. Consumed by
## [CleanUpSpeciesCodeLayer()] / [ProcessInitialCommunitiesData()] via
## their `mapping` / `species_mapping` argument.
##
## This table is intentionally a strict one-to-one normalisation: each VRI
## `SPECIES_CD_N` code maps to its own Title-case canonical form. NO
## species variants are lumped here, because the choice of which biological
## variants to collapse together is study-area specific (it depends on
## which species are present in that study area's LANDIS-II `species.txt`).
## Study-area-specific lumping decisions and their rationale belong in
## the consuming project, layered on top of this map via a named-vector
## merge -- see the `?species_map_bc_vri` examples below.

#' BC VRI species code -> canonical Title-case form (one-to-one)
#'
#' Named character vector mapping Province of BC Vegetation Resource
#' Inventory (VRI) `SPECIES_CD_N` codes to their Title-case canonical
#' form. The mapping is strictly one-to-one -- each raw VRI code (e.g.
#' `"HW"`, `"PLI"`, `"SXS"`) maps to its own distinct Title-case form
#' (`"Hw"`, `"Pli"`, `"Sxs"`). No species-variant lumping or
#' trait-group substitution is done here; that information is preserved
#' so consuming projects can decide how to handle each variant based on
#' their study area's LANDIS-II `species.txt`.
#'
#' Each entry carries an inline common-name comment. Names marked `(BC)`
#' are the `Description` field of the Province of BC tree species code
#' list; the remainder are genus-level or unspecified VRI codes that the
#' provincial list does not enumerate, and their names are informational
#' only. Take care with the broadleaf codes in particular: `DR` is red
#' alder (*Alnus rubra*), NOT a Douglas-fir code, and `SXS` is a Sitka
#' hybrid rather than an interior-spruce hybrid.
#'
#' Pass this map directly to [CleanUpSpeciesCodeLayer()] /
#' [ProcessInitialCommunitiesData()] only if your study area has a
#' `species.txt` slot for every Title-case form here. In practice every
#' study area collapses some variants (e.g. `PLI`/`PLC` -> `Pl`; lumping
#' `Lw` / `Fd` into trait-group equivalents when those species are absent
#' from the local `species.txt`). Layer those decisions on top via a
#' named-vector merge in the consuming project, keeping the rationale
#' as inline comments where the decisions are made:
#'
#' ```r
#' ## In a consuming project's target / R script:
#' vri_species_mapping <- c(
#'   landisbc::species_map_bc_vri,
#'
#'   ## ---- study-area-specific lumping (overrides above) ----
#'   ## Western larch -> Pl: no Larix slot in species.txt; closest
#'   ## trait-group is the fire-adapted conifer Pinus contorta.
#'   LW = "Pl",
#'
#'   ## Douglas-fir -> Bl: no Pseudotsuga slot in species.txt.
#'   FD = "Bl",
#'
#'   ## ... etc, with one comment per decision so reviewers see the WHY.
#' )
#' ```
#'
#' This separation keeps biological provenance intact in the package
#' (you can always inspect `species_map_bc_vri` to see the original VRI
#' codes), while making study-area-specific modelling decisions
#' first-class artifacts in their consuming projects where they can be
#' reviewed alongside the rest of the study-area parameterisation.
#'
#' @format Named `character` vector of length 30 (currently). Names are
#'   raw VRI `SPECIES_CD_N` codes (uppercase); values are the
#'   Title-case canonical form.
#' @source Province of British Columbia tree species codes,
#'   <https://www2.gov.bc.ca/gov/content/industry/forestry/managing-our-forest-resources/tree-seed/tree-seed-centre/seed-testing/codes>
#' @family BC VRI to LANDIS-II initial communities
#' @seealso [CleanUpSpeciesCodeLayer()], [ProcessInitialCommunitiesData()]
#' @export
species_map_bc_vri <- c(
  ## Broadleaf
  ## Common names marked (BC) are the Description field of the Province of BC
  ## tree species code list; the rest are unlisted VRI genus-level codes.
  AC = "Ac", ## poplar (BC)
  ACB = "Acb", ## balsam poplar (not in the BC list)
  ACT = "Act", ## black cottonwood (BC)
  AT = "At", ## trembling aspen (BC)
  DR = "Dr", ## red alder (BC) -- Alnus rubra, NOT a Douglas-fir code
  E = "E", ## birch, unspecified (not in the BC list)
  EP = "Ep", ## paper birch (BC)
  MB = "Mb", ## bigleaf maple (BC)

  ## Conifers -- firs
  B = "B", ## fir, unspecified (not in the BC list)
  BA = "Ba", ## amabilis fir (BC)
  BL = "Bl", ## subalpine fir (BC)

  ## Conifers -- cedar
  CW = "Cw", ## western redcedar (BC)

  ## Conifers -- Douglas-fir
  FD = "Fd", ## Douglas-fir, unspecified (not in the BC list; cf. FDC / FDI)
  FDI = "Fdi", ## Douglas-fir, interior (BC)

  ## Conifers -- hemlocks
  H = "H", ## hemlock, unspecified (not in the BC list)
  HM = "Hm", ## mountain hemlock (BC)
  HW = "Hw", ## western hemlock (BC)

  ## Conifers -- larches
  LA = "La", ## alpine larch (BC)
  LT = "Lt", ## tamarack (BC)
  LW = "Lw", ## western larch (BC)

  ## Conifers -- pines
  PL = "Pl", ## lodgepole pine, unspecified (not in the BC list; cf. PLC / PLI)
  PLC = "Plc", ## lodgepole pine, coast (BC)
  PLI = "Pli", ## lodgepole pine, interior (BC)

  ## Conifers -- spruces
  S = "S", ## spruce, unspecified (not in the BC list)
  SA = "Sa", ## spruce, unspecified variant (not in the BC list)
  SE = "Se", ## Engelmann spruce (not in the BC list)
  SS = "Ss", ## Sitka spruce (BC)
  SW = "Sw", ## white spruce (not in the BC list)
  SX = "Sx", ## spruce hybrid (BC)
  SXS = "Sxs" ## Sitka x unknown hybrid (BC)
)

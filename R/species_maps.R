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
#' @family BC VRI to LANDIS-II initial communities
#' @seealso [CleanUpSpeciesCodeLayer()], [ProcessInitialCommunitiesData()]
#' @export
species_map_bc_vri <- c(
  ## Broadleaf
  AC = "Ac", ## black cottonwood
  ACB = "Acb", ## black cottonwood variant
  ACT = "Act", ## black cottonwood variant
  AT = "At", ## trembling aspen
  E = "E", ## generic birch
  EP = "Ep", ## paper birch
  MB = "Mb", ## bigleaf maple

  ## Conifers -- firs
  B = "B", ## generic / unspecified fir
  BA = "Ba", ## amabilis fir
  BL = "Bl", ## subalpine fir

  ## Conifers -- cedar
  CW = "Cw", ## western redcedar

  ## Conifers -- Douglas-fir
  DR = "Dr", ## Douglas-fir variant
  FD = "Fd", ## Douglas-fir
  FDI = "Fdi", ## interior Douglas-fir

  ## Conifers -- hemlocks
  H = "H", ## generic / unspecified hemlock
  HM = "Hm", ## mountain hemlock
  HW = "Hw", ## western hemlock

  ## Conifers -- larches
  LA = "La", ## alpine larch
  LT = "Lt", ## tamarack
  LW = "Lw", ## western larch

  ## Conifers -- pines
  PL = "Pl", ## lodgepole pine
  PLC = "Plc", ## coastal lodgepole pine
  PLI = "Pli", ## interior lodgepole pine

  ## Conifers -- spruces
  S = "S", ## generic / unspecified spruce
  SA = "Sa", ## spruce variant
  SE = "Se", ## Engelmann spruce
  SS = "Ss", ## Sitka spruce
  SW = "Sw", ## spruce variant
  SX = "Sx", ## interior spruce (Engelmann x white hybrid)
  SXS = "Sxs" ## interior spruce hybrid variant
)

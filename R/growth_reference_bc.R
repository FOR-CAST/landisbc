## Internal typed-CSV reader, so the reference tables coerce their numeric
## columns without the caller having to.
.read_typed_csv <- function(path, integer = character(0), numeric = character(0)) {
  utils::read.csv(path, stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    dplyr::mutate(
      dplyr::across(dplyr::any_of(integer), as.integer),
      dplyr::across(dplyr::any_of(numeric), as.numeric)
    )
}

#' Read the TIPSY yield curves
#'
#' Values are Mg C ha^-1; see the units note in
#' `params/forcs/growth_reference/tipsy_run_metadata.csv`.
#'
#' @param path Character. Path to `tipsy_curves.csv`.
#'
#' @return A tibble with `series_id`, `species`, `bec_group`, `age`, `value`.
#' @export
read_tipsy_curves <- function(path) {
  .read_typed_csv(path, integer = "age", numeric = "value") |>
    dplyr::select(series_id, species, bec_group, age, value)
}

#' Read the TIPSY per-series metadata
#'
#' @param path Character. Path to `tipsy_series.csv`.
#'
#' @return A tibble, one row per series.
#' @export
read_tipsy_series <- function(path) {
  .read_typed_csv(path, integer = "planting_sph", numeric = "site_index") |>
    dplyr::select(series_id, species, tipsy_species, bec_group, planting_sph, site_index)
}

#' Read the Kivari volume-to-biomass conversion factors
#'
#' Subalpine and amabilis fir share one coefficient set, stored as `Ba_Bl`.
#'
#' @param path Character. Path to `kivari_volume_to_biomass.csv`.
#'
#' @return A tibble with `species_group` and the five component factors.
#' @export
read_kivari_coef <- function(path) {
  .read_typed_csv(path, numeric = c("bole", "branches", "bark", "foliage", "total")) |>
    dplyr::select(species_group, bole, branches, bark, foliage, total)
}

#' Map a modelled species code to its Kivari coefficient group
#'
#' @param species Character vector of modelled species codes.
#'
#' @return Character vector of `species_group` values, `NA` where no factor applies.
#' @export
kivari_species_group <- function(species) {
  ## Ba and Bl share the single fir coefficient set. Cw has no Kivari row --
  ## the published table covers At, Ba/Bl, Hw, Pl, and Sx only.
  dplyr::case_when(
    species %in% c("Ba", "Bl") ~ "Ba_Bl",
    species %in% c("At", "Hw", "Pl", "Sx") ~ species,
    .default = NA_character_
  )
}

## ---- BC ground-plot ("PSP") data ----------------------------------------------------------------
##
## Source: BC Data Catalogue record 824e684b-4114-4a05-a490-aa56332b57f4,
## "Forest Inventory Ground Plot Data and Interactive Map", Forest Analysis and
## Inventory Branch, under the Open Government Licence - British Columbia.
##
## The data are published on an FTP tree rather than as a BCGW layer, so `bcdata`
## resolves and cites the catalogue record while the tables are fetched by URL.
##
## Two compilations, with different layouts:
##   non_psp/publish_by_tsa/<TSA>/   CMI, YSM, NFI and VRI plots, partitioned by
##                                   TSA (~50 KB per table)
##   psp/                            PSP plots, province-wide flat files
## `faib_tree_detail.csv` (740 MB in the PSP compilation) is never fetched: the
## plot-level summaries carry everything the calibration needs.

.faib_record_id <- "824e684b-4114-4a05-a490-aa56332b57f4"

.faib_ftp_root <- paste0(
  "https://www.for.gov.bc.ca/ftp/HTS/external/!publish/ground_plot_compilations"
)

## The four tables that together reconstruct a plot-visit record, joined on
## SITE_IDENTIFIER / CLSTR_ID.
.faib_tables <- c(
  "faib_header",
  "faib_sample_byvisit",
  "faib_compiled_smries",
  "faib_compiled_spcsmries_siteage"
)

## Timber Supply Areas covering the Lax'yip and its surrounds. Kispiox holds the
## ICHmc plots the calibration is anchored on; the other three supplement it.
##
## The supplement is NOT optional. Usable observations per modelled species,
## Kispiox alone vs all four TSAs (plots, and plots older than 150 years):
##
##   species   Kispiox    >150yr      all four   >150yr
##   At         66          0          102         0
##   Ba          0          0           64         8
##   Bl         21          7          158        79
##   Hw        151         11          342        73
##   Pl        115          0          154         4
##   Sx         21          0           59        10
##
## Restricting to Kispiox drops amabilis fir entirely, and removes every
## old-forest observation for spruce and pine -- precisely the part of the curve
## the report already flags as weakly constrained. Narrowing further to Kispiox
## ICH leaves subalpine fir with 8 plots, none older than 116 years.
.faib_tsas <- c("Kispiox TSA", "Kalum TSA", "Bulkley TSA", "Nass TSA")

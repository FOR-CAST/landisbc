## bcwsft fuel-typing cross-check helpers (BC-specific).
##
## Helpers for the bcwsft fuel-typing cross-check: an independent check on the
## map-derived provincial fuel types using the R port of the BC Wildfire Service
## fuel-typing decision tree, in the spirit of Baron et al. 2024. bcwsft is a
## SEPARATE GPL-3 package; we only call it via `bcwsft::` (never copy its
## source), and the call paths are guarded so this file loads without bcwsft
## installed -- the functions that use it only run when bcwsft is available.
##
## Provenance:
##   * De-duplicated from shared BC_HRV / gitanyow-partial-harvest code.

#' Pull the VRI attributes the bcwsft decision tree needs, over a study area
#'
#' Queries the VEG_COMP Rank 1 layer, which carries every bcwsft input attribute
#' directly (including `BEC_ZONE_CODE`, `BEC_SUBZONE` and `COAST_INTERIOR_CD`),
#' so no separate BEC spatial join is needed. The WFS query is done in BC Albers
#' (EPSG:3005) -- the WFS cannot interpret a custom simulation CRS -- and the
#' result is reprojected back to the study-area CRS.
#'
#' @param study_area `sf` or `SpatVector` study-area polygon (typically the
#'   buffered simulation area).
#'
#' @returns An `sf` of VRI polygons carrying (at least)
#'   `bcwsft::bcwsft_input_columns`.
#'
#' @family BC fire and fuel data
#' @export
get_vri_for_fuel_typing <- function(study_area) {
  if (inherits(study_area, "SpatVector")) {
    study_area <- sf::st_as_sf(study_area)
  }
  ## VEG_COMP Rank 1 layer. It carries every bcwsft input attribute directly -- including BEC_ZONE_CODE,
  ## BEC_SUBZONE and COAST_INTERIOR_CD -- so no separate BEC spatial join is needed (confirmed in
  ## gitanyow against bcdc_describe_feature(): all of bcwsft::bcwsft_input_columns are present).
  ## Query in BC Albers (the WFS cannot interpret a custom sim CRS); reproject the result back.
  sa_q <- sf::st_transform(study_area, 3005)
  bcdata::bcdc_query_geodata("2ebb35d8-c82f-4a17-9c96-612ac3532d55") |>
    dplyr::filter(bcdata::INTERSECTS(sa_q)) |>
    dplyr::select(dplyr::any_of(bcwsft::bcwsft_input_columns)) |>
    bcdata::collect() |>
    sf::st_transform(sf::st_crs(study_area)) |>
    sf::st_set_agr("constant") |>
    sf::st_crop(study_area)
}

#' Run the bcwsft R port over a VRI sf and attach the assigned FBP fuel type
#'
#' @param vri `sf` of VRI polygons (from [get_vri_for_fuel_typing()]).
#' @param season `"growing"` or `"dormant"`.
#' @param current_year Integer reference year (defaults to the current year).
#'
#' @returns `vri` with added `FUEL_TYPE_CD` (factor, normalised to the
#'   provincial vocabulary via [normalize_fbp_codes()]) and `bcwsft_branch`
#'   columns.
#'
#' @family BC fire and fuel data
#' @export
run_bcwsft_fuel_typing <- function(vri, season = "growing", current_year = NULL) {
  if (is.null(current_year)) {
    current_year <- as.integer(format(Sys.Date(), "%Y"))
  }
  attrs <- sf::st_drop_geometry(vri)

  ## Ensure every expected input column exists; bcwsft fills logic on NA.
  missing <- setdiff(bcwsft::bcwsft_input_columns, names(attrs))
  if (length(missing)) {
    attrs[missing] <- NA
  }

  ft <- bcwsft::bcwsft_fuel_type(
    attrs,
    season = season,
    current_year = current_year,
    on_error = "na" ## tolerate not-yet-ported branches while the port matures
  )

  vri$FUEL_TYPE_CD <- as.factor(normalize_fbp_codes(ft$fuel_type))
  vri$bcwsft_branch <- ft$branch
  vri
}

#' Collapse bcwsft season/leaf fuel-type codes to the provincial Public vocabulary
#'
#' bcwsft emits seasonal/structural leaves (D-1/D-2, M-1/M-2, O-1a/O-1b) that the
#' provincial layer reports aggregated (D-1/2, M-1/2, O-1a/b).
#'
#' @param x Character vector of bcwsft fuel-type codes.
#'
#' @returns A character vector with the seasonal/structural leaves collapsed to
#'   the aggregated provincial codes.
#'
#' @family BC fire and fuel data
#' @export
normalize_fbp_codes <- function(x) {
  dplyr::case_when(
    x %in% c("D-1", "D-2") ~ "D-1/2",
    x %in% c("M-1", "M-2") ~ "M-1/2",
    x %in% c("O-1a", "O-1b") ~ "O-1a/b",
    .default = x
  )
}

#' Confusion matrix and overall agreement between bcwsft and provincial fuel types
#'
#' Assigns each bcwsft polygon the provincial code it most overlaps
#' (largest-overlap spatial join), then tabulates agreement.
#'
#' @param bcwsft_sf `sf` with a `FUEL_TYPE_CD` column from
#'   [run_bcwsft_fuel_typing()].
#' @param provincial_sf `sf` with a `FUEL_TYPE_CD` column (a provincial
#'   fuel-types layer).
#'
#' @returns A list with `confusion` (table), `agreement` (proportion of
#'   matched polygons), and `n` (number of compared polygons).
#'
#' @family BC fire and fuel data
#' @export
compare_fuel_typing <- function(bcwsft_sf, provincial_sf) {
  ## Assign each bcwsft polygon the provincial code it most overlaps (largest-overlap join).
  ## TODO: consider area-weighting or a cell-wise comparison on the rasterToMatch to match the
  ## fuel_types_dist distribution reported in the fire report.
  prov <- provincial_sf[, "FUEL_TYPE_CD"]
  names(prov)[names(prov) == "FUEL_TYPE_CD"] <- "FUEL_TYPE_CD_prov"

  joined <- sf::st_join(bcwsft_sf, prov, largest = TRUE)

  bc <- as.character(joined$FUEL_TYPE_CD)
  pv <- as.character(joined$FUEL_TYPE_CD_prov)
  keep <- !is.na(bc) & !is.na(pv)

  confusion <- table(bcwsft = bc[keep], provincial = pv[keep])
  agreement <- if (sum(keep) > 0) mean(bc[keep] == pv[keep]) else NA_real_

  list(confusion = confusion, agreement = agreement, n = sum(keep))
}

#' Plot the fuel-typing confusion matrix as a heatmap
#'
#' Writes a PNG heatmap of the confusion matrix and returns its path.
#'
#' @param comparison Output of [compare_fuel_typing()].
#' @param out_path File path for the PNG.
#'
#' @returns The written PNG path (`out_path`), invisibly returned via the value.
#'
#' @family BC fire and fuel data
#' @export
plot_fuel_typing_comparison <- function(comparison, out_path) {
  df <- as.data.frame(comparison$confusion)
  gg <- ggplot2::ggplot(df, ggplot2::aes(x = provincial, y = bcwsft, fill = Freq)) +
    ggplot2::geom_tile() +
    ggplot2::geom_text(ggplot2::aes(label = Freq), size = 3) +
    tidyterra::scale_fill_whitebox_c("muted") +
    ggplot2::labs(
      x = "Provincial (BC Wildfire Public layer)",
      y = "bcwsft (R port of Perrakis et al. 2018)",
      title = sprintf(
        "Fuel-typing agreement: %.0f%% of %d polygons",
        100 * comparison$agreement,
        comparison$n
      )
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
  if (!dir.exists(dirname(out_path))) {
    dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  }
  ggplot2::ggsave(out_path, gg, width = 8, height = 6)
  out_path
}

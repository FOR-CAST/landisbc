#' Fetch BC Fire Burn Severity (Historical) polygons via bcdata
#'
#' Returns the Province of British Columbia's polygon-level burn-severity ratings
#' (one record per FIRE_NUMBER / FIRE_YEAR / BURN_SEVERITY_RATING combination)
#' for the requested fire years, clipped to `scope_polys`. Used to compute the
#' observed severity-class distribution for Dynamic Fire calibration via
#' [compute_observed_severity_dist()].
#'
#' Filters on `FIRE_YEAR %in% fire_years` server-side via bcdata's lazy geodata
#' query, so only polygons in the requested window are downloaded.
#'
#' **Spatial scope.** BC Fire Burn Severity is assessed only for fires with
#' usable pre/post-fire Landsat coverage, so its spatial coverage is much sparser
#' than fire perimeters. At a single study area's scale the window may yield only
#' a handful of assessed polygons -- too few for a representative distribution --
#' so `scope_polys` is typically the full fire-regime ecoregion(s) the study area
#' falls within (not the study area itself), giving a defensible regional
#' reference. BC severity coverage starts in 2015; earlier fire years contribute
#' no observed severity data.
#'
#' The bcdata source is the Province of BC "Fire Burn Severity (Historical)"
#' layer (Forests catalogue record `c58a54e5-76b7-4921-94a7-b5998484e697`,
#' object `WHSE_FOREST_VEGETATION.VEG_BURN_SEVERITY_SP`).
#'
#' @param scope_polys `sf` POLYGON in the project CRS (e.g. BC Albers) covering
#'   the fire-regime ecoregion(s) the calibration targets.
#' @param fire_years Integer vector of fire years.
#'
#' @returns An `sf` data frame with columns `FIRE_NUMBER`, `FIRE_YEAR`,
#'   `BURN_SEVERITY_RATING` (factor: Unburned / Low / Medium / High / Unknown)
#'   and polygon geometry clipped to `scope_polys`.
#'
#' @family BC fire severity
#' @export
get_bc_burn_severity_polys <- function(scope_polys, fire_years) {
  bcdata::bcdc_query_geodata("c58a54e5-76b7-4921-94a7-b5998484e697") |>
    dplyr::filter(INTERSECTS(scope_polys), FIRE_YEAR %in% fire_years) |>
    dplyr::select(FIRE_NUMBER, FIRE_YEAR, BURN_SEVERITY_RATING) |>
    dplyr::collect() |>
    sf::st_set_agr("constant") |>
    sf::st_crop(scope_polys) |>
    sf::st_transform(sf::st_crs(scope_polys)) |>
    dplyr::mutate(BURN_SEVERITY_RATING = as.factor(BURN_SEVERITY_RATING))
}

#' BC -> LANDIS Dynamic Fire severity-class mapping
#'
#' Returns the weights used by [compute_observed_severity_dist()] to map BC's
#' 4-class burn-severity scheme (Unburned, Low, Medium, High) onto LANDIS-II
#' Dynamic Fire's 5-class scheme (integers 1..5). "Unburned" is dropped --
#' simulated severities are only logged for burned cells, so the observed
#' reference must exclude unburned area.
#'
#' Mapping rationale: BC has 3 burned-class bins, LANDIS has 5, so each BC bin is
#' split across the LANDIS bins it brackets:
#' \itemize{
#'   \item Low -> 50% LANDIS-1 + 50% LANDIS-2
#'   \item Medium -> 100% LANDIS-3
#'   \item High -> 50% LANDIS-4 + 50% LANDIS-5
#' }
#' This trapezoid smoothing avoids hard zero bins in LANDIS classes 2 and 4
#' (which inflate the chi-squared loss artificially) while still respecting the
#' ordering of the BC classification.
#'
#' @returns Named list keyed by BC severity rating (Low / Medium / High); each
#'   element is a numeric vector of weights over LANDIS classes 1..5.
#'
#' @family BC fire severity
#' @export
bc_to_landis_severity_map <- function() {
  list(
    Low = c(0.5, 0.5, 0.0, 0.0, 0.0),
    Medium = c(0.0, 0.0, 1.0, 0.0, 0.0),
    High = c(0.0, 0.0, 0.0, 0.5, 0.5)
  )
}

#' Compute observed severity-class distribution for the calibration loss
#'
#' Computes the area-weighted distribution of BC severity ratings over the input
#' polygon set, drops "Unburned" / "Unknown", then projects onto LANDIS-II
#' Dynamic Fire's 5-class scheme via [bc_to_landis_severity_map()] and normalises
#' to sum to 1.
#'
#' The input is the full BC severity polygon set within the calibration scope
#' (typically the fire-regime ecoregion(s), not a single study area); no fire-
#' perimeter intersection is applied because BC severity is so sparse spatially
#' that intersecting at study-area scope collapses to a handful of polygons (see
#' [get_bc_burn_severity_polys()] for the scope rationale). The resulting
#' distribution is a regional reference for the ecoregion's historical fire
#' severity, not a study-area-specific one.
#'
#' @param burn_severity_polys `sf` object returned by
#'   [get_bc_burn_severity_polys()].
#'
#' @returns Named numeric vector of length 5 (names "1".."5") summing to 1. This
#'   is the format that `landisutils::save_observed_fire_targets()`'s
#'   `severity_dist` argument expects.
#'
#' @family BC fire severity
#' @export
compute_observed_severity_dist <- function(burn_severity_polys) {
  stopifnot(
    inherits(burn_severity_polys, "sf"),
    "BURN_SEVERITY_RATING" %in% names(burn_severity_polys)
  )

  bsp <- burn_severity_polys
  bsp$area_m2 <- as.numeric(sf::st_area(bsp))
  area_by_bc <- stats::aggregate(
    bsp$area_m2,
    by = list(rating = as.character(bsp$BURN_SEVERITY_RATING)),
    FUN = function(x) sum(x, na.rm = TRUE)
  )
  names(area_by_bc)[2L] <- "area_m2"

  ## Drop Unburned + Unknown -- simulated severities are only for burned cells.
  area_by_bc <- area_by_bc[
    !area_by_bc$rating %in% c("Unburned", "Unknown") & area_by_bc$area_m2 > 0,
    ,
    drop = FALSE
  ]
  if (nrow(area_by_bc) == 0L) {
    stop("compute_observed_severity_dist(): no burned area in burn_severity_polys.", call. = FALSE)
  }

  map <- bc_to_landis_severity_map()
  ## Distribute each BC class's burned area across LANDIS 1..5 via the mapping.
  weights <- vapply(
    seq_len(nrow(area_by_bc)),
    function(i) {
      rating <- area_by_bc$rating[i]
      if (!rating %in% names(map)) {
        stop(
          sprintf("compute_observed_severity_dist(): no LANDIS mapping for BC rating '%s'", rating),
          call. = FALSE
        )
      }
      map[[rating]] * area_by_bc$area_m2[i]
    },
    numeric(5L)
  )
  landis_area <- rowSums(weights)
  stopifnot(sum(landis_area) > 0)

  stats::setNames(landis_area / sum(landis_area), as.character(1:5))
}

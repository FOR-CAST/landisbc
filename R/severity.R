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
  ## Query the WFS in the layer CRS (EPSG:3005). bcdata's INTERSECTS falls back to the geometry's
  ## BOUNDING BOX for large scopes, and a non-3005 scope yields the wrong box -> a silent zero-feature
  ## result. Reproject the scope to 3005 for the query, then bring the result back to the scope CRS.
  scope_3005 <- sf::st_transform(scope_polys, 3005)
  result <- bcdata::bcdc_query_geodata("c58a54e5-76b7-4921-94a7-b5998484e697") |>
    dplyr::filter(INTERSECTS(scope_3005), FIRE_YEAR %in% fire_years) |>
    dplyr::select(FIRE_NUMBER, FIRE_YEAR, BURN_SEVERITY_RATING) |>
    dplyr::collect()
  ## An empty bcdata result collapses to a geometry-only sf (no attribute columns), so return an empty
  ## sf with the expected schema rather than erroring downstream on a missing BURN_SEVERITY_RATING.
  if (nrow(result) == 0L) {
    return(sf::st_sf(
      FIRE_NUMBER = character(0),
      FIRE_YEAR = integer(0),
      BURN_SEVERITY_RATING = factor(character(0)),
      geometry = sf::st_sfc(crs = sf::st_crs(scope_polys))
    ))
  }
  result |>
    sf::st_transform(sf::st_crs(scope_polys)) |>
    sf::st_set_agr("constant") |>
    sf::st_crop(scope_polys) |>
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

## CanLaBS v2 (Canada Landsat Burned Severity) integration --------------------
##
## CanLaBS v2 (Guindon, Correia & Perbet 2026; doi:10.23687/2af751e7-79f9-4da8-
## 9b45-14688818dca3) is a national 30 m Landsat dNBR product covering 1985-2024,
## built on NBAC perimeters and distributed under the Open Government Licence -
## Canada. It complements the BC Fire Burn Severity (Historical) layer, which is
## categorical (Low/Medium/High), BC-only, Access-Only, and starts in 2015.
##
## The integration follows "Option B": the continuous dNBR is thresholded into
## BC's three burned classes using breakpoints FIT so that CanLaBS reproduces the
## BC class-area fractions over the years both datasets cover (>= 2015), then the
## SAME breakpoints are applied over the full 1985-2024 record. The BC layer thus
## calibrates the thresholds; CanLaBS supplies the long, NBAC-consistent record
## the L_severity loss actually consumes. Because the breakpoints are empirical
## quantiles of the data's own dNBR distribution, this is invariant to whether the
## product stores raw or scaled (x1000) dNBR -- no absolute-scaling assumption is
## made. The resulting 3-class area is mapped onto LANDIS 1..5 via the existing
## [bc_to_landis_severity_map()] trapezoid kernel, so the observed-distribution
## contract is identical to [compute_observed_severity_dist()].

#' CanLaBS v2 layer filenames
#'
#' The three GeoTIFF layers distributed with CanLaBS v2 (national mosaic, Canada
#' Lambert Conformal Conic / NAD83). These are large; download once and cache
#' under `canlabs_dir` (as for the NBAC archive). The filenames embed the product
#' version date and may change on a future release -- override the `files`
#' argument of [get_canlabs_dnbr()] if so.
#'
#' @returns Named character vector with elements `dnbr`, `salvage`, `fireyear`.
#' @family CanLaBS fire severity
#' @export
canlabs_v2_files <- function() {
  c(
    dnbr = "CanLaBS_1985_2024_v20260121.tif",
    salvage = "CanLaBS_salvageMask_1985_2024_v20260121.tif",
    fireyear = "NBAC_MRB_1972to2024_reproj.tif"
  )
}

## Harmonise the NBAC year column across the naming variants the two projects use.
.nbac_year <- function(x) {
  cand <- c("FIRE_YEAR", "YEAR", "NFIREID_YEAR", "EODATE_YEAR")
  nm <- intersect(cand, names(x))
  if (length(nm) == 0L) {
    nm <- grep("year", names(x), ignore.case = TRUE, value = TRUE)
  }
  if (length(nm) == 0L) {
    stop(".nbac_year(): no year column found in nbac_polys.", call. = FALSE)
  }
  as.integer(x[[nm[1L]]])
}

## Accept either the list returned by fit_canlabs_thresholds() or a bare
## c(lowmed =, medhigh =) numeric vector.
.canlabs_thr <- function(thresholds) {
  thr <- if (is.list(thresholds)) thresholds$thresholds else thresholds
  stopifnot(all(c("lowmed", "medhigh") %in% names(thr)), thr[["lowmed"]] <= thr[["medhigh"]])
  thr
}

#' Load CanLaBS v2 dNBR over a scope, salvage-masked and year-filtered
#'
#' Reads the staged CanLaBS v2 GeoTIFFs, crops and masks the dNBR layer to
#' `scope_polys`, drops salvage-logged pixels, and (optionally) restricts to fires
#' in `fire_years`. Returns dNBR in the CanLaBS CRS (Canada Lambert / NAD83);
#' reprojecting the small scope polygon into the raster CRS avoids resampling the
#' national mosaic.
#'
#' Year filtering uses the caller's NBAC perimeters (a known year column) rather
#' than the CanLaBS fire-year raster, whose pixel encoding is not documented in the
#' product readme; pass the project's NBAC polygons as `nbac_polys`.
#'
#' @param canlabs_dir Directory holding the staged CanLaBS v2 GeoTIFFs.
#' @param scope_polys `sf`/`sfc` scope (e.g. the fire-regime polygons).
#' @param nbac_polys `sf` NBAC perimeters with a year column; required if
#'   `fire_years` is used for temporal filtering.
#' @param fire_years Integer vector of years to keep, or `NULL` for all.
#' @param drop_salvage Logical; if `TRUE` (default) sets salvage-logged pixels
#'   (mask value 1) to `NA`.
#' @param files Named character vector of layer filenames; see [canlabs_v2_files()].
#'
#' @returns A single-layer `terra` `SpatRaster` (`dNBR`) in the CanLaBS CRS.
#' @family CanLaBS fire severity
#' @export
get_canlabs_dnbr <- function(
  canlabs_dir,
  scope_polys,
  nbac_polys = NULL,
  fire_years = NULL,
  drop_salvage = TRUE,
  files = canlabs_v2_files()
) {
  ## Tolerate terra SpatVector inputs (both projects store perimeters that way).
  if (inherits(scope_polys, "SpatVector")) {
    scope_polys <- sf::st_as_sf(scope_polys)
  }
  if (inherits(nbac_polys, "SpatVector")) {
    nbac_polys <- sf::st_as_sf(nbac_polys)
  }
  stopifnot(inherits(scope_polys, c("sf", "sfc")))
  dnbr_path <- file.path(canlabs_dir, files[["dnbr"]])
  if (!file.exists(dnbr_path)) {
    stop(
      sprintf(
        paste0(
          "get_canlabs_dnbr(): CanLaBS dNBR not found at '%s'.\n",
          "Stage the CanLaBS v2 GeoTIFFs (%s) under `canlabs_dir` first ",
          "(national mosaic, large -- download once and cache).\n",
          "Source: doi:10.23687/2af751e7-79f9-4da8-9b45-14688818dca3"
        ),
        dnbr_path,
        paste(unname(files), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  dnbr <- terra::rast(dnbr_path)

  ## Reproject the (small) scope into the raster CRS, then crop + mask.
  scope_v <- terra::project(terra::vect(scope_polys), dnbr)
  dnbr <- terra::mask(terra::crop(dnbr, scope_v), scope_v)

  ## Drop salvage-logged pixels (mask layer: 1 = salvage) so post-fire logging
  ## does not contaminate the severity reference.
  if (isTRUE(drop_salvage)) {
    salv <- terra::crop(terra::rast(file.path(canlabs_dir, files[["salvage"]])), dnbr)
    if (!terra::compareGeom(salv, dnbr, stopOnError = FALSE)) {
      salv <- terra::resample(salv, dnbr, method = "near")
    }
    dnbr <- terra::mask(dnbr, salv, maskvalues = 1)
  }

  ## Restrict to fires in `fire_years` via the caller's NBAC perimeters.
  if (!is.null(fire_years) && !is.null(nbac_polys)) {
    yr <- .nbac_year(nbac_polys)
    keep <- sf::st_geometry(nbac_polys[!is.na(yr) & yr %in% fire_years, ])
    if (length(keep) == 0L) {
      stop("get_canlabs_dnbr(): no NBAC perimeters in `fire_years`.", call. = FALSE)
    }
    dnbr <- terra::mask(dnbr, terra::project(terra::vect(keep), dnbr))
  }

  names(dnbr) <- "dNBR"
  dnbr
}

#' Fit dNBR thresholds that reproduce BC's burned-class area fractions
#'
#' The "Option B" calibration step: computes the area fractions of BC's Low /
#' Medium / High burned classes, extracts the CanLaBS dNBR values inside the
#' BC-assessed polygons (the 2015+ overlap window, by construction), and returns
#' the two dNBR breakpoints whose quantiles reproduce those fractions. Higher dNBR
#' is taken to mean higher severity, so ascending dNBR quantiles align with Low <
#' Medium < High.
#'
#' @param canlabs_dnbr `SpatRaster` from [get_canlabs_dnbr()] (scope-level).
#' @param bc_polys `sf` BC burn-severity polygons from [get_bc_burn_severity_polys()].
#'
#' @returns A list with `thresholds` (named numeric `c(lowmed =, medhigh =)`),
#'   `bc_fractions` (the Low/Medium/High area fractions used), and `n_pixels`.
#' @family CanLaBS fire severity
#' @export
fit_canlabs_thresholds <- function(canlabs_dnbr, bc_polys) {
  stopifnot("BURN_SEVERITY_RATING" %in% names(bc_polys))
  burned <- bc_polys[as.character(bc_polys$BURN_SEVERITY_RATING) %in% c("Low", "Medium", "High"), ]
  if (nrow(burned) == 0L) {
    stop("fit_canlabs_thresholds(): no BC burned polygons (Low/Medium/High).", call. = FALSE)
  }
  ba <- stats::aggregate(
    as.numeric(sf::st_area(burned)),
    by = list(rating = as.character(burned$BURN_SEVERITY_RATING)),
    FUN = sum
  )
  fr <- stats::setNames(ba$x / sum(ba$x), ba$rating)
  fr <- stats::setNames(
    c(Low = unname(fr["Low"]), Medium = unname(fr["Medium"]), High = unname(fr["High"])),
    c("Low", "Medium", "High")
  )
  fr[is.na(fr)] <- 0

  ex <- terra::extract(
    canlabs_dnbr,
    terra::project(terra::vect(sf::st_geometry(burned)), canlabs_dnbr)
  )
  vals <- ex[[ncol(ex)]]
  vals <- vals[is.finite(vals)]
  if (length(vals) < 2L) {
    stop("fit_canlabs_thresholds(): too few CanLaBS pixels within BC polygons.", call. = FALSE)
  }

  t1 <- stats::quantile(vals, probs = fr[["Low"]], names = FALSE, type = 7)
  t2 <- stats::quantile(vals, probs = fr[["Low"]] + fr[["Medium"]], names = FALSE, type = 7)
  list(thresholds = c(lowmed = t1, medhigh = t2), bc_fractions = fr, n_pixels = length(vals))
}

#' Classify CanLaBS dNBR into BC burned classes and return area by class
#'
#' @param canlabs_dnbr `SpatRaster` from [get_canlabs_dnbr()].
#' @param thresholds Output of [fit_canlabs_thresholds()] (or a bare
#'   `c(lowmed =, medhigh =)` numeric vector).
#'
#' @returns Named numeric vector `c(Low =, Medium =, High =)` of burned area (ha).
#' @family CanLaBS fire severity
#' @export
classify_canlabs_dnbr <- function(canlabs_dnbr, thresholds) {
  thr <- .canlabs_thr(thresholds)
  cell_ha <- prod(terra::res(canlabs_dnbr)) / 1e4
  ## Reclassify to 1 = Low, 2 = Medium, 3 = High and tabulate with terra::freq()
  ## rather than pulling every cell into memory (the clipped mosaic is large).
  ## right = FALSE gives left-closed bins [-Inf, lowmed) [lowmed, medhigh)
  ## [medhigh, Inf), matching v < lowmed / lowmed <= v < medhigh / v >= medhigh.
  # fmt: skip
  rcl <- matrix(
    c(
      -Inf, thr[["lowmed"]], 1,
      thr[["lowmed"]], thr[["medhigh"]], 2,
      thr[["medhigh"]], Inf, 3
    ),
    ncol = 3,
    byrow = TRUE
  )
  cls <- terra::classify(canlabs_dnbr, rcl, right = FALSE, include.lowest = TRUE)
  ft <- terra::freq(cls) ## data frame with `value` + `count` (NA excluded)
  counts <- c("1" = 0, "2" = 0, "3" = 0)
  counts[as.character(ft$value)] <- ft$count
  stats::setNames(unname(counts[c("1", "2", "3")]) * cell_ha, c("Low", "Medium", "High"))
}

#' Observed severity-class distribution from CanLaBS dNBR
#'
#' Classifies CanLaBS dNBR into BC's Low/Medium/High via `thresholds`, maps the
#' area onto LANDIS-II Dynamic Fire's 5-class scheme with the same trapezoid kernel
#' used for the BC layer ([bc_to_landis_severity_map()]), and normalises to sum 1.
#' The return contract matches [compute_observed_severity_dist()] so it is a
#' drop-in for `landisutils::save_observed_fire_targets()`'s `severity_dist`.
#'
#' @param canlabs_dnbr `SpatRaster` from [get_canlabs_dnbr()] (full record).
#' @param thresholds Output of [fit_canlabs_thresholds()].
#'
#' @returns Named numeric vector of length 5 (names "1".."5") summing to 1.
#' @family CanLaBS fire severity
#' @export
compute_observed_severity_dist_canlabs <- function(canlabs_dnbr, thresholds) {
  area_by_class <- classify_canlabs_dnbr(canlabs_dnbr, thresholds)
  area_by_class <- area_by_class[area_by_class > 0]
  if (length(area_by_class) == 0L) {
    stop("compute_observed_severity_dist_canlabs(): no burned area.", call. = FALSE)
  }
  map <- bc_to_landis_severity_map()
  landis_area <- rowSums(vapply(
    names(area_by_class),
    function(cls) map[[cls]] * area_by_class[[cls]],
    numeric(5L)
  ))
  stats::setNames(landis_area / sum(landis_area), as.character(1:5))
}

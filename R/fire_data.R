## BC fire-history + provincial fuel-type data helpers (BC-specific).
##
## Loaders for the national fire records (NFDB points/polygons, NBAC perimeters)
## clipped to a study area, plus the provincial "BC Wildfire Fire Fuel Types -
## Public" fuel raster and its recent-disturbance mask. These feed the Dynamic
## Fire / Dynamic Fuels inputs and the fire calibration targets.
##
## Provenance:
##   * De-duplicated from shared BC_HRV / gitanyow-partial-harvest code.

# ---- Internal helpers --------------------------------------------------------

## Dual-project column tolerance: the NFDB and NBAC attribute schemas differ
## between vintages and between the BC_HRV and gitanyow-partial-harvest projects
## (e.g. YEAR vs FIRE_YEAR for the year field; ADJ_HA vs POLY_HA vs HECTARES for
## the burned-area field). Pick the first candidate column present, or NA when
## none match (callers decide whether a missing column is fatal).
.first_col <- function(x, candidates) {
  intersect(candidates, names(x))[1L]
}

## bcdata object id for "BC Wildfire Fire Fuel Types - Public" (FUEL_TYPE_CD; last built on 2023 VRI).
BC_FUEL_TYPES_BCDC_ID <- "e18ef98c-e1bf-43ac-95e4-b473452f32ec"

# ---- NFDB fire history (National Fire DataBase, CWFIS) -----------------------

#' Load NFDB fire points, clipped + EcoCode-tagged to a study area
#'
#' Loads National Fire DataBase (NFDB) fire points, filters to the study-area
#' fire years and `SIZE_HA >= 1` ha, projects to the fire-ecoregions grid, and
#' (optionally) tags each fire with its fire-ecoregion `EcoCode` extracted from a
#' fire-ecoregions raster. When `fire_eco_map_path` is supplied, fires outside
#' the study-area zones (NA `EcoCode`) are dropped -- this is what restricts the
#' national NFDB to the study area, generalised over the N zones (no hard-coded
#' zone). The year column is detected tolerantly (`YEAR` or `FIRE_YEAR`) so the
#' loader works across the BC_HRV and gitanyow-partial-harvest projects.
#'
#' @param nfdb_shp Path(s) to the NFDB point shapefile(s).
#' @param fire_eco_map_path Optional path to a fire-ecoregions raster. When
#'   supplied (the BC_HRV path), points are reprojected to its CRS and tagged
#'   with `EcoCode`; points outside any zone are dropped. `NULL` (default) skips
#'   the EcoCode tagging.
#' @param fire_years Integer vector of fire years to keep.
#'
#' @returns A `SpatVector` of NFDB points within the study area (and, when
#'   `fire_eco_map_path` is supplied, carrying an integer `EcoCode` column).
#'
#' @family BC fire and fuel data
#' @export
load_nfdb_points <- function(nfdb_shp, fire_eco_map_path = NULL, fire_years) {
  p <- withCallingHandlers(terra::vect(nfdb_shp), warning = function(w) {
    if (grepl("Z coordinates ignored", conditionMessage(w))) invokeRestart("muffleWarning")
  })
  ## Tolerate either project's year column (YEAR vs FIRE_YEAR) before filtering.
  year_col <- .first_col(p, c("YEAR", "FIRE_YEAR"))
  p <- p[terra::is.valid(p), ] |> ## terra::makeValid is slow; drop the few invalid geometries
    tidyterra::mutate(
      YEAR = as.integer(.data[[year_col]]),
      MONTH = as.integer(MONTH),
      DAY = as.integer(DAY)
    ) |>
    tidyterra::mutate(DATE = as.Date(paste(YEAR, MONTH, DAY, sep = "-")), .before = "YEAR") |>
    tidyterra::mutate(JULIAN_DAY = as.integer(format(DATE, "%j")), .after = "DAY") |>
    tidyterra::filter(YEAR %in% !!fire_years, SIZE_HA >= 1.0)
  if (is.null(fire_eco_map_path)) {
    return(p)
  }
  eco <- terra::rast(fire_eco_map_path)
  p <- terra::project(p, terra::crs(eco))
  p$EcoCode <- terra::extract(eco, p)[[2L]]
  tidyterra::filter(p, !is.na(EcoCode))
}

#' Load NFDB fire polygons, filtered + clipped to a study area
#'
#' Loads National Fire DataBase (NFDB) fire polygons, filters to the fire years
#' and `SIZE_HA >= 1` ha, and projects + clips to the study area. The year column
#' is detected tolerantly (`YEAR` or `FIRE_YEAR`) so the loader works across the
#' BC_HRV and gitanyow-partial-harvest projects.
#'
#' @param nfdb_shp Character vector of NFDB polygon shapefile path(s) (the NFDB
#'   poly record ships multiple multi-year partitions).
#' @param study_area_path Path to the study-area vector (defines the clip
#'   geometry + output CRS).
#' @param fire_years Integer vector of fire years to keep.
#'
#' @returns A `SpatVector` of NFDB polygons clipped to the study area, in the
#'   study-area CRS.
#'
#' @family BC fire and fuel data
#' @export
load_nfdb_polys <- function(nfdb_shp, study_area_path, fire_years) {
  sa <- terra::vect(study_area_path)
  p <- lapply(nfdb_shp, function(x) {
    pp <- withCallingHandlers(terra::vect(x), warning = function(w) {
      if (grepl("Z coordinates ignored", conditionMessage(w))) invokeRestart("muffleWarning")
    })
    pp[terra::is.valid(pp), ] ## terra::makeValid is slow; drop the few invalid geometries
  }) |>
    tidyterra::bind_spat_rows() ## robust to column differences between the two NFDB partitions
  ## Tolerate either project's year column (YEAR vs FIRE_YEAR) before filtering.
  year_col <- .first_col(p, c("YEAR", "FIRE_YEAR"))
  p <- p |>
    tidyterra::mutate(
      YEAR = as.integer(.data[[year_col]]),
      MONTH = as.integer(MONTH),
      DAY = as.integer(DAY)
    ) |>
    tidyterra::mutate(
      JULIAN_DAY = as.integer(format(as.Date(paste(YEAR, MONTH, DAY, sep = "-")), "%j"))
    ) |>
    tidyterra::filter(YEAR %in% !!fire_years, SIZE_HA >= 1.0) |>
    terra::project(terra::crs(sa))
  terra::crop(p, sa) ## clip to the study area
}

# ---- National Burned Area Composite (NBAC, CWFIS) ----------------------------
## NBAC perimeters are satellite-derived (best-available delineation, excluding unburned islands and
## interior water) and span 1972-present; they are preferred over the NFDB polygon record, whose older
## perimeters are aerial sketches that overestimate burned area. NFDB polygons are kept only as a
## backfill for years NBAC does not cover.

#' Load NBAC fire perimeters, harmonised + clipped to a study area
#'
#' Loads National Burned Area Composite (NBAC) fire perimeters and harmonises
#' them to the NFDB-poly schema used downstream: `SIZE_HA` is taken from the
#' adjusted burned area (NBAC's canonical burned-area figure, excluding unburned
#' islands/water) and `YEAR` from the NBAC year field. Both the year and the
#' burned-area columns are detected tolerantly (year: `YEAR` or `FIRE_YEAR`;
#' area: `ADJ_HA`, `POLY_HA`, or `HECTARES`), so the loader works across NBAC
#' vintages and across the BC_HRV and gitanyow-partial-harvest projects.
#' Filtered to the fire years and `SIZE_HA >= 1` ha, projected + clipped to the
#' study area.
#'
#' @param nbac_shp Path to the NBAC polygon shapefile.
#' @param study_area_path Path to the study-area vector (defines the clip
#'   geometry + output CRS).
#' @param fire_years Integer vector of fire years to keep.
#'
#' @returns A `SpatVector` of NBAC perimeters clipped to the study area, in the
#'   study-area CRS, carrying harmonised `YEAR` + `SIZE_HA` columns.
#'
#' @family BC fire and fuel data
#' @export
load_nbac_polys <- function(nbac_shp, study_area_path, fire_years) {
  sa <- terra::vect(study_area_path)
  p <- withCallingHandlers(terra::vect(nbac_shp), warning = function(w) {
    if (grepl("Z coordinates ignored", conditionMessage(w))) invokeRestart("muffleWarning")
  })
  p <- p[terra::is.valid(p), ] ## drop the few invalid geometries (terra::makeValid is slow)
  ## Tolerate either project's / vintage's year + burned-area columns.
  year_col <- .first_col(p, c("YEAR", "FIRE_YEAR"))
  size_col <- .first_col(p, c("ADJ_HA", "POLY_HA", "HECTARES"))
  if (is.na(year_col) || is.na(size_col)) {
    stop(
      sprintf(
        "NBAC shapefile is missing expected year/size columns. Found: %s",
        paste(names(p), collapse = ", ")
      ),
      call. = FALSE
    )
  }
  p <- tidyterra::mutate(
    p,
    YEAR = as.integer(.data[[year_col]]),
    SIZE_HA = as.numeric(.data[[size_col]])
  )
  p <- tidyterra::filter(p, YEAR %in% !!fire_years, SIZE_HA >= 1.0)
  p <- terra::project(p, terra::crs(sa))
  terra::crop(p, sa) ## clip to the study area
}

#' Clip national NFDB fire points to a study area
#'
#' Projects NFDB points to a study-area rasterToMatch CRS and crops them to its
#' extent (the observed-targets input for fire calibration).
#'
#' @param nfdb_points A `SpatVector` of NFDB points, or a path to read with
#'   `terra::vect()`.
#' @param rtm_path Path to the study-area rasterToMatch (defines CRS + extent).
#'
#' @returns A `SpatVector` of NFDB points within the study area, in the
#'   rasterToMatch CRS.
#'
#' @family BC fire and fuel data
#' @export
clip_nfdb_to_study_area <- function(nfdb_points, rtm_path) {
  pts <- if (is.character(nfdb_points)) terra::vect(nfdb_points) else nfdb_points
  rtm <- terra::rast(rtm_path)
  pts <- terra::project(pts, terra::crs(rtm))
  terra::crop(pts, terra::ext(rtm))
}

# ---- provincial fuel-type raster + recent-disturbance mask -------------------

#' Fetch the provincial "BC Wildfire Fire Fuel Types - Public" polygons
#'
#' Fetches the provincial fuel-type polygons over a study area. `FUEL_TYPE_CD` is
#' returned as a factor (the categorical field that `rasterize()` / `freq()`
#' summarise by label). The WFS query is done in BC Albers (EPSG:3005) -- the WFS
#' cannot interpret a custom simulation CRS -- and the result is reprojected back
#' to the study-area CRS.
#'
#' @param study_area `sf` or `SpatVector` study-area polygon (the buffered
#'   simulation area).
#'
#' @returns An `sf` of provincial fuel-type polygons with a factor
#'   `FUEL_TYPE_CD` column, clipped to the study area.
#'
#' @family BC fire and fuel data
#' @export
get_fuel_types <- function(study_area) {
  if (inherits(study_area, "SpatVector")) {
    study_area <- sf::st_as_sf(study_area)
  }
  ## Query in BC Albers: the WFS cannot interpret the custom sim CRS, so INTERSECTS() with the sim-CRS
  ## geometry silently returns zero features. collect() comes back in BC Albers; reproject to the sim CRS.
  sa_q <- sf::st_transform(study_area, 3005)
  bcdata::bcdc_query_geodata(BC_FUEL_TYPES_BCDC_ID) |>
    dplyr::filter(bcdata::INTERSECTS(sa_q)) |>
    dplyr::select(FUEL_TYPE_CD, PERCENT_CONIFER, M1_2_PERCENT_CONIFER, PERCENT_DEAD_FIR) |>
    bcdata::collect() |>
    sf::st_transform(sf::st_crs(study_area)) |>
    sf::st_set_agr("constant") |>
    sf::st_crop(study_area) |>
    dplyr::mutate(FUEL_TYPE_CD = as.factor(FUEL_TYPE_CD))
}

#' Rasterise the most-recent stand-replacing disturbance to the rasterToMatch
#'
#' Rasterises the most-recent stand-replacing disturbance (since `recent_year`)
#' to the rasterToMatch. `MRSRD_Y` = year of the most recent stand-replacing
#' disturbance; `MRSRD_A` = its cause (CUT or BRN).
#'
#' @param for_dist `sf` or `SpatVector` of forest-disturbance polygons carrying
#'   `MRSRD_Y` and `MRSRD_A` columns.
#' @param rtm A rasterToMatch `SpatRaster`.
#' @param recent_year Integer cutoff year; only disturbances after it are kept.
#'
#' @returns A `SpatRaster` of the most-recent disturbance year, aligned to `rtm`.
#'
#' @family BC fire and fuel data
#' @export
calc_recently_disturbed <- function(for_dist, rtm, recent_year) {
  if (inherits(for_dist, "sf")) {
    for_dist <- terra::vect(for_dist)
  }
  recent <- tidyterra::filter(for_dist, MRSRD_Y > recent_year) |>
    tidyterra::filter_out(is.na(MRSRD_A))
  terra::rasterize(recent, rtm, field = "MRSRD_Y", fun = "max")
}

#' Rasterise the provincial fuel layer to the rasterToMatch
#'
#' Rasterises the provincial fuel layer to the rasterToMatch, clips to the study
#' area, and optionally masks recently-disturbed cells. Returns a CATEGORICAL
#' raster (`terra::freq()` summarises FBP labels).
#'
#' @param fuel_types `sf` of provincial fuel-type polygons with a factor
#'   `FUEL_TYPE_CD` column (from [get_fuel_types()]).
#' @param recent_disturb `SpatRaster` of recent disturbance (used as an inverse
#'   mask), or `NULL` to skip masking.
#' @param study_area `sf` or `SpatVector` study-area polygon.
#' @param rtm A rasterToMatch `SpatRaster`.
#'
#' @returns A categorical `SpatRaster` of FBP fuel types, clipped to the study
#'   area and optionally masked of recently-disturbed cells.
#'
#' @family BC fire and fuel data
#' @export
prep_fuel_types_rast <- function(fuel_types, recent_disturb, study_area, rtm) {
  stopifnot(is.factor(fuel_types$FUEL_TYPE_CD))
  if (inherits(study_area, "sf")) {
    study_area <- terra::vect(study_area)
  }
  ## terra::rasterize() does not reproject -- align the polygons + mask to the rasterToMatch CRS.
  v <- terra::project(terra::vect(fuel_types), terra::crs(rtm))
  study_area <- terra::project(study_area, terra::crs(rtm))
  r <- terra::rasterize(v, rtm, field = "FUEL_TYPE_CD") |> terra::crop(study_area, mask = TRUE)
  if (!is.null(recent_disturb)) {
    r <- terra::mask(r, recent_disturb, inverse = TRUE)
  }
  r
}

#' Labelled area-by-fuel-type summary of the provincial fuel raster
#'
#' Computes a labelled area-by-fuel-type summary of the (undisturbed) provincial
#' fuel raster. Labels are summarised on the IN-MEMORY factor raster
#' (`terra::freq()`'s value column holds the label), so no stored-raster labels
#' and no hardcoded integer-to-label map are needed. Hectares uses the true cell
#' area computed from the raster resolution (e.g. a 120 m pixel = 1.44 ha), not a
#' hardcoded per-cell area.
#'
#' @param fuel_types `sf` of provincial fuel-type polygons (from
#'   [get_fuel_types()]).
#' @param recent_disturb `SpatRaster` of recent disturbance (inverse mask), or
#'   `NULL` to skip masking.
#' @param study_area `sf` or `SpatVector` study-area polygon.
#' @param rtm A rasterToMatch `SpatRaster`.
#'
#' @returns A data frame with columns `fuel_type` (character FBP label) and
#'   `hectares` (numeric area).
#'
#' @family BC fire and fuel data
#' @export
fuel_types_distribution <- function(fuel_types, recent_disturb, study_area, rtm) {
  r <- prep_fuel_types_rast(fuel_types, recent_disturb, study_area, rtm)
  fr <- terra::freq(r)
  pixel_ha <- prod(terra::res(r)) / 1e4
  data.frame(
    fuel_type = as.character(fr$value),
    hectares = as.numeric(fr$count) * pixel_ha,
    stringsAsFactors = FALSE
  )
}

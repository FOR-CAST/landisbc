## VRI-to-LANDIS-II initial communities pipeline (BC-specific).
##
## R equivalents of an arcpy-based Python LANDIS-II VRI-to-initial-communities
## toolset. Heavy use of `terra` for geoprocessing; variable names kept as
## close as possible to the Python originals to ease cross-reference.
##
## Provenance:
##   * Original Python implementation: author unknown.
##   * R re-implementation: Alex M. Chubaty.

# ---- Internal helpers --------------------------------------------------------------------------------------------------------------------

## Read a SpatVector from either a plain file path or c(dsn, layer)
.read_vect <- function(x) {
  if (inherits(x, "SpatVector")) {
    return(x)
  }
  if (length(x) == 2L) {
    terra::vect(x[1], layer = x[2])
  } else {
    terra::vect(x)
  }
}

## Detect a field name from two candidates (full GDB name vs shapefile abbreviation)
.field_name <- function(v, full, abbrev) {
  if (full %in% names(v)) full else abbrev
}

## Detect present species/age field pairs for species 1–n.
## Returns a list of list(sp = <field>, age = <field>) for each detected species.
.sp_field_pairs <- function(v_names, n = 2L) {
  sp_gdb <- paste0("SPECIES_CD_", seq_len(n))
  sp_shp <- c("SPECIES_CD", paste0("SPECIES__", seq_len(n - 1L)))
  age_fld <- paste0("PROJ_AGE_", seq_len(n))
  result <- list()
  for (i in seq_len(n)) {
    fn_sp <- if (sp_gdb[i] %in% v_names) {
      sp_gdb[i]
    } else if (sp_shp[i] %in% v_names) {
      sp_shp[i]
    } else {
      next
    }
    fn_age <- age_fld[i]
    if (!fn_age %in% v_names) {
      next
    }
    result[[length(result) + 1L]] <- list(sp = fn_sp, age = fn_age)
  }
  result
}

## Build the BEC zone/subzone field name for a given SpatVector
.bec_field <- function(v) {
  if ("bec_zone_subzone" %in% names(v)) {
    "bec_zone_subzone"
  } else if ("bec_zone_s" %in% names(v)) {
    "bec_zone_s"
  } else {
    "MAP_LABEL"
  } # field in the test GDB
}

# ---- CleanUpSpeciesCodeLayer ------------------------------------------------------------------------------------------------------

#' Standardise BC VRI species code variants against a user-supplied mapping
#'
#' Looks up a Province of BC VRI `SPECIES_CD_N` code (e.g. `"HW"`, `"PLI"`,
#' `"SXS"`) in a user-supplied named-character mapping and returns the
#' cleaned LANDIS-II species.txt code. Codes not in the mapping trigger an
#' informative [stop()] so unknown codes fail loudly at IC build time, not
#' at LANDIS-II sim time. `NA`, `""`, and the literal string `"NA"` return
#' `""` so VRI rows without a second species drop cleanly downstream.
#'
#' For Interior Cedar-Hemlock study areas, pass [species_map_bc_ich]
#' directly. For other study areas, define a comparable named character
#' vector (see [species_map_bc_ich] for the structure, or
#' `c(landisbc::species_map_bc_ich, <new codes>)` to extend the ICH defaults).
#'
#' @param SpeciesCode Character scalar. One raw VRI species code.
#' @param mapping Named character vector. Names are raw VRI codes
#'   (e.g. `"HW"`, `"PLI"`); values are the cleaned target codes that
#'   appear in the LANDIS-II `species.txt` for the study area
#'   (e.g. `"Hw"`, `"Pl"`).
#'
#' @returns Character scalar. Either the cleaned code or `""` for NA / empty.
#' @seealso [species_map_bc_ich]
#' @family BC VRI to LANDIS-II initial communities
#' @export
CleanUpSpeciesCodeLayer <- function(SpeciesCode, mapping) {
  stopifnot(
    is.character(mapping),
    length(mapping) >= 1L,
    !is.null(names(mapping)),
    all(nzchar(names(mapping)))
  )
  ## NA / empty / literal "NA" -> no cohort. VRI records can have missing
  ## species fields (e.g. SPECIES_CD_2 absent in single-species polygons);
  ## downstream consumers drop rows where the cleaned code is empty.
  if (is.na(SpeciesCode) || identical(SpeciesCode, "") || identical(SpeciesCode, "NA")) {
    return("")
  }
  out <- mapping[SpeciesCode]
  if (is.na(out)) {
    stop(
      sprintf(
        "CleanUpSpeciesCodeLayer(): VRI species code '%s' is not in the supplied mapping. Add it to your `mapping` argument (see `?landisbc::species_map_bc_ich` for the ICH template) or filter it upstream.",
        SpeciesCode
      ),
      call. = FALSE
    )
  }
  unname(out)
}

# ---- MapCodeDataHash ----------------------------------------------------------------------------------------------------------------------
## Canonical key for a set of (SpeciesCode, Age) pairs within one MapCode.
## Equivalent to MapCodeDataHash() in LandisSupportFunctions.py.

#' Canonical hash of (SpeciesCode, Age) pairs within one map code
#'
#' Returns a stable string used to deduplicate map codes whose species/age
#' composition is identical. Equivalent to `MapCodeDataHash()` in the
#' original Python `LandisSupportFunctions.py`.
#'
#' @param mapcode_data data.frame with SpeciesCode and Age columns.
#' @returns Character scalar. Newline-separated, tab-delimited sorted pairs.
#' @family BC VRI to LANDIS-II initial communities
#' @export
MapCodeDataHash <- function(mapcode_data) {
  pairs <- sort(unique(paste(mapcode_data$SpeciesCode, mapcode_data$Age, sep = "\t")))
  paste(pairs, collapse = "\n")
}

# ---- CreateLandisGrid --------------------------------------------------------------------------------------------------------------------

#' Create a regular grid clipped to the study area
#'
#' Replicates ArcPy CreateFishnet: the bounding box is expanded outward to the next
#' CellSize boundary so the grid fully covers the study area.  Cells are assigned
#' sequential MapCodes starting at 10001.  The full fishnet raster extent is stored
#' as attr(result, "raster_extent") for downstream rasterization.
#'
#' @param StudyAreaFilePath File path string or c(dsn, layer) for the study area polygon.
#' @param CellSize          Cell side length in the study area's projected CRS units (m).
#'
#' @return SpatVector of grid cell polygons with a MapCode field.
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateLandisGrid <- function(StudyAreaFilePath, CellSize) {
  StudyArea <- .read_vect(StudyAreaFilePath)

  # Step 1 – create fishnet from study area bounding box.
  # ArcPy CreateFishnet uses ceiling division so the grid fully covers the extent;
  # replicate that by snapping xmax/ymax outward to the next cell boundary.
  fcStudyAreaDesc <- terra::ext(StudyArea)
  xmin_g <- fcStudyAreaDesc[1]
  ymin_g <- fcStudyAreaDesc[3]
  ncols_g <- ceiling((fcStudyAreaDesc[2] - xmin_g) / CellSize)
  nrows_g <- ceiling((fcStudyAreaDesc[4] - ymin_g) / CellSize)
  step1_grid_template <- terra::rast(
    xmin = xmin_g,
    xmax = xmin_g + ncols_g * CellSize,
    ymin = ymin_g,
    ymax = ymin_g + nrows_g * CellSize,
    resolution = CellSize,
    crs = terra::crs(StudyArea)
  )
  # Assign sequential cell IDs to the full grid raster
  terra::values(step1_grid_template) <- seq_len(terra::ncell(step1_grid_template))

  # Step 2 – mask to study area using faster raster operations
  #   (avoids slow polygon-vs-polygon intersection with ~130k cells)
  study_area_mask <- terra::rasterize(StudyArea, step1_grid_template, field = 1L)
  step1grid_rast <- terra::mask(step1_grid_template, study_area_mask)

  # Convert only the non-NA (inside study area) cells to polygons
  step1grid_lyr <- terra::as.polygons(step1grid_rast, dissolve = FALSE, na.rm = TRUE)

  # Step 3 – calculate MapCode (!FID!+10001; FID is 0-based in ArcGIS)
  step1grid_lyr$MapCode <- (seq_len(nrow(step1grid_lyr)) - 1L) + 10001L

  # Return geometry + MapCode only, plus the full fishnet extent as an attribute
  # so downstream rasterization uses the complete template extent (not just occupied cells).
  LandisGrid <- step1grid_lyr[, "MapCode"]
  attr(LandisGrid, "raster_extent") <- terra::ext(step1_grid_template)

  return(LandisGrid)
}

# ---- CreateInitialCommunitiesData --------------------------------------------------------------------------------------------

#' Intersect VRI with the LANDIS grid
#'
#' Crops VRI1 to the grid extent, intersects with grid cells, and attaches per-fragment
#' area in m².  Species/age fields are auto-detected for up to n_species species columns,
#' handling both GDB (SPECIES_CD_N) and shapefile (SPECIES__N) name variants.
#'
#' @param LandisGrid    SpatVector from CreateLandisGrid().
#' @param VRI1FilePath  File path or c(dsn, layer) for the VRI 1 layer.
#' @param n_species     Number of species/age field pairs to detect (default 2).
#'
#' @return SpatVector of grid × VRI intersection features with MapCode, species, age, and Area fields.
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateInitialCommunitiesData <- function(LandisGrid, VRI1FilePath, n_species = 2L) {
  VRI1 <- .read_vect(VRI1FilePath)

  pairs <- .sp_field_pairs(names(VRI1), n = n_species)
  dissolve_fields <- unlist(lapply(pairs, function(p) c(p$sp, p$age)))

  # Crop to grid extent first (fast bbox pre-filter), then intersect.
  # terra::intersect(grid, VRI) is equivalent to:
  #   dissolve VRI by attrs → union(grid, dissolved) → filter(MapCode > 0)
  # because the final filter discards everything outside the grid anyway.
  vri_cropped <- terra::crop(VRI1[, dissolve_fields], ext(LandisGrid))
  InitialCommunitiesData <- terra::intersect(LandisGrid[, "MapCode"], vri_cropped)

  # Calculate area (m²)
  InitialCommunitiesData$Area <- terra::expanse(InitialCommunitiesData, unit = "m")

  return(InitialCommunitiesData)
}

# ---- ProcessInitialCommunitiesData ------------------------------------------------------------------------------------------

#' Convert the VRI–grid intersection to a (MapCode, SpeciesCode, Age) data frame
#'
#' Removes sliver polygons below SliverThreshold % of a full cell area, bins ages to
#' the nearest AgeBinSize midpoint, standardises species codes via
#' [CleanUpSpeciesCodeLayer()] using the supplied `species_mapping`,
#' drops absent or zero-age records, and deduplicates.
#'
#' @param InitialCommunitiesData  SpatVector from CreateInitialCommunitiesData().
#' @param AgeBinSize              Age bin width in years (e.g. 20).
#' @param grid_size               Cell side length in metres (used to compute sliver threshold).
#' @param SliverThreshold         Minimum intersecting area as % of one full cell (e.g. 5).
#' @param species_mapping         Named character vector passed through to
#'   [CleanUpSpeciesCodeLayer()]. Names are raw VRI codes; values are the
#'   cleaned target codes that appear in the study area's LANDIS-II
#'   `species.txt`. For Interior Cedar-Hemlock studies, pass
#'   [species_map_bc_ich] directly.
#' @param n_species               Number of species/age field pairs to detect (default 2).
#'
#' @return data.frame with columns: MapCode (character), SpeciesCode, Age (integer).
#' @family BC VRI to LANDIS-II initial communities
#' @export
ProcessInitialCommunitiesData <- function(
  InitialCommunitiesData,
  AgeBinSize,
  grid_size,
  SliverThreshold,
  species_mapping,
  n_species = 2L
) {
  SliverThresholdArea <- grid_size * grid_size * SliverThreshold / 100

  df <- as.data.frame(InitialCommunitiesData)
  pairs <- .sp_field_pairs(names(df), n = n_species)

  # Replace NA ages with 0 for all detected species (matches Python int(None) → crash avoidance)
  for (p in pairs) {
    df[[p$age]][is.na(df[[p$age]])] <- 0L
  }

  # Filter slivers and zero-MapCode artefacts from the union
  df <- df[!is.na(df$MapCode) & df$MapCode > 0 & !is.na(df$Area) & df$Area >= SliverThresholdArea, ]

  # Bin ages: int(age / binsize) * binsize + int(binsize / 2)
  bin <- function(age) as.integer(age / AgeBinSize) * AgeBinSize + as.integer(AgeBinSize / 2)
  MapCode_chr <- as.character(df$MapCode)

  # Build one record data.frame per species, filtering out absent/empty species codes
  sp_records <- lapply(pairs, function(p) {
    cleaned <- vapply(
      as.character(df[[p$sp]]),
      CleanUpSpeciesCodeLayer,
      character(1),
      mapping = species_mapping
    )
    binned <- bin(df[[p$age]])
    keep <- df[[p$age]] > 0 & !is.na(df[[p$sp]]) & nzchar(trimws(as.character(df[[p$sp]])))
    data.frame(
      MapCode = MapCode_chr[keep],
      SpeciesCode = cleaned[keep],
      Age = binned[keep],
      stringsAsFactors = FALSE
    )
  })

  # Combine and deduplicate (equivalent to the Python state-tracking loop)
  InitialCommunitiesDataList <- unique(do.call(rbind, sp_records))
  InitialCommunitiesDataList <- InitialCommunitiesDataList[
    order(
      InitialCommunitiesDataList$MapCode,
      InitialCommunitiesDataList$SpeciesCode,
      InitialCommunitiesDataList$Age
    ),
  ]
  rownames(InitialCommunitiesDataList) <- NULL

  return(InitialCommunitiesDataList)
}

# ---- MergeVRI1andVRI2Data ------------------------------------------------------------------------------------------------------------
## Merge two InitialCommunitiesDataLists and deduplicate.
## Equivalent to MergeVRI1andVRI2Data.py.

#' Merge VRI1 and VRI2 initial-community data lists
#'
#' Combines two snapshots' (MapCode, SpeciesCode, Age) data frames so each
#' MapCode carries the union of cohorts from VRI1 and VRI2. Mirrors
#' `MergeVRI1andVRI2Data.py`.
#'
#' @param InitialCommunitiesDataListVRI1 data.frame from
#'   [ProcessInitialCommunitiesData()] applied to VRI1.
#' @param InitialCommunitiesDataListVRI2 Same, for VRI2.
#' @returns Combined data.frame with the union of cohort rows.
#' @family BC VRI to LANDIS-II initial communities
#' @export
MergeVRI1andVRI2Data <- function(InitialCommunitiesDataListVRI1, InitialCommunitiesDataListVRI2) {
  InitialCommunitiesDataList <- rbind(
    InitialCommunitiesDataListVRI1,
    InitialCommunitiesDataListVRI2
  ) |>
    unique()
  InitialCommunitiesDataList <- InitialCommunitiesDataList[
    order(
      InitialCommunitiesDataList$MapCode,
      InitialCommunitiesDataList$SpeciesCode,
      InitialCommunitiesDataList$Age
    ),
  ]
  rownames(InitialCommunitiesDataList) <- NULL

  return(InitialCommunitiesDataList)
}

# ---- CleanMapCodes --------------------------------------------------------------------------------------------------------------------------

#' Assign canonical map codes, collapsing duplicate communities
#'
#' Grid cells with identical species/age composition receive the same clean code.
#' Vegetated codes (>= 10000) are renumbered starting at 10000; non-vegetated codes
#' (< 10000) are preserved as-is.
#'
#' @param InitialCommunitiesDataList data.frame from ProcessInitialCommunitiesData() or
#'   MergeVRI1andVRI2Data(), with columns MapCode, SpeciesCode, Age.
#'
#' @return Named list mapping original MapCode (character keys) to canonical integer codes.
#' @family BC VRI to LANDIS-II initial communities
#' @export
CleanMapCodes <- function(InitialCommunitiesDataList) {
  # Compute one canonical hash per veg MapCode (>= 10000), in sorted visit order.
  veg_summary <- InitialCommunitiesDataList |>
    dplyr::filter(as.integer(MapCode) >= 10000L) |>
    dplyr::group_by(MapCode) |>
    dplyr::summarise(hash = MapCodeDataHash(dplyr::pick(SpeciesCode, Age)), .groups = "drop") |>
    dplyr::arrange(MapCode) |>
    dplyr::mutate(CleanMapCode = match(hash, unique(hash)) + 9999L)

  # Non-veg codes (< 10000) stay as-is.
  nonveg_summary <- InitialCommunitiesDataList |>
    dplyr::filter(as.integer(MapCode) < 10000L) |>
    dplyr::distinct(MapCode) |>
    dplyr::mutate(CleanMapCode = as.integer(MapCode))

  all_codes <- dplyr::bind_rows(dplyr::select(veg_summary, MapCode, CleanMapCode), nonveg_summary)
  setNames(as.list(all_codes$CleanMapCode), all_codes$MapCode)
}

# ---- GetNonVegData --------------------------------------------------------------------------------------------------------------------------

#' Find the dominant BCLCS Level-4 non-vegetation code for each grid cell
#'
#' Intersects VRI1 with the grid, excludes treed categories (TB, TC, TM), and returns
#' the Level-4 code with the largest area in each cell.  Cells where non-veg covers
#' < 50 % of the area AND whose MapCode is in dicCleanMapCodes are excluded.
#'
#' @param LandisGrid       SpatVector from CreateLandisGrid().
#' @param VRI1FilePath     File path or c(dsn, layer) for the VRI 1 layer.
#' @param grid_size        Cell side length in metres.
#' @param dicCleanMapCodes Named list from CleanMapCodes() — used to detect vegetated cells.
#'
#' @return Named list mapping MapCode (character) to dominant BCLCS Level-4 code (character).
#' @family BC VRI to LANDIS-II initial communities
#' @export
GetNonVegData <- function(LandisGrid, VRI1FilePath, grid_size, dicCleanMapCodes) {
  VRI1 <- .read_vect(VRI1FilePath)

  fieldname_level_4 <- .field_name(VRI1, "BCLCS_LEVEL_4", "BCLCS_LE_3")
  fieldname_level_2 <- .field_name(VRI1, "BCLCS_LEVEL_2", "BCLCS_LE_1")

  # Crop VRI to grid extent, filter out treed categories, then intersect.
  # Equivalent to dissolve-by-BCLCS → union(grid, non-veg) → filter(MapCode > 0).
  vri_cropped <- terra::crop(
    VRI1[, c(fieldname_level_2, fieldname_level_4)],
    terra::ext(LandisGrid)
  )
  ## terra::SpatVector's `[[<field>]]` returns a 1-column data.frame, not a vector.
  ## Wrapping that in as.character() collapses it to a single string of the form
  ## `c(NA, "RO", "HE", ...)`, so the lev4 %in% c("TB","TC","TM") filter below is
  ## evaluated against a length-1 character vector and returns a single FALSE,
  ## which indexes the SpatVector as "keep all rows". The end result is that
  ## treed polygons (TB/TC/TM) silently leak through into dicNonVegMapCodes,
  ## flagging most of the grid as non-vegetated and producing a near-empty
  ## ecoregions raster (only ~56 active cells out of ~165 k). Use [[1]] to
  ## extract the column as a proper character vector.
  lev4 <- as.character(vri_cropped[[fieldname_level_4]][[1]])
  ## NOTE: TM (Treed-Mixed) is excluded here alongside TB/TC, so it never enters
  ## dicNonVegMapCodes. As a result, the TM = 6000L entry in CreateInitialCommunitiesMap
  ## is dead code: TM-dominated cells that lack species/age data fall through to the
  ## default code 7000L (exposed land) rather than 6000L.
  step2_filter <- vri_cropped[!(lev4 %in% c("TB", "TC", "TM")), ]

  step4_filter <- terra::intersect(LandisGrid[, "MapCode"], step2_filter)

  # Step 5 – calculate area
  step4_filter$Area <- terra::expanse(step4_filter, unit = "m")

  df <- as.data.frame(step4_filter)
  names(df)[names(df) == fieldname_level_2] <- "lev2"
  names(df)[names(df) == fieldname_level_4] <- "lev4"

  area50pct <- grid_size * grid_size * 0.5

  # Steps 6-7 – find dominant BCLCS_LEVEL_4 per MapCode
  dominant <- df |>
    dplyr::mutate(
      MapCode = as.character(MapCode),
      lev4 = dplyr::if_else(!is.na(lev2) & lev2 == "W", "W", as.character(lev4))
    ) |>
    dplyr::filter(!is.na(lev4) & nchar(trimws(lev4)) > 0) |>
    dplyr::group_by(MapCode) |>
    dplyr::summarise(
      TotalArea = sum(Area, na.rm = TRUE),
      DomCode = lev4[which.max(Area)],
      .groups = "drop"
    ) |>
    dplyr::filter(!(MapCode %in% names(dicCleanMapCodes) & TotalArea < area50pct))

  setNames(as.list(dominant$DomCode), dominant$MapCode) # dicNonVegMapCodes in CreateLandisFiles
}

# ---- CreateInitialCommunitiesMap ----------------------------------------------------------------------------------------------

#' Write the LANDIS-II initial communities raster
#'
#' Applies canonical clean codes and non-veg codes (6000–8000) to grid cells, then
#' rasterizes to an INT4S GeoTIFF.  Cells with no VRI data default to 7000 (exposed
#' land).  The full fishnet template extent from CreateLandisGrid() is used as the
#' rasterization template.
#'
#' @param LandisGrid            SpatVector from CreateLandisGrid().
#' @param grid_size             Cell side length in metres.
#' @param InitialCommunitiesMap Output file path for the INT4S GeoTIFF.
#' @param dicNonVegMapCodes     Named list from GetNonVegData().
#' @param dicCleanMapCodes      Named list from CleanMapCodes().
#'
#' @return Invisibly, the rasterized SpatRaster.
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateInitialCommunitiesMap <- function(
  LandisGrid,
  grid_size,
  InitialCommunitiesMap,
  dicNonVegMapCodes,
  dicCleanMapCodes
) {
  NonVegCodes <- list(
    TM = 6000L, ## dead code — TM is excluded from dicNonVegMapCodes in GetNonVegData (see note there)
    HE = 6100L,
    HF = 6100L,
    HG = 6100L,
    ST = 6200L,
    SL = 6200L,
    BY = 6300L,
    BM = 6300L,
    BL = 6300L,
    SI = 7000L,
    RO = 7000L,
    EL = 7000L,
    W = 8000L
  )

  LandisGrid_out <- LandisGrid # work on a copy
  mc_chr <- as.character(LandisGrid_out$MapCode)

  # Vectorized lookup: start with 7000 (no VRI data → exposed land)
  out_codes <- rep(7000L, nrow(LandisGrid_out))

  # Apply clean map codes
  in_clean <- mc_chr %in% names(dicCleanMapCodes)
  if (any(in_clean)) {
    out_codes[in_clean] <- as.integer(unlist(dicCleanMapCodes[mc_chr[in_clean]]))
  }

  # Apply non-veg codes (overrides clean codes where NonVegCodes has an entry)
  in_nonveg <- mc_chr %in% names(dicNonVegMapCodes)
  if (any(in_nonveg)) {
    lev4_vals <- unlist(dicNonVegMapCodes[mc_chr[in_nonveg]])
    nv_ints <- sapply(lev4_vals, function(l) {
      v <- NonVegCodes[[l]]
      if (!is.null(v)) v else NA_integer_
    })
    idx <- which(in_nonveg)
    has_code <- !is.na(nv_ints)
    out_codes[idx[has_code]] <- nv_ints[has_code]
  }

  LandisGrid_out$MapCode <- out_codes

  # Rasterize to grid_size resolution (32-bit signed int, matching Python).
  # Use the full fishnet template extent (stored as attr) so the raster matches
  # ArcPy's fishnet extent, not just the bounding box of occupied cells.
  tmpl_ext <- attr(LandisGrid, "raster_extent") %||% terra::ext(LandisGrid_out)
  step1_raster_template <- terra::rast(
    tmpl_ext,
    resolution = grid_size,
    crs = terra::crs(LandisGrid_out)
  )
  step1_raster <- terra::rasterize(LandisGrid_out, step1_raster_template, field = "MapCode")

  ## NOTE: written as INT4S (32-bit signed, GDAL GDT_Int32). ForCS reads the map via
  ## UIntPixel (Band<uint>); the GDAL layer dispatches on the stored type (GDT_Int32 →
  ## NewIntBand → Convert.ToUInt32), so any non-negative 32-bit value is handled correctly.
  ## The LANDIS-II documentation's "UInt16 (0–65,535)" is misleading: GDT_UInt16 would
  ## throw an exception in the GDAL reader (no UInt16 reader registered). INT4S is correct.
  terra::writeRaster(
    step1_raster,
    InitialCommunitiesMap,
    datatype = "INT4S",
    NAflag = 0L,
    overwrite = TRUE
  )

  invisible(step1_raster)
}

# ---- CreateInitialCommunitiesTextFile ------------------------------------------------------------------------------------

#' Write the LANDIS-II initial communities text configuration file
#'
#' Iterates over canonical map codes in sorted order, writing one MapCode block per
#' unique community (species × age cohorts).  Non-vegetated placeholder codes
#' (6000, 6100, 6200, 6300, 7000, 8000) are always appended at the end.
#'
#' @param InitialCommunitiesDataList data.frame with columns MapCode, SpeciesCode, Age.
#' @param dicCleanMapCodes           Named list from CleanMapCodes().
#' @param InitialCommunitiesTxt      Output file path for the text file.
#'
#' @return Invisibly NULL (writes to file as a side effect).
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateInitialCommunitiesTextFile <- function(
  InitialCommunitiesDataList,
  dicCleanMapCodes,
  InitialCommunitiesTxt
) {
  text_file <- file(InitialCommunitiesTxt, "w")
  cat('LandisData   "Initial Communities"', file = text_file)

  ProcessedCleanMapcodes <- integer(0)
  AllMapCodesUnique <- sort(unique(names(dicCleanMapCodes)))

  for (currentMapCode in AllMapCodesUnique) {
    if (as.integer(currentMapCode) >= 10000L) {
      currentCleanMapCode <- dicCleanMapCodes[[currentMapCode]]

      if (!(currentCleanMapCode %in% ProcessedCleanMapcodes)) {
        cat("\n\nMapCode ", currentCleanMapCode, sep = "", file = text_file)

        currentMapCodeData <- InitialCommunitiesDataList[
          InitialCommunitiesDataList$MapCode == currentMapCode,
        ]

        AllSpeciesCodesUnique <- sort(unique(currentMapCodeData$SpeciesCode))

        for (currentSpeciesCode in AllSpeciesCodesUnique) {
          cat("\n   ", currentSpeciesCode, sep = "", file = text_file)
          AllAgesUnique <- sort(unique(currentMapCodeData$Age[
            currentMapCodeData$SpeciesCode == currentSpeciesCode
          ]))
          for (currentAge in AllAgesUnique) {
            cat(" ", currentAge, sep = "", file = text_file)
          }
        }

        ProcessedCleanMapcodes <- c(ProcessedCleanMapcodes, currentCleanMapCode)
      }
    }
  }

  # Non-veg placeholder map codes (always appended)
  cat(
    "\n\nMapCode 6000\n",
    "\nMapCode 6100\n",
    "\nMapCode 6200\n",
    "\nMapCode 6300\n",
    "\nMapCode 7000\n",
    "\nMapCode 8000  \n",
    sep = "",
    file = text_file
  )

  close(text_file)
}

# ---- CreateInitialCommunitiesCSVFile -------------------------------------------------------------------------

#' Write the LANDIS-II v8 initial communities CSV file
#'
#' Non-vegetated map codes (< 10000) are omitted; LANDIS-II v8 treats absent map codes
#' as empty communities.  CohortBiomass is always 0 (initial biomass is derived from
#' cohort age during succession initialisation).
#'
#' @param InitialCommunitiesDataList data.frame with columns MapCode, SpeciesCode, Age.
#' @param dicCleanMapCodes           Named list from CleanMapCodes().
#' @param InitialCommunitiesCSV      Output file path for the CSV.
#'
#' @return Invisibly NULL (writes to file as a side effect).
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateInitialCommunitiesCSVFile <- function(
  InitialCommunitiesDataList,
  dicCleanMapCodes,
  InitialCommunitiesCSV
) {
  ProcessedCleanMapcodes <- integer(0)
  AllMapCodesUnique <- sort(unique(names(dicCleanMapCodes)))

  rows <- lapply(AllMapCodesUnique, function(currentMapCode) {
    if (as.integer(currentMapCode) < 10000L) {
      return(NULL)
    }

    currentCleanMapCode <- dicCleanMapCodes[[currentMapCode]]
    if (currentCleanMapCode %in% ProcessedCleanMapcodes) {
      return(NULL)
    }

    ProcessedCleanMapcodes <<- c(ProcessedCleanMapcodes, currentCleanMapCode)

    currentMapCodeData <- InitialCommunitiesDataList[
      InitialCommunitiesDataList$MapCode == currentMapCode,
    ]

    data.frame(
      MapCode = as.integer(currentCleanMapCode),
      SpeciesName = currentMapCodeData$SpeciesCode,
      CohortAge = as.integer(currentMapCodeData$Age),
      CohortBiomass = 0L,
      stringsAsFactors = FALSE
    )
  })

  out <- do.call(rbind, Filter(Negate(is.null), rows))
  write.csv(out, InitialCommunitiesCSV, row.names = FALSE, quote = FALSE)
}

# ---- GetBECCodes ------------------------------------------------------------------------------------------------------------------------------
## Dissolve BEC layer and assign sequential integer codes to each zone/subzone.
## Equivalent to getBECCodes.py.

#' Extract BC Biogeoclimatic Ecosystem Classification (BEC) codes
#'
#' Reads a BEC layer and returns a named integer lookup table keyed by
#' BEC zone-subzone-variant label, used to populate LANDIS-II's
#' ecoregions.txt and ecoregions.tif.
#'
#' @param BECFilePath SpatVector or path / c(dsn, layer) for the BEC layer.
#' @returns Named integer vector (BEC label -> integer ecoregion id).
#' @family BC VRI to LANDIS-II initial communities
#' @export
GetBECCodes <- function(BECFilePath) {
  BEC_layer <- .read_vect(BECFilePath)
  fieldname_bec_zone_subzone <- .bec_field(BEC_layer)

  # Get sorted unique BEC zone/subzone values (no geometry dissolve needed)
  # Use values() to reliably extract the column from a SpatVector
  bec_vals <- sort(unique(values(BEC_layer)[[fieldname_bec_zone_subzone]]))
  bec_vals <- as.character(bec_vals[!is.na(bec_vals) & nzchar(trimws(bec_vals))])

  dicBECCODES <- setNames(as.list(seq_along(bec_vals)), bec_vals)

  return(dicBECCODES)
}

# ---- CreateEcoRegionsMap --------------------------------------------------------------------------------------------------------------

#' Write the LANDIS-II ecoregions raster
#'
#' Finds the dominant BEC zone/subzone for each grid cell, assigns the integer code
#' from GetBECCodes() sequencing, and rasterizes to an INT2S GeoTIFF.  Non-vegetated
#' cells and cells in dicNonVegMapCodes receive code 0 (inactive in LANDIS-II).
#'
#' @param LandisGrid        SpatVector from CreateLandisGrid().
#' @param BECFilePath       File path or c(dsn, layer) for the BEC polygon layer.
#' @param grid_size         Cell side length in metres.
#' @param EcoRegionsMap     Output file path for the INT2S GeoTIFF.
#' @param dicNonVegMapCodes Named list from GetNonVegData().
#'
#' @return Invisibly, the rasterized SpatRaster.
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateEcoRegionsMap <- function(
  LandisGrid,
  BECFilePath,
  grid_size,
  EcoRegionsMap,
  dicNonVegMapCodes
) {
  BEC_layer <- .read_vect(BECFilePath)
  fieldname_bec_zone_subzone <- .bec_field(BEC_layer)

  # Step 2 – intersect grid with BEC (equivalent to union + filter MapCode > 0)
  bec_cropped <- terra::crop(BEC_layer[, fieldname_bec_zone_subzone], ext(LandisGrid))
  step2_intersect <- terra::intersect(LandisGrid[, "MapCode"], bec_cropped)
  step2_intersect$Area <- terra::expanse(step2_intersect, unit = "m")

  df <- as.data.frame(step2_intersect)
  df$MapCode <- as.character(df$MapCode)

  # Steps 3-5 – find dominant BEC per MapCode
  dicMaxAreaBEC <- list()
  dicMaxArea <- list()

  for (i in seq_len(nrow(df))) {
    MapCode <- df$MapCode[i]
    Area <- df$Area[i]
    BEC <- as.character(df[[fieldname_bec_zone_subzone]][i])

    if (!is.na(BEC) && nchar(trimws(BEC)) > 0 && !is.na(MapCode)) {
      if (MapCode %in% names(dicMaxArea)) {
        if (!is.na(Area) && Area > dicMaxArea[[MapCode]]) {
          dicMaxArea[[MapCode]] <- Area
          dicMaxAreaBEC[[MapCode]] <- BEC
        }
      } else {
        dicMaxArea[[MapCode]] <- Area
        dicMaxAreaBEC[[MapCode]] <- BEC
      }
    }
  }

  # Step 6 – build BEC code lookup (sorted unique values, matching GetBECCodes)
  bec_uvals <- sort(unique(values(BEC_layer)[[fieldname_bec_zone_subzone]]))
  bec_uvals <- as.character(bec_uvals[!is.na(bec_uvals) & nzchar(trimws(bec_uvals))])
  bec_code_vec <- setNames(seq_along(bec_uvals), bec_uvals) # named integer vector

  # Step 7 – update grid with BECCODE (vectorized)
  LandisGrid_out <- LandisGrid
  mc_chr <- as.character(LandisGrid_out$MapCode)
  mc_int <- LandisGrid_out$MapCode

  # Resolve dominant BEC per cell from dicMaxAreaBEC
  cell_bec <- dicMaxAreaBEC[mc_chr] # list, NULL where missing
  has_bec <- !vapply(cell_bec, is.null, logical(1))
  bec_name <- rep(NA_character_, length(mc_chr))
  if (any(has_bec)) {
    bec_name[has_bec] <- unlist(cell_bec[has_bec])
  }

  ## Resolve BEC code: use bec_code_vec for vegetated grid cells; non-veg cells
  ## (those in dicNonVegMapCodes) get code 0 so LANDIS treats them as inactive.
  nonveg_mapcodes <- names(dicNonVegMapCodes)
  beccode_v <- rep(NA_integer_, length(mc_chr))
  in_grid <- has_bec & mc_int >= 10000L & !(mc_chr %in% nonveg_mapcodes)
  if (any(in_grid)) {
    beccode_v[in_grid] <- as.integer(bec_code_vec[bec_name[in_grid]])
  }
  in_nonveg <- has_bec & (mc_int < 10000L | mc_chr %in% nonveg_mapcodes)
  if (any(in_nonveg)) {
    beccode_v[in_nonveg] <- 0L ## inactive — no LANDIS ecoregion assignment
  }

  cell_area <- dicMaxArea[mc_chr]
  has_area <- !vapply(cell_area, is.null, logical(1))
  maxarea_v <- rep(NA_real_, length(mc_chr))
  if (any(has_area)) {
    maxarea_v[has_area] <- unlist(cell_area[has_area])
  }

  LandisGrid_out$MaxArea <- maxarea_v
  LandisGrid_out$BEC <- bec_name
  LandisGrid_out$BECCODE <- beccode_v

  # Step 8 – rasterize (16-bit signed int, matching Python).
  # Use full fishnet extent from LandisGrid attr so raster covers the same area.
  tmpl_ext <- attr(LandisGrid, "raster_extent") %||% terra::ext(LandisGrid_out)
  step8_raster_template <- terra::rast(
    tmpl_ext,
    resolution = grid_size,
    crs = terra::crs(LandisGrid_out)
  )
  step8_raster <- terra::rasterize(LandisGrid_out, step8_raster_template, field = "BECCODE")

  terra::writeRaster(step8_raster, EcoRegionsMap, datatype = "INT2S", NAflag = 0L, overwrite = TRUE)

  invisible(step8_raster)
}

# ---- WriteEcoRegionsTextFile ------------------------------------------------------------------------------------------------------
## Write the LANDIS-II ecoregions text configuration file.
## Equivalent to WriteEcoRegionsTextFile.py.

#' Write the LANDIS-II ecoregions.txt input file
#'
#' Materialises the LANDIS-II ecoregions.txt parameter file from the BEC
#' code lookup produced by [GetBECCodes()].
#'
#' @param dicBECCodes Named integer vector from [GetBECCodes()].
#' @param EcoRegionsTxt Output file path for the ecoregions.txt file.
#' @returns Invisibly, the path written.
#' @family BC VRI to LANDIS-II initial communities
#' @export
WriteEcoRegionsTextFile <- function(dicBECCodes, EcoRegionsTxt) {
  text_file <- file(EcoRegionsTxt, "w")

  writeLines('LandisData  Ecoregions', con = text_file)
  writeLines('>>         Map', con = text_file)
  writeLines('>> Active  Code  Name   Description', con = text_file)
  writeLines('>> ------  ----  -----  -----------)', con = text_file)

  for (BEC in names(dicBECCodes)) {
    BECCode <- dicBECCodes[[BEC]]
    writeLines(paste0('     yes    ', BECCode, '  ', BEC, '\t"', BEC, '"'), con = text_file)
  }

  writeLines('      no     0   NoData    "NoData"', con = text_file)
  writeLines('      no     6000   TM    "Treed - Mixed "', con = text_file)
  writeLines(
    '      no     6100   HEHFHG    "Herb, Herb - Forbs, Herb - Graminoids "',
    con = text_file
  )
  writeLines('      no     6200   STSL    "Shrub Tall, Shrub Low"', con = text_file)
  writeLines(
    '      no     6300   BYBMBL    "Bryoid, Bryoid - Moss, Bryoid - Lichens "',
    con = text_file
  )
  writeLines(
    '      no     7000   SIROEL    "Snow / Ice, Rock / Rubble, Exposed Land "',
    con = text_file
  )
  writeLines('      no     8000   W    "Water"', con = text_file)

  close(text_file)
}

# ---- CreateLandisFiles ------------------------------------------------------------------------------------------------------------------

#' Create all LANDIS-II initial communities and ecoregions files
#'
#' Main orchestrator.  All file path arguments accept either a plain file path string
#' or c(dsn, layer) for geodatabase layers.
#'
#' @param StudyAreaFilePath      File path or c(dsn, layer) for the study area polygon.
#' @param VRI1FilePath           File path or c(dsn, layer) for the primary VRI layer.
#' @param VRI2FilePath           File path or c(dsn, layer) for the secondary VRI layer (used if UseVRI2 = TRUE).
#' @param BECFilePath            File path or c(dsn, layer) for the BEC polygon layer.
#' @param grid_size              Grid cell side length in metres.
#' @param AgeBinSize             Age bin width in years.
#' @param UseVRI2                Logical; if TRUE VRI2 records are merged with VRI1.
#' @param SliverThreshold        Minimum intersecting area as % of one full cell.
#' @param InitialCommunitiesMap  Output path for the initial communities GeoTIFF.
#' @param InitialCommunitiesTxt  Output path for the initial communities text file.
#' @param EcoRegionsMap          Output path for the ecoregions GeoTIFF.
#' @param EcoRegionsTxt          Output path for the ecoregions text file.
#' @param n_species              Number of species/age field pairs per VRI feature (default 2).
#'
#' @return Invisibly NULL (writes four files as a side effect).
#' @family BC VRI to LANDIS-II initial communities
#' @export
CreateLandisFiles <- function(
  StudyAreaFilePath,
  VRI1FilePath,
  VRI2FilePath,
  BECFilePath,
  grid_size,
  AgeBinSize,
  UseVRI2,
  SliverThreshold,
  InitialCommunitiesMap,
  InitialCommunitiesTxt,
  EcoRegionsMap,
  EcoRegionsTxt,
  n_species = 2L
) {
  message("Creating Landis Grid")
  LandisGrid <- CreateLandisGrid(StudyAreaFilePath, grid_size)

  InitialCommunitiesDataVRI1 <- CreateInitialCommunitiesData(
    LandisGrid,
    VRI1FilePath,
    n_species = n_species
  )
  InitialCommunitiesDataListVRI1 <- ProcessInitialCommunitiesData(
    InitialCommunitiesDataVRI1,
    AgeBinSize,
    grid_size,
    SliverThreshold,
    n_species = n_species
  )

  if (UseVRI2) {
    InitialCommunitiesDataVRI2 <- CreateInitialCommunitiesData(
      LandisGrid,
      VRI2FilePath,
      n_species = n_species
    )
    InitialCommunitiesDataListVRI2 <- ProcessInitialCommunitiesData(
      InitialCommunitiesDataVRI2,
      AgeBinSize,
      grid_size,
      SliverThreshold,
      n_species = n_species
    )
  } else {
    InitialCommunitiesDataListVRI2 <- data.frame(
      MapCode = character(0),
      SpeciesCode = character(0),
      Age = integer(0),
      stringsAsFactors = FALSE
    )
  }

  InitialCommunitiesDataList <- MergeVRI1andVRI2Data(
    InitialCommunitiesDataListVRI1,
    InitialCommunitiesDataListVRI2
  )

  dicCleanMapCodes <- CleanMapCodes(InitialCommunitiesDataList)
  dicNonVegMapCodes <- GetNonVegData(LandisGrid, VRI1FilePath, grid_size, dicCleanMapCodes)

  message("Creating Initial Communities Map")
  CreateInitialCommunitiesMap(
    LandisGrid,
    grid_size,
    InitialCommunitiesMap,
    dicNonVegMapCodes,
    dicCleanMapCodes
  )

  message("Creating Initial Communities config file")
  CreateInitialCommunitiesTextFile(
    InitialCommunitiesDataList,
    dicCleanMapCodes,
    InitialCommunitiesTxt
  )

  message("Creating EcoRegions Map")
  CreateEcoRegionsMap(LandisGrid, BECFilePath, grid_size, EcoRegionsMap, dicNonVegMapCodes)

  message("Creating EcoRegions config file")
  dicBECCODES <- GetBECCodes(BECFilePath)
  WriteEcoRegionsTextFile(dicBECCODES, EcoRegionsTxt)

  invisible(NULL)
}

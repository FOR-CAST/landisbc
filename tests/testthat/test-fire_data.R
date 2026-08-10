## Small in-memory study area + rasterToMatch shared across tests.
make_rtm <- function() {
  terra::rast(nrows = 4, ncols = 4, xmin = 0, xmax = 480, ymin = 0, ymax = 480, crs = "EPSG:3005")
}

make_sa <- function() {
  terra::vect("POLYGON ((0 0, 480 0, 480 480, 0 480, 0 0))", crs = "EPSG:3005")
}

test_that("calc_recently_disturbed() keeps only post-cutoff, attributed disturbance", {
  rtm <- make_rtm()
  fd <- terra::vect(
    c(
      "POLYGON ((0 0, 120 0, 120 120, 0 120, 0 0))", ## recent + attributed -> kept
      "POLYGON ((240 240, 360 240, 360 360, 240 360, 240 240))", ## too old -> dropped
      "POLYGON ((120 120, 240 120, 240 240, 120 240, 120 120))" ## NA cause -> dropped
    ),
    crs = "EPSG:3005"
  )
  fd$MRSRD_Y <- c(2015L, 1990L, 2018L)
  fd$MRSRD_A <- c("BRN", "CUT", NA)

  r <- calc_recently_disturbed(fd, rtm, recent_year = 2000L)
  v <- terra::values(r)
  ## only the 2015 BRN polygon survives the year + cause filters
  expect_equal(sort(unique(v[!is.na(v)])), 2015)
  expect_equal(sum(!is.na(v)), 1L)
})

test_that("prep_fuel_types_rast() requires a factor FUEL_TYPE_CD", {
  rtm <- make_rtm()
  ft <- sf::st_sf(
    FUEL_TYPE_CD = c("C-2", "C-3"),
    geometry = sf::st_sfc(
      sf::st_polygon(list(rbind(c(0, 0), c(120, 0), c(120, 120), c(0, 120), c(0, 0)))),
      sf::st_polygon(list(rbind(c(120, 0), c(240, 0), c(240, 120), c(120, 120), c(120, 0)))),
      crs = 3005
    )
  )
  expect_snapshot(prep_fuel_types_rast(ft, NULL, make_sa(), rtm), error = TRUE)
})

test_that("fuel_types_distribution() scales counts by cell area in hectares", {
  rtm <- make_rtm() ## 120 m cells -> 1.44 ha each
  ft <- sf::st_sf(
    FUEL_TYPE_CD = factor(c("C-2", "C-3")),
    geometry = sf::st_sfc(
      ## left half (8 cells) C-2, right half (8 cells) C-3
      sf::st_polygon(list(rbind(c(0, 0), c(240, 0), c(240, 480), c(0, 480), c(0, 0)))),
      sf::st_polygon(list(rbind(c(240, 0), c(480, 0), c(480, 480), c(240, 480), c(240, 0)))),
      crs = 3005
    )
  )
  dist <- fuel_types_distribution(ft, NULL, make_sa(), rtm)
  expect_named(dist, c("fuel_type", "hectares"))
  expect_setequal(dist$fuel_type, c("C-2", "C-3"))
  ## 8 cells * (120 m)^2 / 1e4 = 11.52 ha per class
  expect_equal(sort(dist$hectares), c(11.52, 11.52))
})

## Fire-ecoregions raster in the LANDIS-II convention: 0 = inactive, >= 1 = a zone.
## Left half is zone 1, right half is inactive.
make_eco <- function() {
  r <- make_rtm()
  terra::values(r) <- rep(c(1L, 1L, 0L, 0L), times = 4)
  r
}

## NFDB-style points carrying the columns load_nfdb_points() needs.
write_nfdb_points <- function(x, y, path) {
  p <- terra::vect(cbind(x, y), type = "points", crs = "EPSG:3005")
  p$YEAR <- 2010L
  p$MONTH <- 7L
  p$DAY <- 1L
  p$SIZE_HA <- 100
  terra::writeVector(p, path, overwrite = TRUE)
  path
}

test_that("load_nfdb_points() keeps only points on active ecoregion cells", {
  eco_path <- withr::local_tempfile(fileext = ".tif")
  terra::writeRaster(make_eco(), eco_path, overwrite = TRUE)
  pts_path <- write_nfdb_points(
    x = c(60, 180, 300, 420, 600),
    y = c(60, 300, 60, 420, 600),
    path = withr::local_tempfile(fileext = ".gpkg")
  )

  out <- load_nfdb_points(pts_path, eco_path, fire_years = 2000:2020)
  ## two points sit on zone 1; two sit on inactive (0) cells; one is off the raster (NA)
  expect_equal(nrow(out), 2L)
  expect_equal(unique(out$EcoCode), 1L)
})

test_that("load_nfdb_points() leaves points untagged and uncropped without an ecoregions map", {
  pts_path <- write_nfdb_points(
    x = c(60, 300, 600),
    y = c(60, 60, 600),
    path = withr::local_tempfile(fileext = ".gpkg")
  )

  out <- load_nfdb_points(pts_path, fire_eco_map_path = NULL, fire_years = 2000:2020)
  expect_equal(nrow(out), 3L)
  expect_false("EcoCode" %in% names(out))
})

test_that("clip_nfdb_to_study_area() drops points off the rasterToMatch's active cells", {
  rtm <- make_rtm()
  ## active only in the left half; NA elsewhere, as crop_mask_to() leaves a rasterToMatch
  terra::values(rtm) <- rep(c(1L, 1L, NA_integer_, NA_integer_), times = 4)
  rtm_path <- withr::local_tempfile(fileext = ".tif")
  terra::writeRaster(rtm, rtm_path, overwrite = TRUE)

  pts <- terra::vect(
    cbind(c(60, 180, 300, 420), c(60, 300, 60, 420)),
    type = "points",
    crs = "EPSG:3005"
  )

  ## all four are inside the bounding box; only the two on non-NA cells are in the study area
  expect_equal(nrow(clip_nfdb_to_study_area(pts, rtm_path)), 2L)
})

test_that("load_nbac_polys() tolerates either project's year/size columns", {
  sa_path <- withr::local_tempfile(fileext = ".gpkg")
  terra::writeVector(make_sa(), sa_path, overwrite = TRUE)

  poly <- function(x0, y0) {
    sf::st_polygon(list(rbind(
      c(x0, y0),
      c(x0 + 100, y0),
      c(x0 + 100, y0 + 100),
      c(x0, y0 + 100),
      c(x0, y0)
    )))
  }

  ## alternate schema: FIRE_YEAR + POLY_HA (neither is the canonical YEAR/ADJ_HA pair)
  nbac <- sf::st_sf(
    FIRE_YEAR = c(2010L, 1999L),
    POLY_HA = c(50, 200),
    geometry = sf::st_sfc(poly(0, 0), poly(120, 0), crs = 3005)
  )
  nbac_path <- withr::local_tempfile(fileext = ".gpkg")
  sf::st_write(nbac, nbac_path, quiet = TRUE)

  out <- load_nbac_polys(nbac_path, sa_path, fire_years = 2000:2020)
  ## only the 2010 record is within fire_years; harmonised to YEAR + SIZE_HA
  expect_equal(unique(out$YEAR), 2010L)
  expect_equal(unique(out$SIZE_HA), 50)
})

test_that("load_nbac_polys() errors when year/size columns are absent", {
  sa_path <- withr::local_tempfile(fileext = ".gpkg")
  terra::writeVector(make_sa(), sa_path, overwrite = TRUE)

  bad <- sf::st_sf(
    SOMETHING = 1L,
    geometry = sf::st_sfc(
      sf::st_polygon(list(rbind(c(0, 0), c(100, 0), c(100, 100), c(0, 100), c(0, 0)))),
      crs = 3005
    )
  )
  bad_path <- withr::local_tempfile(fileext = ".gpkg")
  sf::st_write(bad, bad_path, quiet = TRUE)

  expect_snapshot(load_nbac_polys(bad_path, sa_path, fire_years = 2000:2020), error = TRUE)
})

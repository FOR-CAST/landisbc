test_that("bc_to_landis_severity_map() is the trapezoid kernel", {
  m <- bc_to_landis_severity_map()
  expect_named(m, c("Low", "Medium", "High"))
  expect_equal(m$Low, c(0.5, 0.5, 0, 0, 0))
  expect_equal(m$Medium, c(0, 0, 1, 0, 0))
  expect_equal(m$High, c(0, 0, 0, 0.5, 0.5))
})

rect <- function(x0, y0, w, h) {
  sf::st_polygon(list(rbind(c(x0, y0), c(x0 + w, y0), c(x0 + w, y0 + h), c(x0, y0 + h), c(x0, y0))))
}

test_that("compute_observed_severity_dist() area-weights + maps BC -> LANDIS 1..5", {
  bsp <- sf::st_sf(
    BURN_SEVERITY_RATING = factor(c("Low", "Medium", "High", "Unburned")),
    geometry = sf::st_sfc(
      rect(0, 0, 1, 2), ## Low, area 2
      rect(10, 0, 2, 2), ## Medium, area 4
      rect(20, 0, 2, 2), ## High, area 4
      rect(30, 0, 2, 2), ## Unburned -> dropped
      crs = 3005
    )
  )
  d <- compute_observed_severity_dist(bsp)
  expect_named(d, as.character(1:5))
  expect_equal(sum(d), 1)
  ## Low(2): .5/.5 -> 1,1 ; Medium(4): 4 -> class3 ; High(4): .5/.5 -> 2,2 ; total 10
  expect_equal(unname(d), c(0.1, 0.1, 0.4, 0.2, 0.2))
})

test_that("compute_observed_severity_dist() errors when no burned area remains", {
  bsp <- sf::st_sf(
    BURN_SEVERITY_RATING = factor("Unburned"),
    geometry = sf::st_sfc(rect(0, 0, 1, 1), crs = 3005)
  )
  expect_error(compute_observed_severity_dist(bsp), "no burned area")
})

## --- CanLaBS v2 (Option B) -------------------------------------------------

## 10x10 dNBR raster on a 1 m grid, values 1..100 (ascending == more severe).
make_dnbr <- function() {
  r <- terra::rast(
    nrows = 10,
    ncols = 10,
    xmin = 0,
    xmax = 10,
    ymin = 0,
    ymax = 10,
    crs = "EPSG:3005"
  )
  terra::values(r) <- 1:100
  names(r) <- "dNBR"
  r
}

## BC severity as three vertical strips partitioning the raster: Low/Medium/High
## with areas 50/30/20 (fractions 0.5/0.3/0.2). Their union covers the full grid.
make_bc_strips <- function() {
  sf::st_sf(
    BURN_SEVERITY_RATING = factor(c("Low", "Medium", "High"), levels = c("Low", "Medium", "High")),
    geometry = sf::st_sfc(
      rect(0, 0, 5, 10), ## Low, area 50
      rect(5, 0, 3, 10), ## Medium, area 30
      rect(8, 0, 2, 10), ## High, area 20
      crs = 3005
    )
  )
}

test_that("fit_canlabs_thresholds() reproduces BC class-area fractions", {
  fit <- fit_canlabs_thresholds(make_dnbr(), make_bc_strips())
  expect_equal(unname(fit$bc_fractions), c(0.5, 0.3, 0.2))
  ## quantiles of 1:100 at p = 0.5 and p = 0.8 (type 7)
  expect_equal(unname(fit$thresholds[["lowmed"]]), 50.5)
  expect_equal(unname(fit$thresholds[["medhigh"]]), 80.2)
  expect_equal(fit$n_pixels, 100L)
})

test_that("compute_observed_severity_dist_canlabs() classifies + maps to LANDIS 1..5", {
  fit <- fit_canlabs_thresholds(make_dnbr(), make_bc_strips())
  d <- compute_observed_severity_dist_canlabs(make_dnbr(), fit)
  expect_named(d, as.character(1:5))
  expect_equal(sum(d), 1)
  ## Low 0.5 -> .25/.25 ; Medium 0.3 -> class 3 ; High 0.2 -> .1/.1
  expect_equal(unname(d), c(0.25, 0.25, 0.3, 0.1, 0.1))
})

test_that("classify_canlabs_dnbr() accepts a bare threshold vector + returns hectares", {
  a <- classify_canlabs_dnbr(make_dnbr(), c(lowmed = 50.5, medhigh = 80.2))
  expect_named(a, c("Low", "Medium", "High"))
  ## 50/30/20 cells x 1 m^2 -> ha
  expect_equal(unname(a), c(50, 30, 20) * 1e-4)
})

test_that("fit_canlabs_thresholds() errors when BC has no burned classes", {
  bc <- sf::st_sf(
    BURN_SEVERITY_RATING = factor("Unburned"),
    geometry = sf::st_sfc(rect(0, 0, 1, 1), crs = 3005)
  )
  expect_error(fit_canlabs_thresholds(make_dnbr(), bc), "no BC burned polygons")
})

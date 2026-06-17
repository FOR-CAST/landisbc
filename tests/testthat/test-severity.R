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

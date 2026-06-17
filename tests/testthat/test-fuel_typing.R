test_that("normalize_fbp_codes() collapses seasonal/structural leaves", {
  x <- c("D-1", "D-2", "M-1", "M-2", "O-1a", "O-1b", "C-2", "S-1")
  expect_equal(
    normalize_fbp_codes(x),
    c("D-1/2", "D-1/2", "M-1/2", "M-1/2", "O-1a/b", "O-1a/b", "C-2", "S-1")
  )
})

test_that("normalize_fbp_codes() passes non-leaf codes through unchanged", {
  x <- c("C-3", "C-7", "W", "N")
  expect_identical(normalize_fbp_codes(x), x)
})

test_that("compare_fuel_typing() tabulates agreement on overlapping polygons", {
  skip_if_not_installed("sf")

  rect <- function(x0, y0, w, h) {
    sf::st_polygon(list(rbind(
      c(x0, y0),
      c(x0 + w, y0),
      c(x0 + w, y0 + h),
      c(x0, y0 + h),
      c(x0, y0)
    )))
  }

  bc <- sf::st_sf(
    FUEL_TYPE_CD = c("C-2", "C-3"),
    geometry = sf::st_sfc(rect(0, 0, 2, 2), rect(10, 0, 2, 2), crs = 3005)
  )
  prov <- sf::st_sf(
    FUEL_TYPE_CD = c("C-2", "C-5"),
    geometry = sf::st_sfc(rect(0, 0, 2, 2), rect(10, 0, 2, 2), crs = 3005)
  )

  cmp <- suppressWarnings(compare_fuel_typing(bc, prov))
  expect_equal(cmp$n, 2L)
  expect_equal(cmp$agreement, 0.5)
  expect_s3_class(cmp$confusion, "table")
})

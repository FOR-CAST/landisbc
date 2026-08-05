clim <- function() {
  tibble::tibble(
    bec_label = c(rep("AAmc1", 10L), rep("BBmm", 10L), rep("CChot", 10L), rep("DDthin", 2L)),
    MAT = c(rep(2, 10L), rep(2.5, 10L), rep(12, 10L), rep(2.1, 2L)),
    MAP = c(rep(700, 10L), rep(750, 10L), rep(2000, 10L), rep(710, 2L))
  )
}

test_that("distance is zero at the anchor and grows with climatic difference", {
  a <- bec_climate_analogues(clim(), "AAmc1", vars = c("MAT", "MAP"))

  expect_equal(a$bec_label[[1L]], "AAmc1")
  expect_equal(a$distance[[1L]], 0)
  expect_lt(a$distance[a$bec_label == "BBmm"], a$distance[a$bec_label == "CChot"])
})

test_that("variables are standardised, so precipitation does not swamp temperature", {
  ## Two labels displaced from the anchor by the SAME number of standard
  ## deviations, one in temperature and one in precipitation, must score equal.
  ## Unstandardised, the precipitation displacement would dominate entirely
  ## because it is ~200x larger in raw units.
  d <- tibble::tibble(
    bec_label = rep(c("anchor", "warm", "wet"), each = 5L),
    MAT = c(rep(2, 5L), rep(4, 5L), rep(2, 5L)),
    MAP = c(rep(700, 5L), rep(700, 5L), rep(1100, 5L))
  )
  a <- bec_climate_analogues(d, "anchor", vars = c("MAT", "MAP"))

  expect_equal(a$distance[a$bec_label == "warm"], a$distance[a$bec_label == "wet"])
  expect_gt(a$distance[a$bec_label == "warm"], 0)
})

test_that("a target given as a named vector is used directly", {
  a <- bec_climate_analogues(clim(), c(MAT = 12, MAP = 2000), vars = c("MAT", "MAP"))
  expect_equal(a$bec_label[[1L]], "CChot")
  expect_equal(a$distance[[1L]], 0)
})

test_that("labels with too few plots are flagged rather than dropped", {
  a <- bec_climate_analogues(clim(), "AAmc1", vars = c("MAT", "MAP"), min_plots = 5L)

  expect_true(a$sparse[a$bec_label == "DDthin"])
  expect_false(any(a$sparse[a$bec_label != "DDthin"]))
  expect_equal(nrow(a), 4L)
})

test_that("an unknown target label errors rather than returning nothing", {
  expect_snapshot(bec_climate_analogues(clim(), "NOSUCH", vars = "MAT"), error = TRUE)
})

test_that("a missing climate variable errors and names what is missing", {
  expect_snapshot(bec_climate_analogues(clim(), "AAmc1", vars = c("MAT", "CMD")), error = TRUE)
})

test_that("the cut-off yields a delimited string, excluding sparse labels by default", {
  a <- bec_climate_analogues(clim(), "AAmc1", vars = c("MAT", "MAP"), min_plots = 5L)
  far <- max(a$distance)

  expect_equal(bec_analogue_labels(a, 0), "AAmc1")
  expect_false(grepl("DDthin", bec_analogue_labels(a, far)))
  expect_true(grepl("DDthin", bec_analogue_labels(a, far, drop_sparse = FALSE)))
})

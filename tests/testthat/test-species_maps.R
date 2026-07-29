test_that("species_map_bc_vri is a strict one-to-one Title-case normalisation", {
  m <- species_map_bc_vri
  title_case <- function(x) {
    paste0(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x))))
  }

  expect_named(m)
  expect_type(m, "character")
  expect_equal(names(m), toupper(names(m)))
  expect_equal(unname(m), title_case(names(m)))
})

test_that("species_map_bc_vri has no duplicate codes or collapsed variants", {
  m <- species_map_bc_vri

  expect_equal(names(m)[duplicated(names(m))], character(0))
  ## values must stay distinct: variant lumping belongs in consuming projects,
  ## not here, so two codes sharing a value would silently destroy information
  expect_equal(unname(m)[duplicated(unname(m))], character(0))
})

test_that("broadleaf codes are not mistaken for conifers", {
  ## DR is Alnus rubra (red alder). It was previously documented as a
  ## "Douglas-fir variant" and grouped with FD / FDI, which led a consuming
  ## project to model a hardwood as subalpine fir.
  expect_equal(species_map_bc_vri[["DR"]], "Dr")
  expect_contains(names(species_map_bc_vri), c("AC", "ACB", "ACT", "AT", "DR", "E", "EP", "MB"))
})

test_that("CleanUpSpeciesCodeLayer normalises via the mapping", {
  expect_equal(CleanUpSpeciesCodeLayer("HW", mapping = species_map_bc_vri), "Hw")
  expect_equal(CleanUpSpeciesCodeLayer("DR", mapping = species_map_bc_vri), "Dr")
  ## a consuming project's lumping overrides win
  m <- species_map_bc_vri
  m["DR"] <- "At"
  expect_equal(CleanUpSpeciesCodeLayer("DR", mapping = m), "At")
})

test_that("CleanUpSpeciesCodeLayer treats missing species as no cohort", {
  expect_equal(CleanUpSpeciesCodeLayer(NA_character_, mapping = species_map_bc_vri), "")
  expect_equal(CleanUpSpeciesCodeLayer("", mapping = species_map_bc_vri), "")
  expect_equal(CleanUpSpeciesCodeLayer("NA", mapping = species_map_bc_vri), "")
})

test_that("CleanUpSpeciesCodeLayer errors on a code absent from the mapping", {
  expect_snapshot(error = TRUE, CleanUpSpeciesCodeLayer("ZZ", mapping = species_map_bc_vri))
})

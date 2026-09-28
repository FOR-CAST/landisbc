## ProcessInitialCommunitiesData(): species listed without an age of their own.

## Three grid-cell fragments, each a whole 100 m cell. Fragment 10001 lists three species and an
## age for the leading one only; 10002 gives its second species an age of its own; 10003 has no
## age for its leading species at all.
.ic_fragments <- function() {
  data.frame(
    MapCode = c(10001L, 10002L, 10003L),
    SPECIES_CD_1 = c("HW", "HW", "BL"),
    PROJ_AGE_1 = c(305, 305, NA),
    SPECIES_CD_2 = c("BL", "BL", "HW"),
    PROJ_AGE_2 = c(NA, 45, 90),
    SPECIES_CD_3 = c("SX", NA, NA),
    PROJ_AGE_3 = c(0, NA, NA),
    Area = 10000
  )
}

.process <- function(...) {
  ProcessInitialCommunitiesData(
    .ic_fragments(),
    AgeBinSize = 20L,
    grid_size = 100,
    SliverThreshold = 1,
    ...
  )
}

test_that("by default a species without an age of its own is dropped", {
  out <- .process(n_species = 3L)

  expect_equal(out$SpeciesCode[out$MapCode == "10001"], "Hw")
  ## its own age is kept, binned to the 20-year midpoint
  expect_equal(out$Age[out$MapCode == "10002" & out$SpeciesCode == "Bl"], 50L)
})

test_that("'leading' gives such a species the leading species' age", {
  out <- .process(n_species = 3L, missing_age = "leading")
  c1 <- out[out$MapCode == "10001", ]

  expect_setequal(c1$SpeciesCode, c("Hw", "Bl", "Sx"))
  expect_equal(unique(c1$Age), 310L)
  ## a recorded age is never overwritten
  expect_equal(out$Age[out$MapCode == "10002" & out$SpeciesCode == "Bl"], 50L)
})

test_that("a leading species without an age is dropped either way, and lends none", {
  for (m in c("drop", "leading")) {
    c3 <- .process(n_species = 3L, missing_age = m)
    c3 <- c3[c3$MapCode == "10003", ]
    expect_equal(c3$SpeciesCode, "Hw")
    expect_equal(c3$Age, 90L)
  }
})

test_that("n_species limits which species are read", {
  out <- .process(n_species = 2L, missing_age = "leading")
  expect_setequal(out$SpeciesCode[out$MapCode == "10001"], c("Hw", "Bl"))
})

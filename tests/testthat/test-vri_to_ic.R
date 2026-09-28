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

## ProcessInitialCommunitiesData(): how raw species codes are resolved.

test_that("species_mapping may be a function, and is called once per species field", {
  calls <- 0L
  lookup <- function(codes) {
    calls <<- calls + 1L
    c(HW = "Hw", BL = "Bl", SX = "Sx")[codes]
  }
  out <- .process(n_species = 3L, species_mapping = lookup, missing_age = "leading")

  expect_setequal(out$SpeciesCode[out$MapCode == "10001"], c("Hw", "Bl", "Sx"))
  ## three species fields, not one call per row
  expect_equal(calls, 3L)
})

test_that("a function mapping must return one code per input", {
  expect_snapshot(.process(species_mapping = function(codes) character(0)), error = TRUE)
})

test_that("an unmapped code errors by default and is dropped on request", {
  partial <- c(HW = "Hw") ## BL and SX unmapped

  expect_snapshot(.process(n_species = 3L, species_mapping = partial), error = TRUE)
  expect_snapshot(
    .process(n_species = 3L, species_mapping = function(codes) partial[codes]),
    error = TRUE
  )

  out <- .process(n_species = 3L, species_mapping = partial, unmapped = "drop")
  expect_setequal(out$SpeciesCode, "Hw")
})

test_that("a code that resolves to nothing never reaches the output", {
  ## a literal "NA" species code with a real age alongside it
  fragments <- .ic_fragments()
  fragments$SPECIES_CD_2[1] <- "NA"
  fragments$PROJ_AGE_2[1] <- 120

  out <- ProcessInitialCommunitiesData(
    fragments,
    AgeBinSize = 20L,
    grid_size = 100,
    SliverThreshold = 1,
    n_species = 2L
  )
  expect_equal(out$SpeciesCode[out$MapCode == "10001"], "Hw")
  expect_equal(sum(!nzchar(out$SpeciesCode)), 0L)
})

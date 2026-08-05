## NOTE: reference values are read off the source report directly --
## Kivari, Xu & Otukol (2010, rev. Jan 2011), Volume to Biomass Conversion for British Columbia
## Forests, Tables 2, 3, 4 and 11-16 -- not from the parsed data they are checking.

test_that("the conversion table is complete and internally consistent", {
  tbl <- kivari_volume_to_biomass
  expect_equal(nrow(tbl), 16L * 14L)
  expect_equal(dplyr::n_distinct(tbl$sp0), 16L)
  expect_equal(dplyr::n_distinct(tbl$bec_zone), 14L)
  expect_false(anyNA(tbl))
  expect_equal(tbl$total, tbl$bole + tbl$branches + tbl$bark + tbl$foliage, tolerance = 1e-6)
})

test_that("published coefficients are reproduced", {
  f <- function(sp, bec) {
    r <- kivari_volume_to_biomass
    unlist(r[r$sp0 == sp & r$bec_zone == bec, c("bole", "branches", "bark", "foliage")])
  }
  ## Table 4 / 11 / 12 / 13, ICH column -- the five groups an ICH project already uses.
  expect_equal(unname(f("PL", "ICH")), c(0.4286, 0.0475, 0.0428, 0.0430))
  expect_equal(unname(f("S", "ICH")), c(0.3917, 0.0670, 0.0413, 0.0334))
  expect_equal(unname(f("H", "ICH")), c(0.4302, 0.0635, 0.0596, 0.0278))
  expect_equal(unname(f("AT", "ICH")), c(0.4389, 0.0769, 0.0952, 0.0157))
  expect_equal(unname(f("B", "ICH")), c(0.3937, 0.0890, 0.0528, 0.0835))
  ## Douglas-fir in the Cariboo zones -- the reason this table was extracted.
  expect_equal(unname(f("F", "SBS")), c(0.3645, 0.1050, 0.0713, 0.0396))
  expect_equal(unname(f("F", "IDF")), c(0.3699, 0.1063, 0.0725, 0.0397))
})

test_that("every coefficient is published to exactly 4 decimals", {
  ## Regression: Table 4's AC/BG cell prints 0.4803 carrying a superscript footnote marker 6, and a
  ## naive parse read it as 0.48036. Any value with a 5th decimal means a footnote marker, a column
  ## collision, or a misread digit -- none of which should ship.
  for (cmp in c("bole", "branches", "bark", "foliage")) {
    v <- kivari_volume_to_biomass[[cmp]]
    expect_equal(v, round(v, 4L), tolerance = 0, info = cmp)
  }
  ac_bg <- kivari_volume_to_biomass
  expect_equal(ac_bg$bole[ac_bg$sp0 == "AC" & ac_bg$bec_zone == "BG"], 0.4803)
})

test_that("kivari_sp0() implements the report's assignment rules", {
  ## the plain letter rules
  expect_equal(
    kivari_sp0(c("BL", "CW", "EP", "FD", "HW", "LW", "SW")),
    c("B", "C", "E", "F", "H", "L", "S")
  )
  ## longer VRI forms resolve the same way as the two-character compilation codes
  expect_equal(kivari_sp0(c("FDI", "PLI", "SXW", "HWC")), c("F", "PL", "S", "H"))
  ## aspen is its own group; other A codes are cottonwood
  expect_equal(kivari_sp0(c("AT", "AC", "ACT")), c("AT", "AC", "AC"))
  ## the four pine groups
  expect_equal(
    kivari_sp0(c("PL", "PA", "PF", "PW", "PS", "PY")),
    c("PL", "PA", "PA", "PW", "PW", "PY")
  )
  ## yellow cedar takes CP and CY away from cedar
  expect_equal(kivari_sp0(c("CW", "CP", "CY", "YC")), c("C", "Y", "Y", "Y"))
  ## the odd reassignments
  expect_equal(
    kivari_sp0(c("XH", "XC", "TW", "GP", "QG", "RA")),
    c("D", "F", "H", "MB", "MB", "MB")
  )
  ## alder is D, not a Douglas-fir code
  expect_equal(kivari_sp0("DR"), "D")
  ## case and padding
  expect_equal(kivari_sp0(c(" fd ", "Pl")), c("F", "PL"))
  ## nothing to assign
  expect_equal(kivari_sp0(c(NA, "", "NA", "ZZ")), rep(NA_character_, 4L))
})

test_that("kivari_factor() looks up and recycles", {
  expect_equal(kivari_factor("PL", "ICH"), 0.5619)
  expect_equal(kivari_factor("FD", "SBS", "bole"), 0.3645)
  ## recycles either argument
  expect_length(kivari_factor(c("FD", "PL", "SW"), "SBS"), 3L)
  expect_length(kivari_factor("FD", c("SBS", "IDF", "ICH")), 3L)
  ## unmatched inputs come back NA rather than being dropped
  expect_equal(kivari_factor(c("PL", "ZZ"), "ICH"), c(0.5619, NA_real_))
  expect_equal(kivari_factor("PL", "NOSUCHZONE"), NA_real_)
  expect_length(kivari_factor(character(0), character(0)), 0L)
})

test_that("the supporting tables line up with the conversion table", {
  expect_setequal(kivari_sp0_codes$sp0, unique(kivari_volume_to_biomass$sp0))
  expect_setequal(kivari_sample_frequency$sp0, unique(kivari_volume_to_biomass$sp0))
  expect_setequal(unique(kivari_correlation$component), c("bole", "branches", "bark", "foliage"))
  ## the report names its lowest correlation: Py bark in IDF
  bark <- kivari_correlation[kivari_correlation$component == "bark", ]
  low <- bark[which.min(bark$r), ]
  expect_equal(low$sp0, "PY")
  expect_equal(low$bec_zone, "IDF")
  expect_equal(low$r, 0.3708)
})

test_that("the installed plain-text copy matches the shipped data", {
  csv <- system.file("extdata", "kivari_volume_to_biomass.csv", package = "landisbc")
  skip_if(!nzchar(csv))
  expect_equal(
    as.data.frame(utils::read.csv(csv, stringsAsFactors = FALSE)),
    as.data.frame(kivari_volume_to_biomass),
    tolerance = 1e-9
  )
})

## NOTE: reference column names are those published by the BC Forest Analysis
## and Inventory Branch ground-sample compilations, BC Data Catalogue record
## 824e684b-4114-4a05-a490-aa56332b57f4.

test_that("the leading-species code is the first two characters, upper-cased", {
  expect_equal(faib_leading_species_code(c("hw55", "SX 30", "Ba100")), c("HW", "SX", "BA"))
})

test_that("a blank species-percent field yields NA rather than an empty code", {
  expect_equal(faib_leading_species_code(c("", "  ", NA)), rep(NA_character_, 3L))
})

test_that("the leading-species percent is parsed from characters 3 to 5", {
  expect_equal(faib_leading_species_percent(c("HW55", "SX100", "BA 7")), c(55L, 100L, 7L))
})

test_that("an unparseable percent is NA, not an error", {
  expect_equal(faib_leading_species_percent(c("HW", "HWxx")), c(NA_integer_, NA_integer_))
})

test_that("PSP columns are renamed onto the non-PSP schema", {
  psp <- tibble::tibble(
    CLSTR_ID = "a",
    BA_HA_LIV = 1,
    STEMS_HA_LIV = 2,
    VHA_WSV_LIV = 3,
    SPB_CPCT_LIV = "HW55",
    AGE_TOT1 = 100,
    HTOP1 = 30
  )
  out <- faib_harmonise_psp_columns(psp)

  expect_true(all(c("BA_HA_LS", "STEMS_HA_LS", "VHA_WSV_LS", "SPB_CPCT_LS") %in% names(out)))
  expect_true(all(c("AGET_TLSO", "HT_TLSO") %in% names(out)))
  expect_false(any(c("VHA_WSV_LIV", "AGE_TOT1") %in% names(out)))
  expect_equal(out$VHA_WSV_LS, 3)
  expect_equal(out$AGET_TLSO, 100)
})

test_that("harmonising leaves a table that is already on the non-PSP schema alone", {
  non_psp <- tibble::tibble(CLSTR_ID = "a", VHA_WSV_LS = 3, AGET_TLSO = 100)
  expect_equal(faib_harmonise_psp_columns(non_psp), non_psp)
})

obs <- function() {
  tibble::tibble(
    species = c("Hw", "Hw", "Hw", "Hw", "Sx"),
    bec_zone = c("ICH", "ICH", "CWH", "ICH", "ICH"),
    bec_label = c("ICHmc1", "ICHmc2", "CWHvm1", "ICHmc1", "ICHmc1"),
    tsa = c("Kispiox TSA", "Bulkley TSA", "Kispiox TSA", "Kispiox TSA", "Kispiox TSA"),
    leading_pct = c(80L, 80L, 80L, 30L, 80L)
  )
}

filters <- function() {
  tibble::tibble(
    species = "Hw",
    bec_zone = "ICH",
    exclude_tsa = "Bulkley TSA",
    exclude_bec_label = "",
    min_leading_pct = 50L
  )
}

test_that("each filter clause drops what it names, and only that species survives", {
  out <- filter_ground_plot_obs(obs(), "Hw", filters())

  expect_equal(nrow(out), 1L)
  expect_equal(out$bec_label, "ICHmc1")
  expect_equal(out$leading_pct, 80L)
})

test_that("a species with no filter row keeps all of its observations", {
  out <- filter_ground_plot_obs(obs(), "Sx", filters())
  expect_equal(nrow(out), 1L)
})

test_that("blank filter fields are no-ops", {
  f <- tibble::tibble(
    species = "Hw",
    bec_zone = "",
    exclude_tsa = NA_character_,
    exclude_bec_label = "",
    min_leading_pct = 0L
  )
  expect_equal(nrow(filter_ground_plot_obs(obs(), "Hw", f)), 4L)
})

test_that("several excluded TSAs can be given semicolon-delimited", {
  f <- tibble::tibble(
    species = "Hw",
    bec_zone = "",
    exclude_tsa = "Bulkley TSA; Kispiox TSA",
    exclude_bec_label = "",
    min_leading_pct = 0L
  )
  expect_equal(nrow(filter_ground_plot_obs(obs(), "Hw", f)), 0L)
})

test_that("the species map decides which codes lump, and unmapped codes drop out", {
  plots <- tibble::tibble(
    CLSTR_ID = c("a", "b", "c"),
    SITE_IDENTIFIER = c(1L, 2L, 3L),
    VISIT_NUMBER = 1L,
    MEAS_YR = 2000L,
    UTIL = 4L,
    VHA_WSV_LS = c(100, 200, 300),
    SPC_LIVE_1 = c("AT", "EP", "ZZ"),
    SPC_LIVE_1_PCT = c(80L, 70L, 90L),
    AGET_TLSO = c(50, 60, 70),
    BEC_ZONE = "ICH",
    BECLABEL = "ICHmc1",
    TSA_DESC = "Kispiox TSA",
    SAMPLE_ESTABLISHMENT_TYPE = "PSP"
  )
  kivari <- tibble::tibble(species_group = "At", total = 0.5)

  ## both broadleaf codes map onto the single At slot; ZZ is not in the map
  out <- derive_ground_plot_obs(plots, kivari, c(AT = "At", EP = "At"))

  expect_equal(nrow(out), 2L)
  expect_setequal(out$species, "At")
  expect_setequal(out$leading_raw, c("AT", "EP"))
})

test_that("derive_ground_plot_obs() resolves a factor per plot's own BEC zone", {
  ## Regression: applying one zone's factor set to a pool spanning several zones is a systematic
  ## bias. Lodgepole pine converts at 0.5619 in the ICH, 0.5793 in the SBS and 0.5180 in the SBPS --
  ## a 12% spread across three zones a single Cariboo pool routinely contains.
  plots <- tibble::tibble(
    SITE_IDENTIFIER = c("a", "b"),
    CLSTR_ID = c("a1", "b1"),
    VISIT_NUMBER = 1L,
    MEAS_YR = 2000L,
    SAMPLE_ESTABLISHMENT_TYPE = "PSP_G",
    TSA_DESC = "Quesnel TSA",
    BEC_ZONE = c("ICH", "SBS"),
    BECLABEL = c("ICHmc1", "SBSdw1"),
    SPC_LIVE_1 = c("PL", "PL"),
    SPC_LIVE_1_PCT = 90L,
    AGET_TLSO = 100,
    UTIL = 4,
    VHA_WSV_LS = 100
  )
  map <- c(PL = "Pl")

  out <- derive_ground_plot_obs(plots, species_map = map)
  expect_equal(out$kivari_group, c("PL", "PL"))
  ## 100 m3/ha x factor x 0.5
  expect_equal(out$aboveground_c_mg_ha, 100 * c(0.5619, 0.5793) * 0.5)

  ## supplying `kivari` restores the single-factor behaviour
  legacy <- derive_ground_plot_obs(
    plots,
    kivari = tibble::tibble(species_group = "Pl", total = 0.5619),
    species_map = map
  )
  expect_equal(legacy$aboveground_c_mg_ha, rep(100 * 0.5619 * 0.5, 2L))
})

test_that("derive_ground_plot_obs() converts species the five-group table could not", {
  plots <- tibble::tibble(
    SITE_IDENTIFIER = "a",
    CLSTR_ID = "a1",
    VISIT_NUMBER = 1L,
    MEAS_YR = 2000L,
    SAMPLE_ESTABLISHMENT_TYPE = "PSP_G",
    TSA_DESC = "Quesnel TSA",
    BEC_ZONE = "SBS",
    BECLABEL = "SBSdw1",
    SPC_LIVE_1 = "FD",
    SPC_LIVE_1_PCT = 90L,
    AGET_TLSO = 100,
    UTIL = 4,
    VHA_WSV_LS = 100
  )
  out <- derive_ground_plot_obs(plots, species_map = c(FD = "Fd"))
  expect_equal(out$kivari_group, "F")
  expect_equal(out$aboveground_c_mg_ha, 100 * 0.5804 * 0.5)
})

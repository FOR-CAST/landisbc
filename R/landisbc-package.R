## Server-side bcdata query column names + the INTERSECTS CQL geometry predicate
## are evaluated non-standardly inside dplyr::filter()/select() on a bcdc_promise,
## and tidyterra/dplyr verbs reference bare column symbols non-standardly too.
utils::globalVariables(c(
  "FIRE_NUMBER", "FIRE_YEAR", "BURN_SEVERITY_RATING", "INTERSECTS",
  ## fuel-type WFS query columns
  "FUEL_TYPE_CD", "PERCENT_CONIFER", "M1_2_PERCENT_CONIFER", "PERCENT_DEAD_FIR",
  ## fire-data loader columns (NFDB / NBAC) referenced in tidyterra verbs
  "YEAR", "MONTH", "DAY", "DATE", "JULIAN_DAY", "SIZE_HA", "EcoCode",
  "MRSRD_Y", "MRSRD_A", ".data",
  ## fuel-typing confusion-matrix plot aesthetics
  "provincial", "bcwsft", "Freq"
))

#' @keywords internal
"_PACKAGE"

## All function calls in R/ are namespaced via pkg::fun().
NULL

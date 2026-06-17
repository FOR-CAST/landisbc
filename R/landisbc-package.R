## Server-side bcdata query column names + the INTERSECTS CQL geometry predicate
## are evaluated non-standardly inside dplyr::filter()/select() on a bcdc_promise.
utils::globalVariables(c(
  "FIRE_NUMBER", "FIRE_YEAR", "BURN_SEVERITY_RATING", "INTERSECTS"
))

#' @keywords internal
"_PACKAGE"

## All function calls in R/ are namespaced via pkg::fun().
NULL

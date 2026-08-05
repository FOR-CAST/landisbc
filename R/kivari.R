## Published BC volume-to-biomass conversion factors, shipped as package data so any BC project can
## use them without re-parsing a PDF. See data-raw/kivari.R for the extraction and its verification.

#' Volume-to-biomass conversion factors for British Columbia forests
#'
#' Regression coefficients converting stand whole-stem volume to aboveground
#' biomass components, by species group and BEC zone. Fitted by regression
#' without intercept, so biomass is simply `volume * coefficient`:
#'
#' ```
#' biomass_t_ha <- wsv_m3_ha * total
#' ```
#'
#' **Utilization level.** These convert whole-stem volume of trees with
#' `Dbh >= 4.0 cm` to biomass of trees with `Dbh >= 4.0 cm`. Pairing them with
#' volume compiled at any other utilization level pairs volumes with the wrong
#' conversion; the FAIB ground-plot compilations record this as `UTIL`, and
#' [assemble_faib_ground_plots()] filters to `UTIL == 4` for exactly this
#' reason. The source report also publishes factors for the 7.5, 12.5, 17.5 and
#' 22.5 cm levels, which are NOT included here.
#'
#' **Units.** Volume is m^3 ha^-1 and biomass is tonnes ha^-1, i.e. oven-dry
#' mass. To get CARBON, apply a carbon fraction yourself -- the coefficients do
#' not include one.
#'
#' **Coverage.** All 16 species groups x 14 BEC zones are populated, with no
#' gaps. Where the report had too little data to fit a (group, zone) stratum it
#' fell back to that group pooled over all zones, so a value being present is
#' not on its own evidence that it was fitted on local data. Judge that with
#' [kivari_sample_frequency] and [kivari_correlation].
#'
#' @format A tibble with 224 rows and 7 columns:
#' \describe{
#'   \item{sp0}{Species group code; see [kivari_sp0_codes] and [kivari_sp0()].}
#'   \item{bec_zone}{BEC zone code.}
#'   \item{bole}{Bole (wood) coefficient (report Table 4).}
#'   \item{branches}{Branch coefficient (report Table 11).}
#'   \item{bark}{Bark coefficient (report Table 12).}
#'   \item{foliage}{Foliage coefficient (report Table 13).}
#'   \item{total}{Sum of the four components. Total aboveground biomass.}
#' }
#'
#' @source Kivari, A., Xu, W., and Otukol, S. 2010 (revised January 2011).
#'   *Volume to Biomass Conversion for British Columbia Forests.* DRAFT.
#'   Forest Analysis and Inventory Branch, BC Ministry of Forests and Range.
#'   Tables 4, 11, 12 and 13.
#'   <https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/stewardship/forest-analysis-inventory/growth-yield/volume_to_biomass_conversion_report_edit_mp_jan_31_2011.pdf>
#'
#'   The report is marked DRAFT; confirm no superseding version exists before
#'   relying on it for published work. The tables are published only as a PDF --
#'   a BC Data Catalogue search returns no machine-readable version -- so they
#'   were parsed programmatically and checked against values independently in
#'   use. A plain-text copy is installed at
#'   `system.file("extdata", "kivari_volume_to_biomass.csv", package = "landisbc")`.
#'
#' @family volume-to-biomass conversion
#' @examples
#' # Douglas-fir in the Sub-Boreal Spruce zone
#' subset(kivari_volume_to_biomass, sp0 == "F" & bec_zone == "SBS")
"kivari_volume_to_biomass"

#' Correlation coefficients for the volume-to-biomass relationships
#'
#' How well each fitted biomass component tracks whole-stem volume, per species
#' group and BEC zone. Use it to judge whether a conversion factor is well
#' supported in the stratum you are applying it to. `NA` where the report
#' printed no value.
#'
#' The report's prose states that correlations "ranged from 0.3708 to 1.0000",
#' but its own foliage table prints 0.0023 for birch in SBPS and 0.3226 for
#' white pine in MH, both below that stated floor. The values here are as
#' printed; the prose is not reproduced.
#'
#' A missing correlation does NOT imply a missing stratum: [kivari_sample_frequency]
#' counts TREES while these are computed over PLOTS, so a stratum can hold many
#' trees in too few plots to correlate (spruce in AT: 183 trees, no bole
#' correlation).
#'
#' @format A tibble with 896 rows and 4 columns:
#' \describe{
#'   \item{sp0}{Species group code.}
#'   \item{bec_zone}{BEC zone code.}
#'   \item{component}{One of `"bole"`, `"branches"`, `"bark"`, `"foliage"`.}
#'   \item{r}{Correlation coefficient, or `NA`.}
#' }
#'
#' @source As [kivari_volume_to_biomass]; report Tables 5, 14, 15 and 16.
#' @family volume-to-biomass conversion
"kivari_correlation"

#' Sample-tree frequency behind the volume-to-biomass factors
#'
#' Number of sample TREES per species group and BEC zone. The thin strata are
#' where the conversion factors deserve least trust -- alder in MS, for
#' instance, carries a branch coefficient of 0.7003 against 0.1299 in ICH.
#' `NA` where the report printed no value.
#'
#' @format A tibble with 224 rows and 3 columns:
#' \describe{
#'   \item{sp0}{Species group code.}
#'   \item{bec_zone}{BEC zone code.}
#'   \item{n_trees}{Number of sample trees, or `NA`.}
#' }
#'
#' @source As [kivari_volume_to_biomass]; report Table 3.
#' @family volume-to-biomass conversion
"kivari_sample_frequency"

#' Species-group (`sp0`) codes used by the volume-to-biomass factors
#'
#' The 16 groups the conversion factors are keyed on, with the rule that assigns
#' a BC tree species code to each. [kivari_sp0()] implements the rules; this
#' table carries them in the report's own words so a caller can check the
#' implementation against the source.
#'
#' @format A tibble with 16 rows and 4 columns:
#' \describe{
#'   \item{sp0}{Species group code.}
#'   \item{genus}{Single-letter genus code.}
#'   \item{interpretation}{The report's plain-language description.}
#'   \item{rule}{The report's rule for assigning species codes to this group.}
#' }
#'
#' @source As [kivari_volume_to_biomass]; report Table 2.
#' @family volume-to-biomass conversion
"kivari_sp0_codes"

#' Assign BC tree species codes to volume-to-biomass species groups
#'
#' Implements the report's own assignment rules ([kivari_sp0_codes]). Most are
#' "anything starting with this letter", with a handful of explicit exceptions
#' that matter: `AT` is its own group rather than falling in with the other
#' `A` codes, the pines split four ways, and `CP` / `CY` go to yellow cedar
#' rather than to cedar.
#'
#' Matching is on the leading letters of the code, so both the two-character
#' forms the ground-plot compilations use (`"FD"`, `"PL"`, `"SW"`) and the
#' longer VRI forms (`"FDI"`, `"PLI"`, `"SXW"`) resolve correctly.
#'
#' @param species_code Character vector of BC tree species codes. Case is
#'   ignored.
#'
#' @return Character vector of `sp0` codes, `NA` where the code is empty or
#'   matches no rule (the report's `blank` row, "invalid code").
#'
#' @family volume-to-biomass conversion
#' @export
#' @examples
#' kivari_sp0(c("FD", "FDI", "PLI", "PA", "PY", "SW", "AT", "AC", "CW", "CY"))
kivari_sp0 <- function(species_code) {
  x <- toupper(trimws(as.character(species_code)))
  x[!nzchar(x) | x == "NA"] <- NA_character_

  first <- substr(x, 1L, 1L)
  two <- substr(x, 1L, 2L)

  ## Order matters: every branch below is an EXCEPTION to the letter rule that follows it.
  out <- dplyr::case_when(
    is.na(x) ~ NA_character_,
    ## A: aspen is its own group; everything else beginning A is cottonwood.
    two == "AT" ~ "AT",
    first == "A" ~ "AC",
    first == "B" ~ "B",
    ## C: yellow cedar takes CP and CY; the rest of C, plus I and J, are cedar.
    two %in% c("CP", "CY") ~ "Y",
    first %in% c("C", "I", "J") ~ "C",
    ## D: alder also claims XH, V and W.
    two == "XH" ~ "D",
    first %in% c("D", "V", "W") ~ "D",
    first == "E" ~ "E",
    ## F: Douglas-fir also claims XC.
    two == "XC" ~ "F",
    first == "F" ~ "F",
    ## H: hemlock also claims TW.
    two == "TW" ~ "H",
    first == "H" ~ "H",
    first == "L" ~ "L",
    ## M: maple also claims GP, QG, RA and K.
    two %in% c("GP", "QG", "RA") ~ "MB",
    first %in% c("K", "M") ~ "MB",
    ## P: four groups, three of them explicit exception lists.
    two %in% c("PA", "PF") ~ "PA",
    two %in% c("PS", "PW") ~ "PW",
    two == "PY" ~ "PY",
    first == "P" ~ "PL",
    first == "S" ~ "S",
    first == "Y" ~ "Y",
    .default = NA_character_
  )
  out
}

#' Look up volume-to-biomass conversion factors
#'
#' Convenience accessor over [kivari_volume_to_biomass]: takes BC species codes
#' and BEC zones and returns the matching factors, resolving the species group
#' with [kivari_sp0()].
#'
#' Vectorised and length-preserving, so it can be used inside a `mutate()` on a
#' table of plot records. Rows whose species or zone has no entry come back
#' `NA` rather than being dropped, so a caller can see and count what did not
#' convert instead of silently losing it.
#'
#' @param species_code Character vector of BC tree species codes.
#' @param bec_zone Character vector of BEC zone codes, recycled against
#'   `species_code`.
#' @param component Which coefficient to return: `"total"` (the default, all
#'   four components summed) or one of the individual components.
#'
#' @return Numeric vector the length of `species_code`.
#'
#' @family volume-to-biomass conversion
#' @export
#' @examples
#' kivari_factor(c("FD", "PL", "SW"), "SBS")
#' kivari_factor("FD", c("SBS", "IDF", "ICH"))
kivari_factor <- function(
  species_code,
  bec_zone,
  component = c("total", "bole", "branches", "bark", "foliage")
) {
  component <- match.arg(component)
  n <- max(length(species_code), length(bec_zone))
  sp0 <- kivari_sp0(rep_len(species_code, n))
  zone <- toupper(trimws(as.character(rep_len(bec_zone, n))))

  tbl <- landisbc::kivari_volume_to_biomass
  i <- match(paste(sp0, zone), paste(tbl$sp0, tbl$bec_zone))
  tbl[[component]][i]
}

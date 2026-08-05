## Extract the published BC volume-to-biomass conversion factors from the source report.
##
##   Kivari, A., Xu, W., and Otukol, S. 2010 (revised January 2011).
##   Volume to Biomass Conversion for British Columbia Forests. DRAFT.
##   Forest Analysis and Inventory Branch, BC Ministry of Forests and Range.
##
## The tables are published ONLY as a PDF -- a search of the BC Data Catalogue returns no
## machine-readable version -- so they are parsed here and shipped as package data. Parsed rather
## than transcribed, and checked against values independently in use, because a hand-copied 224-cell
## table is a transcription error waiting to happen.
##
## Requires the `poppler-utils` pdftotext binary. Not run at install or build time.
##
## Run from the package root:
##   Rscript-4.6.1 data-raw/kivari.R

stopifnot(nzchar(Sys.which("pdftotext")))

URL <- paste0(
  "https://www2.gov.bc.ca/assets/gov/farming-natural-resources-and-industry/forestry/",
  "stewardship/forest-analysis-inventory/growth-yield/",
  "volume_to_biomass_conversion_report_edit_mp_jan_31_2011.pdf"
)

pdf <- file.path(tempdir(), "kivari.pdf")
txt <- file.path(tempdir(), "kivari.txt")
if (!file.exists(pdf)) {
  utils::download.file(URL, pdf, mode = "wb", quiet = TRUE)
}
system2("pdftotext", c("-layout", shQuote(pdf), shQuote(txt)))
lines <- readLines(txt, warn = FALSE)

## The 14 BEC zones and 16 species groups (Sp0), in the order the report's tables use.
BEC <- c(
  "AT",
  "BG",
  "BWBS",
  "CDF",
  "CWH",
  "ESSF",
  "ICH",
  "IDF",
  "MH",
  "MS",
  "PP",
  "SBPS",
  "SBS",
  "SWB"
)
SP0 <- c("AC", "AT", "B", "C", "D", "E", "F", "H", "L", "MB", "PA", "PL", "PW", "PY", "S", "Y")

## ---- parsing -------------------------------------------------------------------------------------
##
## `pdftotext -layout` preserves column alignment, so a cell is located by WHERE it sits on the line,
## not by which token number it is. That matters: the correlation and sample-frequency tables have
## empty cells wherever a stratum had no data, so splitting on whitespace and taking the nth token
## silently shifts every value after the first gap into the wrong BEC zone.

#' Character position of each BEC label in a table's header line.
bec_positions <- function(header) {
  vapply(
    BEC,
    function(z) {
      ## match the label as a whole token, so "AT" does not match inside "SWB" etc.
      m <- gregexpr(paste0("(?<![A-Z])", z, "(?![A-Z])"), header, perl = TRUE)[[1L]]
      stopifnot(m[[1L]] > 0L)
      ## the column is right-aligned to the label's END in these tables
      as.integer(m[[1L]]) + attr(m, "match.length")[[1L]] - 1L
    },
    integer(1)
  )
}

#' Parse one Sp0-by-BEC table into a matrix, assigning each value to the nearest BEC column.
parse_table <- function(caption, allow_missing = FALSE) {
  ## The caption appears twice: once in the list of tables at the front, once above the table. Take
  ## the occurrence that is actually followed by a header line naming the BEC zones.
  hits <- grep(caption, lines)
  stopifnot(length(hits) > 0L)
  start <- NA_integer_
  for (h in hits) {
    win <- lines[h:min(h + 6L, length(lines))]
    hdr <- grep("\\bSBPS\\b.*\\bSBS\\b", win)
    if (length(hdr)) {
      start <- h + hdr[[1L]] - 1L
      break
    }
  }
  stopifnot(!is.na(start))

  pos <- bec_positions(lines[[start]])
  body <- lines[(start + 1L):min(start + 30L, length(lines))]

  out <- matrix(NA_real_, nrow = length(SP0), ncol = length(BEC), dimnames = list(SP0, BEC))
  for (sp in SP0) {
    hit <- grep(paste0("^\\s*", sp, "\\s+[0-9.]"), body)
    if (length(hit) == 0L) {
      stop("no row for Sp0 '", sp, "' under /", caption, "/", call. = FALSE)
    }
    ln <- body[[hit[[1L]]]]
    ## every numeric token, with the character position of its LAST digit
    m <- gregexpr("[0-9]+\\.[0-9]+|(?<=\\s)[0-9]+(?=\\s|$)", ln, perl = TRUE)[[1L]]
    starts <- as.integer(m)
    ends <- starts + attr(m, "match.length") - 1L
    vals <- as.numeric(substring(ln, starts, ends))
    ## drop a leading token that is part of the Sp0 label itself (none here, but be safe)
    keep <- starts > attr(regexpr(paste0("^\\s*", sp), ln), "match.length")
    starts <- starts[keep]
    ends <- ends[keep]
    vals <- vals[keep]
    ## assign each value to the BEC column whose label it ends nearest to
    col <- vapply(ends, function(e) which.min(abs(pos - e)), integer(1))
    if (anyDuplicated(col)) {
      stop("two values landed in the same BEC column for Sp0 '", sp, "'", call. = FALSE)
    }
    out[sp, col] <- vals
  }

  if (!allow_missing && anyNA(out)) {
    stop("unexpected empty cells under /", caption, "/", call. = FALSE)
  }
  out
}

components <- c(
  bole = "Regression Coefficients for bole \\(wood\\) biomass",
  branches = "Coefficients for branch biomass fitted by regression without intercept by BEC",
  bark = "Coefficients for bark biomass fitted by regression without intercept by BEC",
  foliage = "Coefficients for foliage biomass fitted by regression without intercept by BEC"
)
correlations <- c(
  bole = "Correlation coefficients for the fitted bole \\(wood\\) biomass and whole stem volume at",
  branches = "Correlation coefficients for branch biomass and whole stem volume for a 4.0cm DBH",
  bark = "Correlation coefficients for bark biomass and whole stem volume for a 4.0cm DBH",
  foliage = "Correlation Coefficients for foliage biomass and whole stem volume for a 4.0cm DBH"
)

long <- function(mats, value_name) {
  do.call(
    rbind,
    lapply(names(mats), function(cmp) {
      m <- mats[[cmp]]
      d <- data.frame(
        sp0 = rep(rownames(m), times = ncol(m)),
        bec_zone = rep(colnames(m), each = nrow(m)),
        component = cmp,
        v = as.vector(m),
        stringsAsFactors = FALSE
      )
      names(d)[names(d) == "v"] <- value_name
      d
    })
  )
}

coef_long <- long(lapply(components, parse_table), "value")
corr_long <- long(lapply(correlations, parse_table, allow_missing = TRUE), "r")

wide <- stats::reshape(
  coef_long,
  idvar = c("sp0", "bec_zone"),
  timevar = "component",
  direction = "wide"
)
names(wide) <- sub("^value\\.", "", names(wide))
wide$total <- round(wide$bole + wide$branches + wide$bark + wide$foliage, 6)

freq <- parse_table(
  "The frequency of the tree samples by BEC and Sp0 is given",
  allow_missing = TRUE
)

## ---- verification --------------------------------------------------------------------------------
##
## Five species' ICH coefficients are independently in use in a downstream project, taken from the
## report by hand. Reproducing them exactly is what establishes that the parse landed on the right
## rows AND the right columns -- a column-assignment error would show up here immediately.
known <- data.frame(
  sp0 = c("AT", "B", "H", "PL", "S"),
  bole = c(0.4389, 0.3937, 0.4302, 0.4286, 0.3917),
  branches = c(0.0769, 0.0890, 0.0635, 0.0475, 0.0670),
  bark = c(0.0952, 0.0528, 0.0596, 0.0428, 0.0413),
  foliage = c(0.0157, 0.0835, 0.0278, 0.0430, 0.0334),
  stringsAsFactors = FALSE
)
chk <- merge(known, wide[wide$bec_zone == "ICH", ], by = "sp0", suffixes = c(".known", ".parsed"))
stopifnot(nrow(chk) == nrow(known))
for (cmp in c("bole", "branches", "bark", "foliage")) {
  d <- abs(chk[[paste0(cmp, ".known")]] - chk[[paste0(cmp, ".parsed")]])
  stopifnot(all(d < 1e-9))
}

stopifnot(
  nrow(wide) == length(SP0) * length(BEC),
  !anyNA(wide$total),
  all(wide$bole > 0),
  all(wide$bole < 1),
  isTRUE(all.equal(max(corr_long$r, na.rm = TRUE), 1.0000))
)

## The report names its lowest correlation explicitly -- "Yellow pine (Pinus ponderosa - Py) bark
## biomass in the IDF BEC zone" at 0.3708 -- so reproducing that particular cell checks the
## correlation tables' column assignment the same way the ICH coefficients check the factor tables'.
bark <- corr_long[corr_long$component == "bark", ]
low_bark <- bark[which.min(bark$r), ]
stopifnot(low_bark$sp0 == "PY", low_bark$bec_zone == "IDF", isTRUE(all.equal(low_bark$r, 0.3708)))

## NOTE: the report's PROSE says correlations "ranged from 0.3708 to 1.0000" across all four
## correlation tables, but its own Table 16 prints 0.0023 for birch foliage in SBPS and 0.3226 for
## white pine foliage in MH. Both are below that stated floor. They are parsed as printed and shipped
## as printed -- silently clamping a published value to match a sentence about it would be worse --
## and the discrepancy is documented in ?kivari_correlation.
stopifnot(any(corr_long$r < 0.3708, na.rm = TRUE))

## NOT cross-checked against the sample-frequency table. It is tempting -- a stratum with no samples
## should have no correlation -- but Table 3 counts TREES while a correlation is computed over PLOTS,
## so a stratum can hold many trees in too few plots to correlate (spruce in AT: 183 trees, no bole
## correlation). Conflating the two produces false alarms, not checks.
##
## What IS an invariant: values must be assigned to columns in the order they appear on the line. A
## column shift that stayed within the row would otherwise be invisible, since `parse_table()` only
## rejects two values landing in the SAME column.
check_monotone <- function(caption) {
  hits <- grep(caption, lines)
  start <- NA_integer_
  for (h in hits) {
    win <- lines[h:min(h + 6L, length(lines))]
    hdr <- grep("\\bSBPS\\b.*\\bSBS\\b", win)
    if (length(hdr)) {
      start <- h + hdr[[1L]] - 1L
      break
    }
  }
  pos <- bec_positions(lines[[start]])
  body <- lines[(start + 1L):min(start + 30L, length(lines))]
  for (sp in SP0) {
    hit <- grep(paste0("^\\s*", sp, "\\s+[0-9.]"), body)[[1L]]
    ln <- body[[hit]]
    m <- gregexpr("[0-9]+\\.[0-9]+|(?<=\\s)[0-9]+(?=\\s|$)", ln, perl = TRUE)[[1L]]
    ends <- as.integer(m) + attr(m, "match.length") - 1L
    col <- vapply(ends, function(e) which.min(abs(pos - e)), integer(1))
    if (length(col) > 1L && any(diff(col) <= 0L)) {
      stop(
        "column assignment is out of order for Sp0 '",
        sp,
        "' under /",
        caption,
        "/",
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}
invisible(lapply(
  c(components, correlations, "The frequency of the tree samples by BEC and Sp0 is given"),
  check_monotone
))

cat(
  "verified: 5 x 4 known ICH coefficients reproduce exactly; the report's named lowest correlation",
  "(Py bark, IDF, 0.3708) lands in the right cell; every table assigns values to columns in order.\n"
)

## ---- assemble ------------------------------------------------------------------------------------

kivari_volume_to_biomass <- tibble::as_tibble(wide[
  order(wide$sp0, wide$bec_zone),
  c("sp0", "bec_zone", "bole", "branches", "bark", "foliage", "total")
])

kivari_correlation <- tibble::as_tibble(corr_long[
  order(corr_long$sp0, corr_long$bec_zone, corr_long$component),
])

kivari_sample_frequency <- tibble::as_tibble(data.frame(
  sp0 = rep(rownames(freq), times = ncol(freq)),
  bec_zone = rep(colnames(freq), each = nrow(freq)),
  n_trees = as.integer(as.vector(freq)),
  stringsAsFactors = FALSE
))
kivari_sample_frequency <- kivari_sample_frequency[
  order(kivari_sample_frequency$sp0, kivari_sample_frequency$bec_zone),
]

## Table 2, transcribed: 16 rows, short enough that transcription is safer than parsing prose.
kivari_sp0_codes <- tibble::tibble(
  sp0 = c("AC", "AT", "B", "C", "D", "E", "F", "H", "L", "MB", "PA", "PL", "PW", "PY", "S", "Y"),
  genus = c("A", "A", "B", "C", "D", "E", "F", "H", "L", "M", "P", "P", "P", "P", "S", "Y"),
  interpretation = c(
    "Cottonwood",
    "Aspen",
    "Balsam (abies)",
    "Cedar (excluding yellow cedar)",
    "Alder",
    "Birch",
    "Douglas-fir",
    "Hemlock",
    "Larch",
    "Maple",
    "White-bark pine",
    "Lodgepole pine, and jack pine",
    "White pine",
    "Yellow pine (Ponderosa pine)",
    "Spruce",
    "Yellow cedar"
  ),
  rule = c(
    "Anything but AT starting with 'A'",
    "AT",
    "Anything starting with 'B'",
    "Anything starting with 'C' (except 'CP' or 'CY'), 'I', or 'J'",
    "XH, anything starting with 'D', 'V', or 'W'",
    "Anything starting with 'E'",
    "XC, anything starting with 'F'",
    "TW, anything starting with 'H'",
    "Anything starting with 'L'",
    "GP, QG, RA, anything starting with 'K', or 'M'",
    "PA, PF",
    "Anything but PA, PF, PS, PW, or PY starting with 'P'",
    "PS, PW",
    "PY",
    "Anything starting with 'S'",
    "CP, CY, anything starting with 'Y'"
  )
)

## ---- write ---------------------------------------------------------------------------------------

usethis::use_data(
  kivari_volume_to_biomass,
  kivari_correlation,
  kivari_sample_frequency,
  kivari_sp0_codes,
  overwrite = TRUE
)

## A plain-text copy of the conversion factors, so the parse is reviewable in a diff and citable
## without loading R.
fs::dir_create("inst/extdata")
utils::write.csv(
  kivari_volume_to_biomass,
  "inst/extdata/kivari_volume_to_biomass.csv",
  row.names = FALSE
)

cat("wrote data/ (4 datasets) and inst/extdata/kivari_volume_to_biomass.csv\n")

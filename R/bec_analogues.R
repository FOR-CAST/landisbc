#' Rank BEC labels by climatic similarity to a target
#'
#' Ground-plot coverage for any one BEC variant is often too thin to fit a growth
#' curve against. Widening the pool to "the same zone" is the obvious move and
#' the wrong one: BEC zones span large climatic ranges, so a same-zone plot can
#' be less like the target than a plot from a neighbouring zone. This ranks every
#' label by actual climate instead.
#'
#' Distance is Euclidean over climate variables standardised by their spread
#' ACROSS LABELS, so each variable contributes comparably regardless of its
#' units. Temperature in degrees and precipitation in millimetres are otherwise
#' incommensurable, and precipitation would dominate purely through its larger
#' numeric range.
#'
#' Choosing the target is the consequential decision and is deliberately left to
#' the caller. Anchoring on the plots labelled as the target variant is the
#' obvious choice and can be badly wrong where those plots are few: a handful of
#' plots carrying a variant's name may sit well away from the landscape actually
#' being modelled, in which case anchoring on that landscape's own climate is the
#' better option. Compute both and compare before committing.
#'
#' @param climate A data frame with one row per plot, a `bec_label` column, and
#'   one column per climate variable.
#' @param target Named numeric vector giving the target climate, or the name of a
#'   `bec_label` whose median climate is used.
#' @param vars Character. Climate variables to compare on.
#' @param min_plots Integer. Labels with fewer plots than this still appear, but
#'   are flagged `sparse`, since a median over three plots is not a climate.
#'
#' @return A tibble ordered by `distance`, with `bec_label`, `n_plots`,
#'   `distance`, `sparse`, and the median of each variable.
#'
#' @family growth calibration helpers
#' @export
bec_climate_analogues <- function(
  climate,
  target,
  vars = c("MAT", "MAP", "MSP", "MCMT", "MWMT", "TD"),
  min_plots = 5L
) {
  stopifnot("bec_label" %in% names(climate))
  missing <- setdiff(vars, names(climate))
  if (length(missing)) {
    stop(
      "bec_climate_analogues(): `climate` is missing variable(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  labels <- climate |>
    dplyr::summarise(
      n_plots = dplyr::n(),
      dplyr::across(dplyr::all_of(vars), \(x) stats::median(x, na.rm = TRUE)),
      .by = "bec_label"
    )

  anchor <- if (is.character(target) && length(target) == 1L) {
    row <- dplyr::filter(labels, .data$bec_label == target)
    if (nrow(row) == 0L) {
      stop("bec_climate_analogues(): no plots carry bec_label '", target, "'.", call. = FALSE)
    }
    unlist(row[vars])
  } else {
    if (!all(vars %in% names(target))) {
      stop("bec_climate_analogues(): `target` must name every variable in `vars`.", call. = FALSE)
    }
    unlist(target[vars])
  }

  ## Spread across labels, not across plots: the comparison is between labels.
  spread <- vapply(labels[vars], stats::sd, numeric(1), na.rm = TRUE)
  spread[!is.finite(spread) | spread == 0] <- 1

  z <- sweep(sweep(as.matrix(labels[vars]), 2L, anchor, "-"), 2L, spread, "/")

  labels |>
    dplyr::mutate(distance = sqrt(rowSums(z^2)), sparse = .data$n_plots < min_plots) |>
    dplyr::relocate("bec_label", "n_plots", "distance", "sparse") |>
    dplyr::arrange(.data$distance)
}

#' Select analogue BEC labels within a distance cut-off
#'
#' The companion to [bec_climate_analogues()]: turns a ranking into the
#' semicolon-delimited string that `include_bec_labels` in the ground-plot
#' filter table expects.
#'
#' @param analogues A tibble from [bec_climate_analogues()].
#' @param max_distance Numeric. Cut-off; labels at or below it are kept.
#' @param drop_sparse Logical. Exclude labels flagged `sparse`.
#'
#' @return A single semicolon-delimited character string.
#'
#' @family growth calibration helpers
#' @export
bec_analogue_labels <- function(analogues, max_distance, drop_sparse = TRUE) {
  keep <- dplyr::filter(analogues, .data$distance <= max_distance)
  if (isTRUE(drop_sparse)) {
    keep <- dplyr::filter(keep, !.data$sparse)
  }
  paste(keep$bec_label, collapse = "; ")
}

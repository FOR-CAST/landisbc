#' Provenance for the FAIB ground-plot compilation
#'
#' Resolves the BC Data Catalogue record so the licence and last-modified date
#' travel with the data rather than being restated by hand.
#'
#' @return A one-row tibble of catalogue metadata.
#' @export
faib_catalogue_record <- function() {
  rec <- bcdata::bcdc_get_record(.faib_record_id)
  tibble::tibble(
    record_id = .faib_record_id,
    title = rec$title,
    organization = rec$organization$title %||% NA_character_,
    licence = rec$license_title %||% NA_character_,
    licence_url = rec$license_url %||% NA_character_,
    record_last_modified = as.character(rec$record_last_modified),
    ftp_root = .faib_ftp_root
  )
}

#' Download the FAIB ground-plot tables
#'
#' Fetches the four plot-level tables for both compilations, caching each file
#' under `dest`. Existing files are reused unless `overwrite = TRUE`, so a repeat
#' build does no network I/O.
#'
#' @param dest Character. Cache directory.
#' @param tsas Character vector of Timber Supply Area names for the non-PSP
#'   compilation (which is partitioned by TSA).
#' @param overwrite Logical. Re-download files that are already cached.
#'
#' @return Character vector of the cached file paths.
#' @export
fetch_faib_ground_plots <- function(dest, tsas = .faib_tsas, overwrite = FALSE) {
  fs::dir_create(dest)

  ## (relative URL, local file name) for every table we need.
  jobs <- c(
    ## PSP compilation: province-wide, filtered to our TSAs after the join.
    purrr::map(.faib_tables, function(tbl) {
      list(
        url = paste0(.faib_ftp_root, "/psp/", tbl, ".csv"),
        file = file.path(dest, paste0("psp__", tbl, ".csv"))
      )
    }),
    ## non-PSP compilation: one small directory per TSA.
    purrr::list_flatten(purrr::map(tsas, function(tsa) {
      purrr::map(.faib_tables, function(tbl) {
        list(
          url = paste0(
            .faib_ftp_root,
            "/non_psp/publish_by_tsa/",
            utils::URLencode(tsa),
            "/",
            tbl,
            ".csv"
          ),
          file = file.path(dest, paste0("nonpsp__", gsub(" ", "_", tsa), "__", tbl, ".csv"))
        )
      })
    }))
  )

  purrr::map_chr(jobs, function(job) {
    if (overwrite || !file.exists(job$file)) {
      utils::download.file(job$url, job$file, mode = "wb", quiet = TRUE)
    }
    job$file
  })
}

## Sample-establishment types excluded by default.
##
## PSP_R (permanent sample plots established by Research Branch) is excluded,
## matching the reference extract behind the published parameterization, which
## carries PSP_G plots only. Settled on the data rather than by convention: all
## 211 PSP_R plot visits in these Timber Supply Areas have NO site age
## (`AGET_TLSO` missing for every one), so they cannot contribute to a
## biomass-versus-age curve at all, and they are all Kalum TSA in the CWH zone --
## coastal, outside the ICH. The exclusion is currently a no-op for the
## calibration: the usable observation count is 879 either way.
##
## Kept explicit rather than left implicit so that a future compilation which
## does publish ages for these plots cannot silently enlarge the calibration set.
##
## Set `exclude_sample_types = character(0)` to include everything.
.faib_excluded_sample_types <- "PSP_R"

#' Assemble plot-visit records from the cached FAIB tables
#'
#' Joins header, visit, compiled-summary, and site-age tables and restricts to
#' the requested Timber Supply Areas at the 4 cm close-utilization level.
#'
#' `UTIL == 4` is not incidental: the Kivari volume-to-biomass factors are
#' specified at the 4.0 cm utilization level, so any other level would pair
#' volumes with the wrong conversion.
#'
#' @param files Character vector of cached file paths, from
#'   [fetch_faib_ground_plots()].
#' @param tsas Character vector of Timber Supply Area names to retain.
#' @param util Numeric. Close-utilization level to retain.
#' @param exclude_sample_types Character vector of `SAMPLE_ESTABLISHMENT_TYPE`
#'   values to drop. Defaults to `"PSP_R"`; see the note above that constant.
#'
#' @return A tibble, one row per plot visit.
#' @export
assemble_faib_ground_plots <- function(
  files,
  tsas = .faib_tsas,
  util = 4,
  exclude_sample_types = .faib_excluded_sample_types
) {
  ## Read every column as character before binding. The per-TSA files are small
  ## enough that a column can be entirely empty in one TSA and populated in
  ## another, which makes `read.csv()` type inference disagree across files and
  ## `bind_rows()` fail on, for example, <character> vs <logical>. Types are
  ## restored explicitly after the bind, for the columns that need them.
  read_one <- function(pattern) {
    hits <- grep(pattern, files, value = TRUE)
    stopifnot(length(hits) > 0L)
    purrr::map(hits, function(f) {
      utils::read.csv(f, stringsAsFactors = FALSE, colClasses = "character") |>
        tibble::as_tibble() |>
        ## The compilations are published with mixed column-name casing across
        ## tables; normalise so the joins below do not depend on it.
        dplyr::rename_with(toupper) |>
        faib_harmonise_psp_columns()
    }) |>
      dplyr::bind_rows()
  }

  ## Columns that must come back numeric/integer for the conversion and joins.
  as_num <- function(df, cols) {
    dplyr::mutate(df, dplyr::across(dplyr::any_of(cols), ~ suppressWarnings(as.numeric(.x))))
  }

  header <- read_one("faib_header\\.csv$")
  visits <- read_one("faib_sample_byvisit\\.csv$")
  smries <- read_one("faib_compiled_smries\\.csv$")
  siteage <- read_one("faib_compiled_spcsmries_siteage\\.csv$")

  keep <- function(df, cols) dplyr::select(df, dplyr::any_of(cols))

  ## BECLABEL is not published; it is zone + subzone + variant concatenated,
  ## which is how the compilation's own data dictionary defines it.
  header <- keep(
    header,
    c(
      "SITE_IDENTIFIER",
      "SAMPLE_ESTABLISHMENT_TYPE",
      "BEC_ZONE",
      "BEC_SBZ",
      "BEC_VAR",
      "TSA_DESC",
      "TFL",
      "OWN_SCHED_DESCRIP",
      "BC_ALBERS_X",
      "BC_ALBERS_Y",
      "GRID_SIZE",
      "GRID_BASE"
    )
  ) |>
    dplyr::mutate(
      BECLABEL = paste0(
        .data$BEC_ZONE,
        dplyr::coalesce(.data$BEC_SBZ, ""),
        dplyr::coalesce(.data$BEC_VAR, "")
      )
    ) |>
    dplyr::distinct(SITE_IDENTIFIER, .keep_all = TRUE)

  visits <- keep(
    visits,
    c(
      "CLSTR_ID",
      "SITE_IDENTIFIER",
      "VISIT_NUMBER",
      "MEAS_YR",
      "MEAS_DT",
      "FIRST_MSMT",
      "LAST_MSMT",
      "NO_PLOTS",
      "SAMP_TYP"
    )
  ) |>
    as_num(c("VISIT_NUMBER", "MEAS_YR", "NO_PLOTS")) |>
    dplyr::distinct(CLSTR_ID, .keep_all = TRUE)

  ## SPC_LIVE_1 is not published either. It is the first entry of SPB_CPCT_LS,
  ## which packs the top five species by live basal area as repeated
  ## 2-character code + 3-digit percentage (e.g. "BL086HM014" -> BL at 86%).
  smries <- keep(
    smries,
    c(
      "CLSTR_ID",
      "UTIL",
      "BA_HA_LS",
      "BA_HA_DS",
      "STEMS_HA_LS",
      "STEMS_HA_DS",
      "VHA_WSV_LS",
      "VHA_WSV_DS",
      "VHA_NTWB_LS",
      "VHA_NTWB_DS",
      "SPB_CPCT_LS"
    )
  ) |>
    as_num(c(
      "UTIL",
      "BA_HA_LS",
      "BA_HA_DS",
      "STEMS_HA_LS",
      "STEMS_HA_DS",
      "VHA_WSV_LS",
      "VHA_WSV_DS",
      "VHA_NTWB_LS",
      "VHA_NTWB_DS"
    )) |>
    dplyr::filter(.data$UTIL == util) |>
    dplyr::mutate(
      SPC_LIVE_1 = faib_leading_species_code(.data$SPB_CPCT_LS),
      SPC_LIVE_1_PCT = faib_leading_species_percent(.data$SPB_CPCT_LS)
    )

  ## The site-age table is per (CLSTR_ID, SPECIES): AGET_TLSO is the mean total
  ## age "for a given species", not a stand age. Join it on the LEADING species
  ## so the age matches the volume being converted. Taking one row per CLSTR_ID
  ## without this would silently pick an arbitrary species' age.
  siteage <- keep(
    siteage,
    c("CLSTR_ID", "SPECIES", "SI_M_TLSO", "HT_TLSO", "AGEB_TLSO", "AGET_TLSO")
  ) |>
    as_num(c("SI_M_TLSO", "HT_TLSO", "AGEB_TLSO", "AGET_TLSO")) |>
    dplyr::mutate(SPECIES = toupper(trimws(.data$SPECIES))) |>
    dplyr::distinct(CLSTR_ID, SPECIES, .keep_all = TRUE)

  smries |>
    dplyr::inner_join(visits, by = "CLSTR_ID") |>
    dplyr::inner_join(header, by = "SITE_IDENTIFIER") |>
    dplyr::left_join(siteage, by = c("CLSTR_ID" = "CLSTR_ID", "SPC_LIVE_1" = "SPECIES")) |>
    dplyr::filter(
      .data$TSA_DESC %in% tsas,
      !.data$SAMPLE_ESTABLISHMENT_TYPE %in% exclude_sample_types
    ) |>
    dplyr::arrange(.data$SITE_IDENTIFIER, .data$VISIT_NUMBER)
}

#' Extract the leading species' code from a composition string
#'
#' @param x Character vector of `SPB_CPCT_LS` composition strings.
#'
#' @return Character vector of two-letter species codes.
#' @export
faib_leading_species_code <- function(x) {
  code <- toupper(substr(as.character(x), 1L, 2L))
  code[!nzchar(trimws(code))] <- NA_character_
  code
}

#' Harmonize the PSP compilation's column names onto the non-PSP schema
#'
#' The two FAIB compilations publish the same quantities under different names.
#' Without this, binding them NA-fills every PSP row's volume, composition, and
#' age, which silently drops the PSP plots -- the bulk of the old-forest
#' observations -- from the calibration.
#'
#' **Plot summaries.** The non-PSP tables use `_LS` (live standing) and `_DS`
#' (dead standing). The PSP tables split the live pool into live / ingrowth /
#' veteran and publish the combined total as `_LIV`, with dead as `_D`. `_LIV`
#' is the counterpart of `_LS`, verified against 456 overlapping plot visits:
#' `VHA_WSV_LIV`, `BA_HA_LIV`, `STEMS_HA_LIV`, and `SPB_CPCT_LIV` each match
#' their `_LS` counterpart exactly. `_L` alone is *not* the counterpart -- it
#' excludes ingrowth and veterans and differs by up to 578 m3 ha^-1.
#'
#' **Site age.** The non-PSP table publishes plot-mean `AGET_TLSO` / `HT_TLSO` /
#' `SI_M_TLSO` / `AGEB_TLSO` per species. The PSP table instead publishes
#' per-plot values `AGE_TOT1..3`, `HTOP1..3`, `SI1..3`, `AGE_BH1..3`. The first
#' plot's value is taken, which reproduces the reference extract exactly on all
#' 430 overlapping PSP plot visits (the across-plot mean and maximum do not:
#' 72 and 272 matches respectively). Note this is plot 1, not a plot mean.
#'
#' @param df A data frame read from one FAIB table, column names upper-cased.
#'
#' @return `df` with any PSP-style columns renamed to their non-PSP equivalents.
faib_harmonise_psp_columns <- function(df) {
  renames <- c(
    ## plot summaries
    BA_HA_LS = "BA_HA_LIV",
    STEMS_HA_LS = "STEMS_HA_LIV",
    VHA_WSV_LS = "VHA_WSV_LIV",
    VHA_MER_LS = "VHA_MER_LIV",
    SPB_CPCT_LS = "SPB_CPCT_LIV",
    BA_HA_DS = "BA_HA_D",
    STEMS_HA_DS = "STEMS_HA_D",
    VHA_WSV_DS = "VHA_WSV_D",
    ## site age: first plot's value
    AGET_TLSO = "AGE_TOT1",
    AGEB_TLSO = "AGE_BH1",
    HT_TLSO = "HTOP1",
    SI_M_TLSO = "SI1"
  )
  ## Only rename PSP-style columns that are present AND whose target is absent,
  ## so a non-PSP table passes through untouched.
  present <- renames[renames %in% names(df) & !names(renames) %in% names(df)]
  if (length(present)) {
    df <- dplyr::rename(df, !!!present)
  }
  df
}

#' Derive aboveground-carbon observations from ground-plot records
#'
#' Converts live whole-stem volume to aboveground carbon with the Kivari factors
#' (`VHA_WSV_LS * total * 0.5`, giving Mg C ha^-1) and attaches the modelled
#' species each plot's leading species resolves to.
#'
#' The leading-species recoding matches the project's `vri_species_mapping`: all
#' broadleaf deciduous (cottonwood, birch, maple, alder) lump into the single
#' `At` slot, hemlock and spruce variants into `Hw` and `Sx`. `leading_raw` is
#' kept so figures can distinguish, for example, birch- from aspen-leading stands.
#'
#' @param plots A tibble from [assemble_faib_ground_plots()].
#' @param kivari A tibble from [read_kivari_coef()].
#' @param species_map Named character vector mapping FAIB leading-species codes
#'   (the names) onto modelled species codes (the values). Which codes lump
#'   together is a modelling decision belonging to the caller, not a property of
#'   the BC data: a project that models only one broadleaf species maps `AT`,
#'   `AC`, `EP` and the rest onto it, while one that separates them does not.
#'   Codes absent from the map yield `NA` and are dropped.
#'
#' @return A tibble of observations with `species`, `stand_age`, and
#'   `aboveground_c_mg_ha`.
#' @export
derive_ground_plot_obs <- function(plots, kivari, species_map) {
  factors <- stats::setNames(kivari$total, kivari$species_group)

  plots |>
    dplyr::mutate(
      leading_raw = toupper(trimws(.data$SPC_LIVE_1)),
      species = unname(species_map[.data$leading_raw]),
      kivari_group = kivari_species_group(.data$species),
      kivari_total = unname(factors[.data$kivari_group]),
      aboveground_c_mg_ha = .data$VHA_WSV_LS * .data$kivari_total * 0.5
    ) |>
    dplyr::transmute(
      site_identifier = .data$SITE_IDENTIFIER,
      cluster_id = .data$CLSTR_ID,
      visit_number = .data$VISIT_NUMBER,
      meas_year = .data$MEAS_YR,
      sample_type = .data$SAMPLE_ESTABLISHMENT_TYPE,
      tsa = .data$TSA_DESC,
      bec_zone = .data$BEC_ZONE,
      bec_label = .data$BECLABEL,
      leading_raw = .data$leading_raw,
      species = .data$species,
      leading_pct = .data$SPC_LIVE_1_PCT,
      stand_age = .data$AGET_TLSO,
      util = .data$UTIL,
      wsv_live_m3_ha = .data$VHA_WSV_LS,
      kivari_group = .data$kivari_group,
      aboveground_c_mg_ha = .data$aboveground_c_mg_ha
    ) |>
    dplyr::filter(!is.na(.data$aboveground_c_mg_ha), !is.na(.data$stand_age))
}

#' Extract the leading species' percentage from a composition string
#'
#' `SPB_CPCT_LS` packs the top five species as repeated 2-character code plus
#' 3-digit percentage, e.g. `"AC074BL011SW010PL005"`.
#'
#' @param x Character vector of composition strings.
#'
#' @return Integer vector of leading-species percentages.
#' @export
faib_leading_species_percent <- function(x) {
  suppressWarnings(as.integer(substr(as.character(x), 3L, 5L)))
}

#' Read the per-species ground-plot filters
#'
#' Which ground plots are admissible evidence for a species is a per-species
#' judgement, not a global one: a species well represented in the target BEC zone
#' can be restricted to it, while one absent from that zone has to borrow plots
#' from elsewhere or have none at all. Keeping those choices in a versioned table
#' rather than buried in plotting or scoring code means the figures, the fit
#' statistics and any write-up all state the same thing.
#'
#' @param path Character. Path to `ground_plot_filters.csv`.
#'
#' @return A tibble, one row per species.
#' @export
read_ground_plot_filters <- function(path) {
  out <- utils::read.csv(path, stringsAsFactors = FALSE) |>
    tibble::as_tibble() |>
    dplyr::mutate(dplyr::across(dplyr::any_of("min_leading_pct"), as.integer))
  ## `include_bec_labels` is optional, so a table written before analogues
  ## existed still reads.
  if (!"include_bec_labels" %in% names(out)) {
    out$include_bec_labels <- NA_character_
  }
  dplyr::select(
    out,
    species,
    bec_zone,
    include_bec_labels,
    exclude_tsa,
    exclude_bec_label,
    min_leading_pct
  )
}

#' Apply one species' ground-plot filter
#'
#' @param obs A tibble from [derive_ground_plot_obs()].
#' @param species Character. Modelled species code.
#' @param filters A tibble from [read_ground_plot_filters()]. An optional
#'   `include_bec_labels` column (semicolon-delimited BEC labels) admits named
#'   climatic analogues from outside the species' own BEC zone; see
#'   [bec_climate_analogues()].
#'
#' @return `obs` restricted to that species' observations.
#' @export
filter_ground_plot_obs <- function(obs, species, filters) {
  f <- dplyr::filter(filters, .data$species == !!species)
  out <- dplyr::filter(obs, .data$species == !!species)

  if (nrow(f) == 0L) {
    return(out)
  }

  blank <- function(x) is.na(x) || !nzchar(trimws(x))

  ## `include_bec_labels` ADDS analogue plots back after the zone restriction,
  ## so a species can be held to its own zone while still admitting named
  ## climatic analogues from outside it. Blank keeps the zone restriction alone,
  ## which is the conservative default; see bec_climate_analogues().
  ## NOT `f$include_bec_labels`: a tibble errors on `$` for an absent column, and
  ## a filter table written before analogues existed will not have it.
  extra <- if ("include_bec_labels" %in% names(f) && !blank(f[["include_bec_labels"]][[1L]])) {
    trimws(strsplit(f[["include_bec_labels"]][[1L]], ";", fixed = TRUE)[[1L]])
  } else {
    character(0)
  }

  if (!blank(f$bec_zone[[1L]])) {
    out <- dplyr::filter(out, .data$bec_zone == f$bec_zone[[1L]] | .data$bec_label %in% extra)
  }
  if (!blank(f$exclude_tsa[[1L]])) {
    drop <- trimws(strsplit(f$exclude_tsa[[1L]], ";", fixed = TRUE)[[1L]])
    out <- dplyr::filter(out, !.data$tsa %in% drop)
  }
  if (!blank(f$exclude_bec_label[[1L]])) {
    drop <- trimws(strsplit(f$exclude_bec_label[[1L]], ";", fixed = TRUE)[[1L]])
    out <- dplyr::filter(out, !.data$bec_label %in% drop)
  }
  if (!is.na(f$min_leading_pct[[1L]]) && f$min_leading_pct[[1L]] > 0L) {
    out <- dplyr::filter(
      out,
      !is.na(.data$leading_pct),
      .data$leading_pct >= f$min_leading_pct[[1L]]
    )
  }
  out
}

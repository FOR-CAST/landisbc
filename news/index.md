# Changelog

## landisbc 0.0.13

- New
  [`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md)
  ranks BEC labels by climatic similarity to a target, so a species
  whose own variant has too few ground plots to fit against can borrow
  from climatically comparable ones. Widening to “the same BEC zone” is
  the obvious move and the wrong one: zones span large climatic ranges,
  so a same-zone plot can be less like the target than one from a
  neighbouring zone. Distance is Euclidean over variables standardised
  by their spread across labels, otherwise precipitation in millimetres
  swamps temperature in degrees purely through its numeric range.
- Choosing the anchor is left to the caller because it is consequential
  and easy to get wrong: anchoring on the plots carrying the target
  variant’s name fails where those plots are few and unrepresentative of
  the landscape being modelled, in which case that landscape’s own
  climate is the better anchor. Compute both and compare.
- [`bec_analogue_labels()`](https://for-cast.github.io/landisbc/reference/bec_analogue_labels.md)
  turns a ranking plus a distance cut-off into the string
  `include_bec_labels` expects, and
  [`filter_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/filter_ground_plot_obs.md)
  gains that optional column: it admits named analogues back after the
  BEC-zone restriction, so a species can be held to its own zone while
  still borrowing. Blank keeps the zone restriction alone, which stays
  the default.

## landisbc 0.0.12

- New helpers for assembling BC ground-plot observations for
  growth-curve calibration, extracted from a project that had them
  inline.
  [`fetch_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/fetch_faib_ground_plots.md)
  and
  [`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md)
  pull and join the Forest Analysis and Inventory Branch ground-sample
  compilations (BC Data Catalogue record
  `824e684b-4114-4a05-a490-aa56332b57f4`, Open Government Licence -
  British Columbia), and
  [`faib_catalogue_record()`](https://for-cast.github.io/landisbc/reference/faib_catalogue_record.md)
  resolves the record so the provenance can be cited.
- [`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md)
  handles the fact that the PSP and non-PSP compilations publish the
  same quantities under DIFFERENT names – `VHA_WSV_LIV` and `AGE_TOT1`
  against `VHA_WSV_LS` and `AGET_TLSO`, among others. Binding them
  naively NA-fills every PSP row, silently discarding half the
  observations.
  [`faib_harmonise_psp_columns()`](https://for-cast.github.io/landisbc/reference/faib_harmonise_psp_columns.md)
  does the renaming.
- [`derive_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/derive_ground_plot_obs.md)
  converts whole-stem volume to aboveground carbon with the Kivari
  factors
  ([`read_kivari_coef()`](https://for-cast.github.io/landisbc/reference/read_kivari_coef.md),
  [`kivari_species_group()`](https://for-cast.github.io/landisbc/reference/kivari_species_group.md)).
  Which leading-species codes lump together is supplied by the caller as
  `species_map` rather than fixed here: that is a modelling decision,
  not a property of the BC data.
- [`read_ground_plot_filters()`](https://for-cast.github.io/landisbc/reference/read_ground_plot_filters.md)
  and
  [`filter_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/filter_ground_plot_obs.md)
  apply per-species BEC-zone, TSA, BEC-label and leading-species-percent
  restrictions from a versioned table, so which plots count as evidence
  for which species is recorded rather than buried in plotting or
  scoring code.
- [`read_tipsy_curves()`](https://for-cast.github.io/landisbc/reference/read_tipsy_curves.md)
  and
  [`read_tipsy_series()`](https://for-cast.github.io/landisbc/reference/read_tipsy_series.md)
  read TIPSY managed-stand yield curves and their run metadata.

## landisbc 0.0.11

- [`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md)
  computes the dominant BEC zone per grid cell raster-side instead of by
  polygon intersection. The old route intersected one polygon per grid
  cell (538,000 on a buffered 100 m LANDIS grid) against a BEC layer
  holding only ~12 distinct labels, then measured each sliver with
  [`terra::expanse()`](https://rspatial.github.io/terra/reference/expanse.html);
  it cost ~17.5 min. Rasterising BEC at 10x10 sub-cell resolution and
  taking the modal value per cell answers the same question in 5.8 s – a
  181x speedup on a real landscape.

- Output is materially unchanged: validated against the polygon result
  on a 402,200-cell vegetated landscape, the two agree on 99.9925% of
  cells with an identical NA pattern and identical raster dimensions.
  The 30 differing cells are near-ties on BEC boundaries; an exact
  coverage-fraction computation (`terra::rasterize(cover = TRUE)`, max
  over zones) reproduces the raster answer exactly, so those cells are
  floating-point tie-breaks in the old polygon path rather than error
  introduced by the new one.

## landisbc 0.0.10

- [`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md)
  no longer scales quadratically with grid size. The step that picks the
  dominant BEC zone per map code used a row-by-row loop whose membership
  test (`MapCode %in% names(dicMaxArea)`) rebuilt and rescanned the
  names of a list that grows to one entry per map code. Measured cost of
  that loop: 0.17 s at n = 5,000 rising to 11.7 s at n = 40,000 –
  timings quadruple as n doubles. On a 538,000-cell LANDIS grid the
  grid/BEC intersection runs to millions of rows and the loop did not
  complete in 5.8 h. It is replaced by a single stable sort plus
  `!duplicated()`, which is O(n log n) and takes ~2 s at n = 2,000,000.

- Results are unchanged. The loop compared with a strict `>` so the
  first maximum encountered won a tie; the replacement sorts with
  `method = "radix"` (stable) and keeps the first row per map code,
  which is the same row. [`order()`](https://rdrr.io/r/base/order.html)
  places NA areas last, so a real maximum now beats an NA area rather
  than erroring on a comparison against a stored `NA`. Equivalence was
  checked over 200 randomised inputs including NA map codes, NA and tied
  areas, and NA / empty / whitespace BEC labels.

## landisbc 0.0.9

- [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
  splits its fetch into one WFS request per `years_per_request` fire
  years (default 5) and drops fire years before coverage begins, instead
  of issuing a single request for the whole window. A single request
  spanning a regional scope and a long year window is liable to be
  rejected outright with “There was an issue sending this WFS request”:
  a district-scale scope puts the whole province in the `INTERSECTS`
  box, and a 1950:2024 window enumerates 75 values in the `CQL_FILTER`.
  Chunking keeps each request servable, and a failure now costs one
  chunk rather than the entire fetch.
- `BC_SEVERITY_FIRST_YEAR` (new, exported) records that BC Fire Burn
  Severity coverage begins in 2015 – the layer is pre/post-fire Landsat
  differencing and does not extend earlier (verified against the live
  layer: `FIRE_YEAR` 2010 and 2014 return no records, 2015 onward do).
  [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
  drops uncovered years before querying, so a 1950:2024 window no longer
  enumerates 65 years that can never match.

## landisbc 0.0.8

- All function calls in `R/` are now namespaced, restoring an invariant
  the package documents but nine calls in `vri_to_ic.R` had broken:
  `ext()` and `values()` (terra),
  [`setNames()`](https://rdrr.io/r/stats/setNames.html) (stats), and
  [`write.csv()`](https://rdrr.io/r/utils/write.table.html) (utils) were
  called bare, so they resolved only when the calling session happened
  to have those packages attached. `utils` is added to `Imports`.
  `R CMD check` is now clean (0 errors, 0 warnings, 0 notes).

- `species_map_bc_vri` common-name annotations are corrected against the
  Province of BC tree species code list, now cited in the documentation.
  `DR` was documented as a “Douglas-fir variant” and grouped with `FD` /
  `FDI`; it is red alder (*Alnus rubra*), a broadleaf hardwood, and is
  now grouped with the other broadleaf codes. A consuming project
  following the old grouping had been modelling it as a conifer. `AC` is
  poplar (not black cottonwood, which is `ACT`), `SXS` is a Sitka hybrid
  (not an interior-spruce hybrid), and `SW` is white spruce. Annotations
  for codes the provincial list does not enumerate are now marked as
  such. The mapping values themselves are unchanged, so no consuming
  project’s results change on this bullet alone.

- `species_map_bc_vri` gains tests covering its documented contract:
  names uppercase, values the Title-case form of the name, and no
  duplicate names or values (variant lumping belongs in consuming
  projects).

## landisbc 0.0.7

- CanLaBS v2 (Canada Landsat Burned Severity) integration for the
  Dynamic Fire `L_severity` loss, complementing the BC Fire Burn
  Severity layer (“Option B”):
  [`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
  loads the staged national dNBR mosaic cropped/masked to a scope,
  salvage-masked, and year-filtered via the caller’s NBAC perimeters;
  [`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md)
  fits two dNBR breakpoints that reproduce the BC Low/Medium/High area
  fractions over the years both datasets cover (BC calibrates the
  thresholds, CanLaBS supplies the longer 1985-2024 record);
  [`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md)
  and
  [`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md)
  produce the LANDIS 1..5 observed distribution via the same
  [`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md)
  trapezoid kernel, so the return contract matches
  [`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md).
  The threshold fit is empirical (data-quantile based), so it is
  invariant to whether the product stores raw or scaled dNBR.
  [`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md)
  records the layer filenames. The end-to-end fetch needs a real
  pipeline run against the staged rasters; the
  classification/fit/distribution logic is unit-tested.

## landisbc 0.0.6

- [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
  now reprojects the scope to EPSG:3005 before the bcdata `INTERSECTS`
  query (bcdata falls back to the geometry bounding box for large
  scopes, and a non-3005 scope yielded the wrong box and silently
  returned zero features), and returns an empty sf with the expected
  schema when no severity is found (an empty bcdata result collapses to
  geometry-only, which broke the downstream `mutate`).

## landisbc 0.0.5

- [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
  now reprojects the bcdata result to the scope CRS before `st_crop()`
  (it was cropping the EPSG:3005 query result against a project-CRS
  scope, erroring with “st_crs(x) == st_crs(y) is not TRUE”).

## landisbc 0.0.4

- New BC fire-and-fuel data helpers, de-duplicated from shared BC_HRV /
  gitanyow-partial-harvest code: the loaders tolerate either project’s
  column names (e.g. `YEAR`/`FIRE_YEAR`, `ADJ_HA`/`POLY_HA`/`HECTARES`),
  the fuel-typing WFS query is done in EPSG:3005 (robust to a
  non-standard sim CRS), and fuel-type area is computed from the raster
  resolution (not hardcoded per-cell).
- [`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md)
  rasterises the most-recent stand-replacing disturbance (since a cutoff
  year) to a rasterToMatch.
- [`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md)
  projects + crops NFDB fire points to a study-area rasterToMatch.
- [`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md)
  builds a confusion matrix and overall agreement between bcwsft and
  provincial fuel types.
- [`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md)
  summarises labelled area-by-fuel-type from the provincial fuel raster,
  with hectares from the raster resolution.
- [`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md)
  fetches the provincial “BC Wildfire Fire Fuel Types - Public” polygons
  over a study area (queried in EPSG:3005).
- [`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md)
  pulls the VEG_COMP Rank 1 VRI attributes the bcwsft decision tree
  needs (queried in EPSG:3005).
- [`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md)
  loads NBAC fire perimeters, harmonised (tolerant year + burned-area
  columns) and clipped to a study area.
- [`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md)
  loads NFDB fire points clipped to a study area, optionally tagged with
  a fire-ecoregion `EcoCode`.
- [`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md)
  loads NFDB fire polygons, filtered and clipped to a study area
  (tolerant year column).
- [`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md)
  collapses bcwsft season/leaf fuel-type codes to the provincial Public
  vocabulary.
- [`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md)
  plots the fuel-typing confusion matrix as a PNG heatmap.
- [`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md)
  rasterises the provincial fuel layer to a rasterToMatch, clipped +
  optionally disturbance-masked.
- [`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)
  runs the (Suggests-only) bcwsft R port over a VRI sf and attaches the
  assigned FBP fuel type.

## landisbc 0.0.3

- [`CreateLandisFiles()`](https://for-cast.github.io/landisbc/reference/CreateLandisFiles.md)
  gains a `species_mapping` argument (default `species_map_bc_vri`) and
  passes it through to
  [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md);
  previously the top-level entry point called
  [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md)
  without the (then mandatory) `species_mapping`, so it errored on use.
- [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md)
  now defaults `species_mapping` to `species_map_bc_vri` rather than
  requiring it, so the BC VRI path works out of the box.
- Documentation: corrected stale references to a non-existent
  `species_map_bc_ich` (an Interior Cedar-Hemlock-specific map that was
  never shipped) to the province-wide `species_map_bc_vri`, in
  [`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md),
  [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
  and the unknown-code error message.

## landisbc 0.0.2

- Added the Province of BC Vegetation Resource Inventory (‘VRI’) to
  LANDIS-II initial-communities pipeline
  ([`CreateLandisFiles()`](https://for-cast.github.io/landisbc/reference/CreateLandisFiles.md)
  and its components
  [`CreateLandisGrid()`](https://for-cast.github.io/landisbc/reference/CreateLandisGrid.md),
  [`CreateInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesData.md),
  [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md),
  [`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md),
  [`GetNonVegData()`](https://for-cast.github.io/landisbc/reference/GetNonVegData.md),
  [`CreateInitialCommunitiesMap()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesMap.md),
  [`CreateInitialCommunitiesCSVFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesCSVFile.md)),
  a pure-R/`terra` descendant of an arcpy implementation, producing a
  LANDIS-II initial-communities map (GeoTIFF) and CSV from VRI rank-1
  polygons.
- `species_map_bc_vri` exports a strict one-to-one Province of BC VRI
  species-code normalisation (raw `SPECIES_CD_N` -\> Title-case
  canonical form); study-area-specific variant lumping is layered on top
  in consuming projects via a named-vector merge.
- [`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md)
  standardises a VRI species code against a supplied mapping, failing
  loudly on unmapped codes.

## landisbc 0.0.1

- Initial package: British Columbia study-area helpers for LANDIS-II
  workflows, factored out so they can be reused across BC projects
  alongside the study-area-agnostic `landisutils`.
- [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md),
  [`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md),
  and
  [`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md)
  derive an observed fire-severity-class distribution from the Province
  of BC Fire Burn Severity (Historical) layer, in the 5-class format
  `landisutils::save_observed_fire_targets()` expects for Dynamic Fire
  calibration.

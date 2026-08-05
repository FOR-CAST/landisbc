# Package index

## All functions

- [`BC_SEVERITY_FIRST_YEAR`](https://for-cast.github.io/landisbc/reference/BC_SEVERITY_FIRST_YEAR.md)
  : First fire year with BC Fire Burn Severity coverage
- [`CleanMapCodes()`](https://for-cast.github.io/landisbc/reference/CleanMapCodes.md)
  : Assign canonical map codes, collapsing duplicate communities
- [`CleanUpSpeciesCodeLayer()`](https://for-cast.github.io/landisbc/reference/CleanUpSpeciesCodeLayer.md)
  : Standardise BC VRI species code variants against a user-supplied
  mapping
- [`CreateEcoRegionsMap()`](https://for-cast.github.io/landisbc/reference/CreateEcoRegionsMap.md)
  : Write the LANDIS-II ecoregions raster
- [`CreateInitialCommunitiesCSVFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesCSVFile.md)
  : Write the LANDIS-II v8 initial communities CSV file
- [`CreateInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesData.md)
  : Intersect VRI with the LANDIS grid
- [`CreateInitialCommunitiesMap()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesMap.md)
  : Write the LANDIS-II initial communities raster
- [`CreateInitialCommunitiesTextFile()`](https://for-cast.github.io/landisbc/reference/CreateInitialCommunitiesTextFile.md)
  : Write the LANDIS-II initial communities text configuration file
- [`CreateLandisFiles()`](https://for-cast.github.io/landisbc/reference/CreateLandisFiles.md)
  : Create all LANDIS-II initial communities and ecoregions files
- [`CreateLandisGrid()`](https://for-cast.github.io/landisbc/reference/CreateLandisGrid.md)
  : Create a regular grid clipped to the study area
- [`GetBECCodes()`](https://for-cast.github.io/landisbc/reference/GetBECCodes.md)
  : Extract BC Biogeoclimatic Ecosystem Classification (BEC) codes
- [`GetNonVegData()`](https://for-cast.github.io/landisbc/reference/GetNonVegData.md)
  : Find the dominant BCLCS Level-4 non-vegetation code for each grid
  cell
- [`MapCodeDataHash()`](https://for-cast.github.io/landisbc/reference/MapCodeDataHash.md)
  : Canonical hash of (SpeciesCode, Age) pairs within one map code
- [`MergeVRI1andVRI2Data()`](https://for-cast.github.io/landisbc/reference/MergeVRI1andVRI2Data.md)
  : Merge VRI1 and VRI2 initial-community data lists
- [`ProcessInitialCommunitiesData()`](https://for-cast.github.io/landisbc/reference/ProcessInitialCommunitiesData.md)
  : Convert the VRI–grid intersection to a (MapCode, SpeciesCode, Age)
  data frame
- [`WriteEcoRegionsTextFile()`](https://for-cast.github.io/landisbc/reference/WriteEcoRegionsTextFile.md)
  : Write the LANDIS-II ecoregions.txt input file
- [`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md)
  : Assemble plot-visit records from the cached FAIB tables
- [`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md)
  : BC -\> LANDIS Dynamic Fire severity-class mapping
- [`bec_analogue_labels()`](https://for-cast.github.io/landisbc/reference/bec_analogue_labels.md)
  : Select analogue BEC labels within a distance cut-off
- [`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md)
  : Rank BEC labels by climatic similarity to a target
- [`calc_recently_disturbed()`](https://for-cast.github.io/landisbc/reference/calc_recently_disturbed.md)
  : Rasterise the most-recent stand-replacing disturbance to the
  rasterToMatch
- [`canlabs_v2_files()`](https://for-cast.github.io/landisbc/reference/canlabs_v2_files.md)
  : CanLaBS v2 layer filenames
- [`classify_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/classify_canlabs_dnbr.md)
  : Classify CanLaBS dNBR into BC burned classes and return area by
  class
- [`clip_nfdb_to_study_area()`](https://for-cast.github.io/landisbc/reference/clip_nfdb_to_study_area.md)
  : Clip national NFDB fire points to a study area
- [`compare_fuel_typing()`](https://for-cast.github.io/landisbc/reference/compare_fuel_typing.md)
  : Confusion matrix and overall agreement between bcwsft and provincial
  fuel types
- [`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md)
  : Compute observed severity-class distribution for the calibration
  loss
- [`compute_observed_severity_dist_canlabs()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist_canlabs.md)
  : Observed severity-class distribution from CanLaBS dNBR
- [`derive_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/derive_ground_plot_obs.md)
  : Derive aboveground-carbon observations from ground-plot records
- [`faib_catalogue_record()`](https://for-cast.github.io/landisbc/reference/faib_catalogue_record.md)
  : Provenance for the FAIB ground-plot compilation
- [`faib_harmonise_psp_columns()`](https://for-cast.github.io/landisbc/reference/faib_harmonise_psp_columns.md)
  : Harmonize the PSP compilation's column names onto the non-PSP schema
- [`faib_leading_species_code()`](https://for-cast.github.io/landisbc/reference/faib_leading_species_code.md)
  : Extract the leading species' code from a composition string
- [`faib_leading_species_percent()`](https://for-cast.github.io/landisbc/reference/faib_leading_species_percent.md)
  : Extract the leading species' percentage from a composition string
- [`fetch_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/fetch_faib_ground_plots.md)
  : Download the FAIB ground-plot tables
- [`filter_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/filter_ground_plot_obs.md)
  : Apply one species' ground-plot filter
- [`fit_canlabs_thresholds()`](https://for-cast.github.io/landisbc/reference/fit_canlabs_thresholds.md)
  : Fit dNBR thresholds that reproduce BC's burned-class area fractions
- [`fuel_types_distribution()`](https://for-cast.github.io/landisbc/reference/fuel_types_distribution.md)
  : Labelled area-by-fuel-type summary of the provincial fuel raster
- [`get_bc_burn_severity_polys()`](https://for-cast.github.io/landisbc/reference/get_bc_burn_severity_polys.md)
  : Fetch BC Fire Burn Severity (Historical) polygons via bcdata
- [`get_canlabs_dnbr()`](https://for-cast.github.io/landisbc/reference/get_canlabs_dnbr.md)
  : Load CanLaBS v2 dNBR over a scope, salvage-masked and year-filtered
- [`get_fuel_types()`](https://for-cast.github.io/landisbc/reference/get_fuel_types.md)
  : Fetch the provincial "BC Wildfire Fire Fuel Types - Public" polygons
- [`get_vri_for_fuel_typing()`](https://for-cast.github.io/landisbc/reference/get_vri_for_fuel_typing.md)
  : Pull the VRI attributes the bcwsft decision tree needs, over a study
  area
- [`kivari_species_group()`](https://for-cast.github.io/landisbc/reference/kivari_species_group.md)
  : Map a modelled species code to its Kivari coefficient group
- [`load_nbac_polys()`](https://for-cast.github.io/landisbc/reference/load_nbac_polys.md)
  : Load NBAC fire perimeters, harmonised + clipped to a study area
- [`load_nfdb_points()`](https://for-cast.github.io/landisbc/reference/load_nfdb_points.md)
  : Load NFDB fire points, clipped + EcoCode-tagged to a study area
- [`load_nfdb_polys()`](https://for-cast.github.io/landisbc/reference/load_nfdb_polys.md)
  : Load NFDB fire polygons, filtered + clipped to a study area
- [`normalize_fbp_codes()`](https://for-cast.github.io/landisbc/reference/normalize_fbp_codes.md)
  : Collapse bcwsft season/leaf fuel-type codes to the provincial Public
  vocabulary
- [`plot_fuel_typing_comparison()`](https://for-cast.github.io/landisbc/reference/plot_fuel_typing_comparison.md)
  : Plot the fuel-typing confusion matrix as a heatmap
- [`prep_fuel_types_rast()`](https://for-cast.github.io/landisbc/reference/prep_fuel_types_rast.md)
  : Rasterise the provincial fuel layer to the rasterToMatch
- [`read_ground_plot_filters()`](https://for-cast.github.io/landisbc/reference/read_ground_plot_filters.md)
  : Read the per-species ground-plot filters
- [`read_kivari_coef()`](https://for-cast.github.io/landisbc/reference/read_kivari_coef.md)
  : Read the Kivari volume-to-biomass conversion factors
- [`read_tipsy_curves()`](https://for-cast.github.io/landisbc/reference/read_tipsy_curves.md)
  : Read the TIPSY yield curves
- [`read_tipsy_series()`](https://for-cast.github.io/landisbc/reference/read_tipsy_series.md)
  : Read the TIPSY per-series metadata
- [`run_bcwsft_fuel_typing()`](https://for-cast.github.io/landisbc/reference/run_bcwsft_fuel_typing.md)
  : Run the bcwsft R port over a VRI sf and attach the assigned FBP fuel
  type
- [`species_map_bc_vri`](https://for-cast.github.io/landisbc/reference/species_map_bc_vri.md)
  : BC VRI species code -\> canonical Title-case form (one-to-one)

# landisbc 0.0.8

* `species_map_bc_vri` common-name annotations are corrected against the Province of BC tree species code list, now cited in the documentation. `DR` was documented as a "Douglas-fir variant" and grouped with `FD` / `FDI`; it is red alder (*Alnus rubra*), a broadleaf hardwood, and is now grouped with the other broadleaf codes. A consuming project following the old grouping had been modelling it as a conifer. `AC` is poplar (not black cottonwood, which is `ACT`), `SXS` is a Sitka hybrid (not an interior-spruce hybrid), and `SW` is white spruce. Annotations for codes the provincial list does not enumerate are now marked as such. The mapping values themselves are unchanged, so no consuming project's results change on this bullet alone.
* `species_map_bc_vri` gains tests covering its documented contract: names uppercase, values the Title-case form of the name, and no duplicate names or values (variant lumping belongs in consuming projects).

# landisbc 0.0.7

* CanLaBS v2 (Canada Landsat Burned Severity) integration for the Dynamic Fire `L_severity` loss, complementing the BC Fire Burn Severity layer ("Option B"): `get_canlabs_dnbr()` loads the staged national dNBR mosaic cropped/masked to a scope, salvage-masked, and year-filtered via the caller's NBAC perimeters; `fit_canlabs_thresholds()` fits two dNBR breakpoints that reproduce the BC Low/Medium/High area fractions over the years both datasets cover (BC calibrates the thresholds, CanLaBS supplies the longer 1985-2024 record); `classify_canlabs_dnbr()` and `compute_observed_severity_dist_canlabs()` produce the LANDIS 1..5 observed distribution via the same `bc_to_landis_severity_map()` trapezoid kernel, so the return contract matches `compute_observed_severity_dist()`. The threshold fit is empirical (data-quantile based), so it is invariant to whether the product stores raw or scaled dNBR. `canlabs_v2_files()` records the layer filenames. The end-to-end fetch needs a real pipeline run against the staged rasters; the classification/fit/distribution logic is unit-tested.

# landisbc 0.0.6

* `get_bc_burn_severity_polys()` now reprojects the scope to EPSG:3005 before the bcdata `INTERSECTS` query (bcdata falls back to the geometry bounding box for large scopes, and a non-3005 scope yielded the wrong box and silently returned zero features), and returns an empty sf with the expected schema when no severity is found (an empty bcdata result collapses to geometry-only, which broke the downstream `mutate`).

# landisbc 0.0.5

* `get_bc_burn_severity_polys()` now reprojects the bcdata result to the scope CRS before `st_crop()` (it was cropping the EPSG:3005 query result against a project-CRS scope, erroring with "st_crs(x) == st_crs(y) is not TRUE").

# landisbc 0.0.4

* New BC fire-and-fuel data helpers, de-duplicated from shared BC_HRV / gitanyow-partial-harvest code: the loaders tolerate either project's column names (e.g. `YEAR`/`FIRE_YEAR`, `ADJ_HA`/`POLY_HA`/`HECTARES`), the fuel-typing WFS query is done in EPSG:3005 (robust to a non-standard sim CRS), and fuel-type area is computed from the raster resolution (not hardcoded per-cell).
* `calc_recently_disturbed()` rasterises the most-recent stand-replacing disturbance (since a cutoff year) to a rasterToMatch.
* `clip_nfdb_to_study_area()` projects + crops NFDB fire points to a study-area rasterToMatch.
* `compare_fuel_typing()` builds a confusion matrix and overall agreement between bcwsft and provincial fuel types.
* `fuel_types_distribution()` summarises labelled area-by-fuel-type from the provincial fuel raster, with hectares from the raster resolution.
* `get_fuel_types()` fetches the provincial "BC Wildfire Fire Fuel Types - Public" polygons over a study area (queried in EPSG:3005).
* `get_vri_for_fuel_typing()` pulls the VEG_COMP Rank 1 VRI attributes the bcwsft decision tree needs (queried in EPSG:3005).
* `load_nbac_polys()` loads NBAC fire perimeters, harmonised (tolerant year + burned-area columns) and clipped to a study area.
* `load_nfdb_points()` loads NFDB fire points clipped to a study area, optionally tagged with a fire-ecoregion `EcoCode`.
* `load_nfdb_polys()` loads NFDB fire polygons, filtered and clipped to a study area (tolerant year column).
* `normalize_fbp_codes()` collapses bcwsft season/leaf fuel-type codes to the provincial Public vocabulary.
* `plot_fuel_typing_comparison()` plots the fuel-typing confusion matrix as a PNG heatmap.
* `prep_fuel_types_rast()` rasterises the provincial fuel layer to a rasterToMatch, clipped + optionally disturbance-masked.
* `run_bcwsft_fuel_typing()` runs the (Suggests-only) bcwsft R port over a VRI sf and attaches the assigned FBP fuel type.

# landisbc 0.0.3

* `CreateLandisFiles()` gains a `species_mapping` argument (default `species_map_bc_vri`) and passes it through to `ProcessInitialCommunitiesData()`; previously the top-level entry point called `ProcessInitialCommunitiesData()` without the (then mandatory) `species_mapping`, so it errored on use.
* `ProcessInitialCommunitiesData()` now defaults `species_mapping` to `species_map_bc_vri` rather than requiring it, so the BC VRI path works out of the box.
* Documentation: corrected stale references to a non-existent `species_map_bc_ich` (an Interior Cedar-Hemlock-specific map that was never shipped) to the province-wide `species_map_bc_vri`, in `CleanUpSpeciesCodeLayer()`, `ProcessInitialCommunitiesData()`, and the unknown-code error message.

# landisbc 0.0.2

* Added the Province of BC Vegetation Resource Inventory ('VRI') to LANDIS-II initial-communities pipeline (`CreateLandisFiles()` and its components `CreateLandisGrid()`, `CreateInitialCommunitiesData()`, `ProcessInitialCommunitiesData()`, `CleanMapCodes()`, `GetNonVegData()`, `CreateInitialCommunitiesMap()`, `CreateInitialCommunitiesCSVFile()`), a pure-R/`terra` descendant of an arcpy implementation, producing a LANDIS-II initial-communities map (GeoTIFF) and CSV from VRI rank-1 polygons.
* `species_map_bc_vri` exports a strict one-to-one Province of BC VRI species-code normalisation (raw `SPECIES_CD_N` -> Title-case canonical form); study-area-specific variant lumping is layered on top in consuming projects via a named-vector merge.
* `CleanUpSpeciesCodeLayer()` standardises a VRI species code against a supplied mapping, failing loudly on unmapped codes.

# landisbc 0.0.1

* Initial package: British Columbia study-area helpers for LANDIS-II workflows, factored out so they can be reused across BC projects alongside the study-area-agnostic `landisutils`.
* `get_bc_burn_severity_polys()`, `bc_to_landis_severity_map()`, and `compute_observed_severity_dist()` derive an observed fire-severity-class distribution from the Province of BC Fire Burn Severity (Historical) layer, in the 5-class format `landisutils::save_observed_fire_targets()` expects for Dynamic Fire calibration.

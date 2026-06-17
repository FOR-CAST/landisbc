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

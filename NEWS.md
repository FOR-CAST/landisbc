# landisbc 0.0.1

* Initial package: British Columbia study-area helpers for LANDIS-II workflows, factored out so they can be reused across BC projects alongside the study-area-agnostic `landisutils`.
* `get_bc_burn_severity_polys()`, `bc_to_landis_severity_map()`, and `compute_observed_severity_dist()` derive an observed fire-severity-class distribution from the Province of BC Fire Burn Severity (Historical) layer, in the 5-class format `landisutils::save_observed_fire_targets()` expects for Dynamic Fire calibration.

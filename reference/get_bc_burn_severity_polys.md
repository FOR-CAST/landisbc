# Fetch BC Fire Burn Severity (Historical) polygons via bcdata

Returns the Province of British Columbia's polygon-level burn-severity
ratings (one record per FIRE_NUMBER / FIRE_YEAR / BURN_SEVERITY_RATING
combination) for the requested fire years, clipped to `scope_polys`.
Used to compute the observed severity-class distribution for Dynamic
Fire calibration via
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md).

## Usage

``` r
get_bc_burn_severity_polys(scope_polys, fire_years, years_per_request = 5L)
```

## Arguments

- scope_polys:

  `sf` POLYGON in the project CRS (e.g. BC Albers) covering the
  fire-regime ecoregion(s) the calibration targets.

- fire_years:

  Integer vector of fire years. Years before `BC_SEVERITY_FIRST_YEAR`
  carry no data and are dropped before querying.

- years_per_request:

  Fire years per WFS request (default `5`). Lower it if the service
  rejects requests for a very large `scope_polys`.

## Value

An `sf` data frame with columns `FIRE_NUMBER`, `FIRE_YEAR`,
`BURN_SEVERITY_RATING` (factor: Unburned / Low / Medium / High /
Unknown) and polygon geometry clipped to `scope_polys`.

## Details

Filters on `FIRE_YEAR %in% fire_years` server-side via bcdata's lazy
geodata query, so only polygons in the requested window are downloaded.

**Spatial scope.** BC Fire Burn Severity is assessed only for fires with
usable pre/post-fire Landsat coverage, so its spatial coverage is much
sparser than fire perimeters. At a single study area's scale the window
may yield only a handful of assessed polygons – too few for a
representative distribution – so `scope_polys` is typically the full
fire-regime ecoregion(s) the study area falls within (not the study area
itself), giving a defensible regional reference. BC severity coverage
starts in 2015; earlier fire years contribute no observed severity data.

The bcdata source is the Province of BC "Fire Burn Severity
(Historical)" layer (Forests catalogue record
`c58a54e5-76b7-4921-94a7-b5998484e697`, object
`WHSE_FOREST_VEGETATION.VEG_BURN_SEVERITY_SP`).

**Request size.** The fetch is split into one WFS request per
`years_per_request` fire years, and years before coverage begins are
dropped entirely. A single request spanning a regional scope and a long
year window is liable to be rejected outright ("There was an issue
sending this WFS request") – a district-scale scope crossed with a
75-year window put the whole province in the `INTERSECTS` box and
enumerated 75 values in the `CQL_FILTER`. Chunking keeps each request
small enough to be served, and a failure costs one chunk rather than the
whole fetch.

## See also

Other BC fire severity:
[`BC_SEVERITY_FIRST_YEAR`](https://for-cast.github.io/landisbc/reference/BC_SEVERITY_FIRST_YEAR.md),
[`bc_to_landis_severity_map()`](https://for-cast.github.io/landisbc/reference/bc_to_landis_severity_map.md),
[`compute_observed_severity_dist()`](https://for-cast.github.io/landisbc/reference/compute_observed_severity_dist.md)

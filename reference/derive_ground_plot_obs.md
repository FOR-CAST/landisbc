# Derive aboveground-carbon observations from ground-plot records

Converts live whole-stem volume to aboveground carbon with the published
volume-to-biomass factors (`VHA_WSV_LS * total * carbon_fraction`,
giving Mg C ha^-1) and attaches the modelled species each plot's leading
species resolves to.

## Usage

``` r
derive_ground_plot_obs(
  plots,
  kivari = NULL,
  species_map,
  carbon_fraction = 0.5
)
```

## Arguments

- plots:

  A tibble from
  [`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md).

- kivari:

  Optional tibble from
  [`read_kivari_coef()`](https://for-cast.github.io/landisbc/reference/read_kivari_coef.md).
  `NULL` (the default) uses the full published tables, resolving a
  factor per plot from its BEC zone and leading species. Supplying one
  restores the older behaviour of a single factor per species group
  applied to every plot regardless of zone.

- species_map:

  Named character vector mapping FAIB leading-species codes (the names)
  onto modelled species codes (the values). Which codes lump together is
  a modelling decision belonging to the caller, not a property of the BC
  data: a project that models only one broadleaf species maps `AT`,
  `AC`, `EP` and the rest onto it, while one that separates them does
  not. Codes absent from the map yield `NA` and are dropped.

- carbon_fraction:

  Numeric. Fraction of oven-dry biomass that is carbon. The published
  factors convert volume to BIOMASS; this converts biomass to carbon.

## Value

A tibble of observations with `species`, `stand_age`, and
`aboveground_c_mg_ha`.

## Details

By default the factor is looked up PER PLOT from its own BEC zone and
its own leading species, via
[`kivari_factor()`](https://for-cast.github.io/landisbc/reference/kivari_factor.md).
This matters whenever the plot pool spans more than one zone: the
factors differ by zone, and applying a single zone's set across a mixed
pool is a systematic bias, not noise.

The leading-species recoding matches the project's
`vri_species_mapping`: all broadleaf deciduous (cottonwood, birch,
maple, alder) lump into the single `At` slot, hemlock and spruce
variants into `Hw` and `Sx`. `leading_raw` is kept so figures can
distinguish, for example, birch- from aspen-leading stands.

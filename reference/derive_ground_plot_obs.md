# Derive aboveground-carbon observations from ground-plot records

Converts live whole-stem volume to aboveground carbon with the Kivari
factors (`VHA_WSV_LS * total * 0.5`, giving Mg C ha^-1) and attaches the
modelled species each plot's leading species resolves to.

## Usage

``` r
derive_ground_plot_obs(plots, kivari, species_map)
```

## Arguments

- plots:

  A tibble from
  [`assemble_faib_ground_plots()`](https://for-cast.github.io/landisbc/reference/assemble_faib_ground_plots.md).

- kivari:

  A tibble from
  [`read_kivari_coef()`](https://for-cast.github.io/landisbc/reference/read_kivari_coef.md).

- species_map:

  Named character vector mapping FAIB leading-species codes (the names)
  onto modelled species codes (the values). Which codes lump together is
  a modelling decision belonging to the caller, not a property of the BC
  data: a project that models only one broadleaf species maps `AT`,
  `AC`, `EP` and the rest onto it, while one that separates them does
  not. Codes absent from the map yield `NA` and are dropped.

## Value

A tibble of observations with `species`, `stand_age`, and
`aboveground_c_mg_ha`.

## Details

The leading-species recoding matches the project's
`vri_species_mapping`: all broadleaf deciduous (cottonwood, birch,
maple, alder) lump into the single `At` slot, hemlock and spruce
variants into `Hw` and `Sx`. `leading_raw` is kept so figures can
distinguish, for example, birch- from aspen-leading stands.

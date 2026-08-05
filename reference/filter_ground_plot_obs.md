# Apply one species' ground-plot filter

Apply one species' ground-plot filter

## Usage

``` r
filter_ground_plot_obs(obs, species, filters)
```

## Arguments

- obs:

  A tibble from
  [`derive_ground_plot_obs()`](https://for-cast.github.io/landisbc/reference/derive_ground_plot_obs.md).

- species:

  Character. Modelled species code.

- filters:

  A tibble from
  [`read_ground_plot_filters()`](https://for-cast.github.io/landisbc/reference/read_ground_plot_filters.md).
  Two optional semicolon-delimited columns refine the selection:
  `include_bec_labels` admits named climatic analogues from outside the
  species' own BEC zone (see
  [`bec_climate_analogues()`](https://for-cast.github.io/landisbc/reference/bec_climate_analogues.md)),
  and `include_leading` restricts which raw species codes count for the
  modelled species.

## Value

`obs` restricted to that species' observations.

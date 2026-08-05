# Harmonize the PSP compilation's column names onto the non-PSP schema

The two FAIB compilations publish the same quantities under different
names. Without this, binding them NA-fills every PSP row's volume,
composition, and age, which silently drops the PSP plots – the bulk of
the old-forest observations – from the calibration.

## Usage

``` r
faib_harmonise_psp_columns(df)
```

## Arguments

- df:

  A data frame read from one FAIB table, column names upper-cased.

## Value

`df` with any PSP-style columns renamed to their non-PSP equivalents.

## Details

**Plot summaries.** The non-PSP tables use `_LS` (live standing) and
`_DS` (dead standing). The PSP tables split the live pool into live /
ingrowth / veteran and publish the combined total as `_LIV`, with dead
as `_D`. `_LIV` is the counterpart of `_LS`, verified against 456
overlapping plot visits: `VHA_WSV_LIV`, `BA_HA_LIV`, `STEMS_HA_LIV`, and
`SPB_CPCT_LIV` each match their `_LS` counterpart exactly. `_L` alone is
*not* the counterpart – it excludes ingrowth and veterans and differs by
up to 578 m3 ha^-1.

**Site age.** The non-PSP table publishes plot-mean `AGET_TLSO` /
`HT_TLSO` / `SI_M_TLSO` / `AGEB_TLSO` per species. The PSP table instead
publishes per-plot values `AGE_TOT1..3`, `HTOP1..3`, `SI1..3`,
`AGE_BH1..3`. The first plot's value is taken, which reproduces the
reference extract exactly on all 430 overlapping PSP plot visits (the
across-plot mean and maximum do not: 72 and 272 matches respectively).
Note this is plot 1, not a plot mean.

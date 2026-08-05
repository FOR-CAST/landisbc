# Extract the leading species' percentage from a composition string

`SPB_CPCT_LS` packs the top five species as repeated 2-character code
plus 3-digit percentage, e.g. `"AC074BL011SW010PL005"`.

## Usage

``` r
faib_leading_species_percent(x)
```

## Arguments

- x:

  Character vector of composition strings.

## Value

Integer vector of leading-species percentages.

# an unknown target label errors rather than returning nothing

    Code
      bec_climate_analogues(clim(), "NOSUCH", vars = "MAT")
    Condition
      Error:
      ! bec_climate_analogues(): no plots carry bec_label 'NOSUCH'.

# a missing climate variable errors and names what is missing

    Code
      bec_climate_analogues(clim(), "AAmc1", vars = c("MAT", "CMD"))
    Condition
      Error:
      ! bec_climate_analogues(): `climate` is missing variable(s): CMD


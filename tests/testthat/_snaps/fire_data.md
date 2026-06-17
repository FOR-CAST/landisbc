# prep_fuel_types_rast() requires a factor FUEL_TYPE_CD

    Code
      prep_fuel_types_rast(ft, NULL, make_sa(), rtm)
    Condition
      Error in `prep_fuel_types_rast()`:
      ! is.factor(fuel_types$FUEL_TYPE_CD) is not TRUE

# load_nbac_polys() errors when year/size columns are absent

    Code
      load_nbac_polys(bad_path, sa_path, fire_years = 2000:2020)
    Condition
      Error:
      ! NBAC shapefile is missing expected year/size columns. Found: SOMETHING


# CleanUpSpeciesCodeLayer errors on a code absent from the mapping

    Code
      CleanUpSpeciesCodeLayer("ZZ", mapping = species_map_bc_vri)
    Condition
      Error:
      ! CleanUpSpeciesCodeLayer(): VRI species code 'ZZ' is not in the supplied mapping. Add it to your `mapping` argument (see `?landisbc::species_map_bc_vri` for the BC VRI template) or filter it upstream.


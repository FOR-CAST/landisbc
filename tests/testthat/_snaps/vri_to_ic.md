# a function mapping must return one code per input

    Code
      .process(species_mapping = function(codes) character(0))
    Condition
      Error:
      ! `species_mapping` must return one cleaned code per input code (got 0 for 3).

# an unmapped code errors by default and is dropped on request

    Code
      .process(n_species = 3L, species_mapping = partial)
    Condition
      Error:
      ! CleanUpSpeciesCodeLayer(): VRI species code 'BL' is not in the supplied mapping. Add it to your `mapping` argument (see `?landisbc::species_map_bc_vri` for the BC VRI template) or filter it upstream.

---

    Code
      .process(n_species = 3L, species_mapping = function(codes) partial[codes])
    Condition
      Error:
      ! VRI species code(s) not in the supplied mapping: BL. Add them to `species_mapping`, pass `unmapped = "drop"`, or filter them upstream.


# TODO

- [ ] find a way to detect uses of linearity 1 and then deallocate them
  - Add a tag to linearity 1 and then use it when pattern matching on a value 
    The pattern match will have one branch with linearity w and one branch with linearity 1, linearity 1 can do the update in-place
- [ ] add binary math to benchmarks
- [ ] watch "how to write a paper" from SPJ
- [ ] finish re-reading linear haskell


# 21

rough day

# 20

- [x] contact package manager student to add typedefs as benchmark
  - probably not until next semester
- [x] fixed computer
- [x] figure out how to deallocate on chez backend
  - Asked edwin, apparently, data is held in vectors. they should be able to be mutated in place whenever something needs to be removed or replaced.

- Meeting with edwin
  - borrowing?
  - use levitation to detect nat-like structure and vect-like buffers
  - linear API? How to do them? How to implement typeclasses/interfaces?
  - parametricity on linearity?
  - granule-like parametricity on linearity?
  - OTT Observational Type Theory -> QOTT, Quantitative Observational Type Typeory.


# 19

- [x] reading though practical levitation

# 18


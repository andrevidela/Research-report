# Final push for the thesis

Here is what's left before we release the thesis into the wild, ideally I'd like to be done with the benchmarking by the end of July and with the thesis by the
end of august so I have 1 month left for corrections.

## %mutate doesn't show any improvements

Probably because Chez is too smart

### solutions?

#### make Chez worse

Not really worth it. we already know mutation is more performance than allocation. We'll see the result we want but not really learn much from it

#### Try on the JS backend

The JS backend was just released recently and I didn't ipmlement this on JS so maybe it's worth a try

#### Go all-in with linearity and re-implement control flow analysis in the core language instead of during codegen

working on it

## write all of this down

I have a folder with all that in ulysses I need to gather all the notes and organise them in a coherent narative

## make a stricter version of Idris2

removing the subtyping rules in Idris would be very annoying but it would make the patch a lot easier to implement. Basically every linear function that uses its argument in a function
can mutate it. Mutation either happens with a constructor mutating a reference _or_ by calling a function that itself mutates the argument because its linear too

### Steps

- [ ] remove the subtyping
- [ ] make use of the mutating construct we added before

### problems

I can probably build the compiler itself with this patch but not the libraries since they make much more liberal use of linearity.
That means that benchmarking will only be synthetic benchmarks and won't be able to use the prelude or contrib. So maybe they won't
be very represeentative. However they should show a lot of improvements

# conclusion

Those two patches should be interesting enough to make the bulk of the thesis. I might sprinkle in some of my experiments with multiplicities and semirings. 
As well as future work with reference counting and control flow analysis

## Todo

- [ ] Add %mutate again
  - [x] try %mutate with JS backend (DOING)
    - [x] run the Fibonacci benchmarks
  - [x] implement --time on the compiler backend
  - [ ] gather the benchmarks results from %mutating 
    - [x] write a result generator
    - [x] run with scheme backend
      - [x] sat solver
      - [x] fib
      - [x] linTest
      - [ ] ~~Bench (see question)~~
      - [ ] ~~SAT (see question)~~
    - [ ] run with JS backend
      - [ ] sat solver
      - [ ] fib
      - [ ] linTest
      - [ ] ~~Bench (see question)~~
      - [ ] ~~SAT (see question)~~
    - [x] run benchmarks with scheme backend WHILE REMOVING STARTUP TIME
      - [x] sat solver
      - [x] fib
      - [x] linTest
      - [ ] ~~Bench (see question)~~
    - [ ] run with JS backend WHILE REMOVING STARTUP TIME
      - [ ] sat solver
      - [ ] fib
      - [ ] linTest
      - [ ] Bench (see question)
    - [ ] pretty graphs with results
      - [ ] graph of JS backend
      - [ ] graph of scheme backend
      - [ ] graph of JS without startup
      - [ ] graph of scheme without startup
  - [x] Correctly implement control flow analysis for mutation of linear arguments 
    - [x] Update every branch of the case tree to use CMut instead of CCon
    - [x] Find out at which phase of the compiler we want this to happen
  - [ ] run the benchmarks again with automatic mutation detection for linear use
- [x] write a table of contents for the thesis and start pulling all the notes together
- [ ] duplicate each case to have a linear one and dispatch linear calls to the linear case (RigCount in DataCon)
- [ ] restricted idris for linearity
  - [ ] add compiler flag
  - [ ] remove subtyping
  - [ ] make every linear function mutating
  - [ ] (OPTIONAL) have a function flag that makes everything in a body linear
  - [ ] (OPTIONAL) ^ this will require to have maybe `w` as unrestricted linearity explicitly
  

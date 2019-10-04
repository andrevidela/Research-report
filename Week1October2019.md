## 04

- [x] send email to potsdam
- [x] find the haskell examples
  - trying out https://gitlab.haskell.org/ghc/nofib
  - had some trouble with cabal and regex-compat
  - it works? not sure how to read output
- [x] writes scripts for benchmark idris-ct compile time
  - idris-ct takes forever zzzzz 
  - result:s
  ```
  idris --build idris-ct.ipkg 2> /dev/null  1040.68s user 73.42s system 56% cpu 32:38.09 total
  idris2 --build idris-ct.ipkg 2> sleep.stderr  47.78s user 6.41s system 99% cpu 54.457 total
  ```
  - nice x22 speedup on Idris-ct
- [ ] check training on monday
- [ ] answer botta about PIK and slow runtime, ask for examples




## 03

- [ ] find an adapt haskell examples
- [ ] write a script that measures compilation time
- [ ] write a script that measures run time
- [x] ask anton about access to the game again
  - Maybe once the project is better defined, might not use the name of it for the paper.
- [x] scan the amazon locker at Agnes Blackadder Haugh

#### What actually happened

Wrote emails all day for law insurance and managing matters in Switerland

## 02

- [x] resend emails to Edwin if he didn't answer
- [x] call to schedule application for national insurance number
  - meeting at 14:50 in Glasgow
  - Contact Fred to see if I should visit strathclyde as well
- [x] compile them + TParsec, Idris-CT, + all dependencies with Idris 2
  - probably won't work as is, but if any of them work, keep an eye on them for future benchmarks
  - [x] Idris2Libs
    - Had to remove `-V --allow-capital-pattern-variables`
    - stuck on `1/1: Building ..tests.Linear (./tests/Linear.idr)`
  - [x] Idris-ct Idris2 branch
    - something like 10x faster than idris 1
  - [x] TParse Idris 2 branch
    - something like 4x faster than Idris1
- [x] meeting at 2pm with Edwin
  Topics:
  - Idris2 from personal repo to Idris-dev?
    - dunno, maybe when it's self hosted?
  - Does my case study sound like an interesting challenge?
    -Yay
  - Laptop?
    - no progress
  - potsdam repo?
    - [ ] send email to potsdam for other repos for benchmarks
  - vacation days?
    - tell at least someone

### Meeting notes: next steps

- deploy infrastructure for benchmarking + see with CI
- 2 approachs: convert programs from non linear to linear or design a new implementation with linear in mind and see what happens.

### delayed

- find an adapt haskell examples

## 01


- [x] fix cs account with new password
- [x] figure out accomodation
- [x] contacted health inssurance
- [x] meeting at 2pm with statebox
- [x] compile Idris 2
  - removed network tests though
- [x] figure out national insurance number
  - no answer, will call tomorrow
- [x] figure out laptop + monitors (no US layout, maybe worth using a desktop instead?)
  - sent a message to Edwin, we'll see if uni makes an exception
- [x] fix wifi access on iPad
  - I was typing the wrong password all along ;__;
- [x] find big idris repos (potsdam repo?)
  - found IdrisLibs and Idris2libs, are there others?
- [x] compile them + TParsec, Idris-CT, + all dependencies with Idris 1
  - [x] tparsec
  - [x] idris-ct
  - [ ] IdrisLibs (compile failed)
  
##### delayed:
- compile them + TParsec, Idris-CT, + all dependencies with Idris 2


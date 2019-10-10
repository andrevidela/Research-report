## 7

- [x] Attending Pgr presentations

## 8

- [x] run examples for IdrisLib
  - had to add a bunch of `--allow-capitalized-pattern-variables` options in makefiles
  - run `make all` in `SequentialDecisionProblems/examples`
  - `./example1` with input `5` `5` already takes forever
  - Looks like the examples weren't ported to Idris 2 mhhhh
  
- [ ] write runtime programs from haskell and scala benchmarks
  - port prime sieve
  - port fibonacchi
  - port vector sum
  - string concatenation 

## 9

too sick to do anything

I guess I read "clowns to the left jokers to the right" by McBride

## 10

- [ ] test the benchmarks by Nicola
  - I guess I'll do that tomorrow in the plane
- [x] read about fibrations (https://bartoszmilewski.com/2019/10/09/fibrations-cleavages-and-lenses/)
  - I should try to implement that with Idris-ct later
- [x] watch this Microsoft research talk about lean (https://www.youtube.com/watch?v=Dp-mQ3HxgDE)
  - No mention of Agda or cubical type theory, might be interesting to compare lean with cubical agda, specialy in terms of quotients
- [x] finish implementing Fibonacci etc
  - interestingly `(n : Nat) -> Vect n Nat` does not allocate a vector of size `n` immediately
  - only in idris2, still have to implement idris2
  - should create github repo as well

# Reclaiming space

Linear types and linear logic trace back to the 1980s with girard's thesis on linear logic (ref). During that timespan
the internet was invented and spread at an incredible rate. Computer became mobile, not only they could be
transported in a luggage but they became as small as to be transported in a jeans pocket. CPU's and GPU's have
seen their performance improve by many order of magnitude. And, most relevant for this paper, Haskell, the lambda
calculus and system-F have proven to be valuable tools for driving the software that power this incredible
techonolical developement.

The same cannot be said about linear types. Though projects like Rust (ref), Cyclone (ref) and Linear haskell (ref)
implement some form of linear typing, the benefits and uses of them are still surrounded by a cloud of uncertainty.
This papers aims to disperse a bit of this cloud by uncovering the benefits of linear typing in performance-critical
operation using Idris2 (ref) and Quantitative Type Theory (ref) as a test bed.

This paper is segmented in 2 parts, an exploration of the basic idea first and an analysis the results obtained by 
executing on the idea using the Idris2 compiler. The results will not benefit from strong theoretical grounds since
we are measuring performance and those measurement suffer from a subjective choice of _what_ exactly is measured and
what consistutes a performance gain. Part 2 will essentially discuss which assumptions were made in order to interpret
the results and discuss them.

# Part 1

## the link between linearity and performance

Linear types are known to model behaviour that competing type system cannot express: 

two cables can't be plugged into 1 outet.

```
plug : (1 outlet : Outlet) -> IO ()
plug outlet = do cable1 <- makeCable Red
                 cable2 <- makeCable Blue
                 connect cable1 outlet
                 connect cable2 outlet -- type error, we've already plugged that outlet
```                 

Once the bread is baked it can't be unbaked. 

```
bake : (1 flour : Flour) -> (1 water : Water) -> IO Bread
bake flour water = do 
  bread <- mkBread flour water
  putStrLn ("For this recipe we used " ++ show flour) -- type error, we already used the flour to bake the bread
  pure bread
```

There is only 1 earth.

```
-- This should update earth in-place instead of making a copy
globalWarming : (1 earth : Earth) -> Earth
globalWarming = record { temperature $= (+ 5) 
                       , age $= (+ 50)
                       }
```       

In this paper we are going to inspect the last case.  How can we detect that a reference is unique and can therefore
be updated in-place _or_ deleted after its use. Let us start with a very traditional example

```
universe : IO ()
universe = do
  matter <- bigBang
  objects <- createObjects matter
  earth <- indexWhere (\x => name x == "earth") object
  … 
  heatDeath -- at the end of scope, earth can be freed
```

After `heatDeath`, `earth` and all other local variable should be freed. However could we do the following?

```
universe : IO ()
universe = do
  matter <- bigBang
  objects <- createObjects matter
  earth <- indexWhere (\x => name x == "earth") object
  sun <- indexWhere (\x => name x == "sun") object
  giantRed <- age (+ 10'000'000) sun
  giantRed `engulf` earth -- 1. last referece from earth, free memory
  …
  newPlanet <- MkNewPlanet objects -- 2. reuse memory from freed earth
  …
  heatDeath -- at the end of scope, earth can be freed
```

In this example we observe two behaviours:

1. freeing memory associated to a reference _before_ the end of its scope
2. reusing freed memory so that the memory footprint of the function stays constant during its runtime even 
   though objects are being allocated and freed.

## Detecting unique usage

## What do we expect to gain?



# Part 2

## A Tool for measuring runtime performance

Running benchmarks is difficult, here is the methodolgy we employed and how you can reproduce the results:

## Hand picked examples

we're picking examples that showcase the change we're making. We should also try to find examples that would showcase
a _negative_ impact on performance. Since we cannot test on every program possible we've settled on those few:


## Have we gained anything?

variance etc

# Discussion

We found a:

- significant performance improvement across the board
- some improvement in some tests and some decline in others
- some insignificant differences
- significant performance decline across the board

why?

- Because the examples were wrong?
- Because we made a mistake in our implementation?
- Because our theoretical model is incomplete or too weak?
- Because 

# Conclusion

Is it faster? yes
why?
because X

is it faster? no
why?
Because Y

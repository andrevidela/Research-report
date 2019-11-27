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
  let earth = globalWarming earth -- update earth in-place
  … 
  heatDeath -- at the end of scope, earth can be freed
```

You will note that in this example we purposely used the same identifier `earth` to indicate that we do not
create a copy.

Here is another example of what we are after:

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
  heatDeath
```

In this example we observe two behaviours:

1. freeing memory associated to a reference _before_ the end of its scope
2. reusing freed memory so that the memory footprint of the function stays constant during its runtime even 
   though objects are being allocated and freed.

An astute reader will probably have realized that both those problem are really similar, indeed one could
interpret the first one as a special case of the second:

```
universe : IO ()
universe = do
  matter <- bigBang
  objects <- createObjects matter
  earth1 <- indexWhere (\x => name x == "earth") object
  -- last use of `earth1`, reclaim its memory and use it to put `earth2` there instead
  let earth2 = globalWarming earth1 
  … 
  heatDeath
```

However the memory impact is very different. In this case, we do a `free` and `malloc` operation in succession
but simply changing some values in the middle of a memory buffer would be equivalent.

Each approach has different trade-off, in-place memory updates are a lot more efficient than `free` and `malloc`.
However being able to track freed memory and allocate new objects in previously. However in-place memory updates
are not always possible take this example

```
allocateList : Nat -> List Objects
allocateList size = let object = operation size
                        moreObjects = moreOPeration object -- last use of object, free
                        evenMore = keepOperating moreObjects -- alst use of `moreObjects`, free
                        ls = createList evenMore -- reuse the memory freed by `object` and `evenMore`
                        ls
```

In this example we have no information about the memory footprint of `object` and `moreObjects`. However, we know
that whatever space they occuped we can reuse for `ls`. (note: This example is bad because `object` and `moreObjects`
would be allocated on the stack and `ls` on the heap so they don't share the same memory region, we should fix this
example with one that doesn't have this problem)


## Detecting unique usage

Rust _CHEATS_ and everything is unique provided it's not _lent_ to a function that _borrows_ it. Identifiers cannot
be aliased and usage is tracked around with _lifetimes_ and careful control flow analysis. This puts Rust in another
_linear category_ of uniqueness type. Our type system, QTT does not say anything about uniqueness, it is then our
responsibility to carefully construct and study situations where uniqueness can be inferred and/or enforced. 

To this end we've added a new `uniqueness` tag to each definintion  which has 3 states

```
data Uniqueness = 
    ||| More analysis is required
    NotSure |
    ||| This definition is unique
    Unique |
    ||| This definition has been shared
    NotUnique
```

This is eerily similar to the semiring we use for linearity which 

    
    

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

# Further work

## Uniqueness and ARC

Reference counting and automatic reference counting are mechanisms for automatic "garbage collection" (in the sense
that is frees garbage from the heap), they rely on compile-time analysis to insert `free` or `alloc` operations as
well as `refcount += 1` or `refcount -= 1` at runtime. Those operations allow to defer memory analysis to compile-time
rather than runtime, making the runtime more predictible by avoiding reliance on "GC Pauses" where the runtime is 
stopped until the garbage collector mechanism is done sweeping the runtime memory.

ARC suffers from two big drawbacks however:

- it still adds some runtime cost (albeit constant) by inserting those increment and decrement operation
- Cyclic data structures cannot be modeled.

Nevertheless we believe we can solve the first issue with careful analysis of the control flow helped by linear
annotation. Indeed, the literature for how ARC and linearity are related is sparse and the implications are still
unconclusive.

The second drawback turn out to be extremely simple to solve: Purely functional program cannot create cyclic data
structures to begin with so the point is moot. It is true that with careful use of escape hatches it is possible
(IORef and the like) but in the general case cyclicity is not a concern.

We believe our existing implementation can be extended to support reference counting by replacing our `Uniqueness`
type by a simpler one but that carries more information:

```
RefCount : Type
RefCount = Maybe Nat

isUnique : RefCount -> Bool
isUnique (Just 1) = True
isUnique _ = False

isErased : RefCount -> Bool
isErased (Just 0) = True
isErased _ = False

increment : RefCount -> Refcount
increment (Just n) = Just (S n)
increment Nothing = Just (S Z)
```

Here RefCount is just an alias for `Maybe Nat` where the `Nothing` case represens a lack of information about the
reference count and the `Just` case represents the number of references pointing to that definition.

`isErased` is called like so because of how it interacts with `0` linearity annotations, a `0` linearity definition
will never be allocated and therefore its Refcount will always be `0`, `0` linearity annotation are interprested as
erased types at runtime.

# Conclusion

Is it faster? yes
why?
because X

is it faster? no
why?
Because Y

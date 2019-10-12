# Compiling linear types


## Memory layout

### Linarize memory representation of datatypes such as Vect n a

can we use linear types to predict memory layout at compile time in order to avoid needles memory fragmentation
and allow constant time access to objects in memory 

#### Unorganised notes:

I was reading “clowns on the left, jokers on the right” from McBride while I was deliriously feverish this week, and in this paper datatypes are builts with “algeraic containers” such that it is possible to define a tail-recurssive catamorphism/traversal of them, regardless of their structure. This property emerges by construction.

Looking at more examples of datatypes that are _not_ optimised correctly (like Vect, Fin, Elem) I noticed the following pattern

 9 -- should automatically optimize as int
10 data Fin : Nat -> Type where
11   FZ : Fin (S n)
12   FS : Fin n -> Fin (S n)
13
14 -- should automatically optimize as a buffer of n elements of `a`
15 data Vect : (n : Nat) -> Type -> Type where
16   Nil : Vect Z a
17   (::) : a -> Vect n a -> Vect (S n) a
18
19 -- should automatically erase the vector and optimise as `struct { void * a; int index; }`
20 data Elem : (a : Type) -> (vs : Vect n a) -> Type where
21   Here : Elem x (x :: xs)
22   There : Elem x xs -> Elem x (y :: xs)

they can all be represented with a `mu` container with a unit, summed with a product, something like: `type a = mu (1 + (a * rec))` (I’m going to use `rec` to refer to the recursive reference to the mu)

Our cases are a bit more complicated because McBride doesn’t have dependent pairs in this algebra. But assuming we could add dependent pairs, I conjecture that every type of the shape


`nat= mu (Z : 1 + (S :  rec))`
`Fin index = mu (FZ : (n ** rec (S n)) + (FS: rec n ** rec (S n))`
`List a = mu (Nil : 1 + (Cons : a * rec a ** rec a)`
`Vect Nat a = mu (Nil : Vect Z a) + (Cons : a * rec n a ** rec (S n) a)`

You will notice they all share the same structure:

`type index a = mu (Inital : (k : index ** rec k a) + (someValue : a * someRecursive: type k a ** rec (f k) a)`

so much so that you can rewrite all the examples as

`nat = type () ()`

`fin = type Nat ()`

`list = type () var` // var means free type variable

`vect = type Nat var`

As you can see the first two should be expected to be optimized as `int` and the later two could be optimized into linear buffers.

Here is where the madness happens:

`matrix m n a = vect m (vect n a)`

should itself be linearized into a buffer of `n * m` elements using the fact that each element of the outer vector contains a linearized buffer of `n` elements so as long as index can be “linearized” into an int and the content can be linearized into a continuous buffer the whole can be linearised into a buffer.



## runtime case study: C++ parser

### Idris 1 implementation

#### runtime

#### discussion

### Idris 2 implementation

#### runtime

#### discussion

## runtime case study IdrisLibs

### Idris 1

#### runtime

#### discussion

### Idris2

#### runtime

#### discussion

## compile time case study: Typedefs

### Idris 1

#### compile time

#### discussion

### Idris 2

#### compile time

#### discussion

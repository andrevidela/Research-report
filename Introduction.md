# Introduction 
Dear reader,
Most master thesis dive deep into their subject matter with very little to no regard to the uninitiated mind.
While this approach is justified in many cases I want to take this opportunity to experiment with a more gentle introduction to the topic, at the cost of formality and familiarity. 

Indeed I feel like this subject matter is strange enough yet, simple enough, that it can be taught in the next few pages even for an uninitiated student. 

The following will only make assumptions about basic understanding of imperative and functional programming. 

## A note about vocabulary and Jargon 

Those technical papers are often hard to approach for the unintiated because of the heavy use of unfamiliar vocabulary and domain-specific jargon. While those practices have their uses, they hinder learning quite a lot. Unfortunately I do not have a solution for this problem, but I hope this section will help you mitigate this feeling of helplessness when sentences seem to be composed of randomly generated sequences of letters rather than english words.

##### Linearity / Quantity / Multiplicity

Used interchangably most of the time. They refer the the number of type a variable is expected to be used.

##### Linear types
Linear types describe values that can be used exactly 0 times, exactly 1 time or have no restriction put on them

##### Affine types
Affine types describe values that can be used at most 0 times, at most 1 times or at most infinitely many times (aka no restrictions)

##### Monad
A mathematical structure that allows to encapsulate _change in a context_. For example `Maybe` is a Monad because it creates a context in which the values we are manipulating might be absent.

##### Co-monad / Comonad
A mathematical structure that allows to encapsulate _access to a context_. For example `List` is a Comonad because it allows us to work in a context were the value we manipulate is one out of many available to us, those other values available to us are the other values of the list.

##### Semiring
A mathematical structure that requires its values to be combined with `+` and `*` in the ways you expect from natural numbers

##### Lattice
A mathematical structure that relates values to one another in a way that doesn't allow arbitrary comparaison between two arbitrary values. Here is a pretty picture of one:

As you can see we can't really tell what's going on  between X and Y, they aren't related directly, but we can tell that they are both smaller than W and greater than Z

##### Syntax
The structure of some piece of information, usual in the form of _text_. Syntax itself does not convey any meaning.

##### Semantics
The meaning associated to a piece of data, most often related to syntax.

##### Type constructor

A value that returns a value of type : `Type`. `Int : Type` is a type constructor that return the type `Int`, `Maybe : Type -> Type` is a type constructor that return the type`Maybe Int` when provided with the type `Int`

#####  Generic type / Polymorphic type

A type that depends on a _type parameter_ like `Maybe : Type -> Type` takes  1 type as parameter.

#####  Indexed type

A type that depends on a _type parameter_ that changes with the values that inhabit the type. Like `Vect 3 String` has index `3` for vectors of `3` elements, and a type parameter `String`

##### Referential transparency

The ability of a program to always return the same values, given the same argument irrespective of its context.


# Programming recap
If you know about programming, you probably know about types and functions. Types are ways to classify values that the computer manipulates and functions are lists of instructions that describe how those values are changed. 

In _imperative programming_ functions perform memory operations like "load" and "store" or make use of complex protocols to connect to the internet. While powerful in a practical sense, those functions are really hard to study, so in order to make you life easier we only consider functions in the _mathematical_ sense of the word : a function is _something_ that takes an input and returns an output. 

In mathematical notations those functions are also defined using a _domain_ and _codomain_ (or a domain and an image) which describe which values are allowed and which values are expected to come out. 

This simplifies our model because it forbids the complexity related to complex operations like arbitrary memory modification or network access. We can recover those features by using patterns like "monad" but it is not the topic of this brief section so we will skip it. 

 Functional programming is often used to describe a programming practice centered around the use of such functions. Types are used to describe the values those functions manipulate. In additions, traditionally functional programming language have a strong emphasis on their type system which allow the types to describe the structure of the values in much more detail than simply "the amount of memory it requires to allocate"

During the rest of this thesis we are going to concern ourselves with Idris2, a purely functional programming language featuring Quantitiative type theory. 

# Idris and dependent types 

Before we jump into idris2, allow me to introduce idris, its predecessor. Idris is a programming language featuring dependent types. Dependent types allow developers to make use of a type discipline powerful enough to write both programs and theorems writhin the same language. 

Here is an example program featuring dependent types

```haskell
intOrString : (b : Bool) -> if b then Int else String
intOrString True = 404
intOrString False = "we got a string"
```

Non-dependent type system cannot represent this behavior and have to resort to patterns like "either" (or more generally alternative monads) which encapsulates all the possible meanings out program could have. Even if sometimes we _know_ there is only one of them that can occur. 


```haskell
intOrString' :: Bool -> Either Int String
intOrString' True = Left 404
intOrString' False = Right "we got a string"
```

This small example is one reason why dependent types are desirable for general purpose programming, they allow the programmer to state the behavior of the program without ambiguity and without superfluous checks that, in addition to hinder readability, can have a negative impact on the runtime performance of the program. 

# Idris and type holes

A very useful feature of Idris is _type holes_, one can replace any term by a variable name prefixed by a question mark, like this : `?hole` This tells the compiler to infer the type a this position and report it to the user in order to better understand what value could possibly fit the expected type. If we take our example of `intOrString` and replace the implementation by a hole we have

```haskell
intOrString : (b : Bool) -> if b then Int else String
intOrString b = ?hole
```

asking the Idris compiler what the hole is supposed to contain we get

```haskell
b : Bool
---------
hole : if b then Int else String
```

This information does not tell us what value we can use. However it informs us that the type of the value _depends_ on the value of `b` therefore, pattern matching on `b` might give us more insight.

```haskell
intOrString : (b : Bool) -> if b then Int else String
intOrString True = ?hole1
intOrString False = ?hole2
```

asking again what is in hole1 get us

```haskell
------------
hole1 : Int
```

and hole2 gets us

```haskell
-------------
hole2 : String
```

Which we can fill with literaly values like `123` or `"this value is of type String"`.

## A note about Either

Interestingly enough using the same strategy in `intOrString'` does not yield such precise results, indeed

```haskell
intOrString' : Bool -> Either Int String
intOrString' b = ?hole
```

Asking for `hole` gets us
```haskell
b : Bool
----------
hole : Either Int String
```

While this type might be easier to read than `if b then Int else String` it does not tell us how to proceed in order to find a more precise type to fill. Indeed, pattern matching further on `b` 

```haskell
intOrString' : Bool -> Either Int String
intOrString' True = ?hole1
intOrString' False = ?hole2
```

does not provide any additional information about the return types to use.

```haskell
-----------
hole1 : Either Int String
```

```haskell
-----------
hole2 : Either Int String
```

## A note about usage

In itself this isn't a problem how ever this lack of information manifests itself in otherways during programming, take the following program

```haskell
checkType : Int
checkType = let intValue = IntOrString True in ?hole
```

the hole give use as information

```haskell
intValue : Int
---------------
hole : Int
```

If we want to manipulate this value we can, simply because we can treat it as a regular integer
```haskell
checkType : Int
checkType = let intValue = IntOrString True 
                doubled = intValue * 2 in ?hole
```

```haskell
intValue : Int
doubled : Int
---------------
hole : Int
```

and return the modified value

```haskell
checkType : Int
checkType = let intValue = IntOrString True 
                doubled = intValue * 2 in doubled
```

without any fuss.

Constrast that with the non-dependent implementation `intOrString'`

```haskell
checkType : Int
checkType = let intValue = IntOrString' True in ?hole
```

```haskell
intValue : Either Int String
---------------
hole : Int
```

The compiler is unable to tell us if this value is an `Int` or a string. despite us _knowing_ that `IntOrString` returns an `Int` we cannot use this fact to convince the compiler to simplify the signature for us. We have to go through a runtime check to ensure that the value we are inspecting is indeed an `Int`

```haskell
let intValue = intOrString' True in
    case intValue of
        (Left i) => ?hole1
        (Right str) => ?hole2
```

This introduces the additional problem that we now need to provide a value for an impossible case (`Right`). What do we even return? we do not have an Int to double. Or alternatives are:
- Panic and crash the program
- Make up a default value, silencing the error but hiding a potential bug
- Change the return type to `Either Int String` and letting the caller deal with it.

This conclude our short introduction to dependent types and I hope you've been convinced of their usefulnesss. In the next section we are going to talk about linear types.

# Idris2 and linear types

Idris2 takes things further and introduces _linear types_ in its type system, allowing us to define how a variable will be used. In Idris2 variables are annotated with a _quantity_ , 0, 1 or W which indicate if the variable cannot be used (0), can be used exactly once (1) or is not subject to any usage restriction (w).

Take the following example

```haskell
increment : Nat -> Nat
increment n = S n
```

We see that the natural number is used exactly once on the right hand side of our definition. Therefore we can update out program with linearity annotations like so

```haskell
increment : (1 _ : Nat) -> Nat
increment n = S n
```

Additionally, idris2 feature pattern matching and the rules of linearity also apply to each variable that is bond when matching on it. That is, if the value we are matching is linear then we need to use the pattern variables linearly. 

```haskell
sum : (1 _ : Nat) -> (1 _ : Nat) -> Nat
sum Z n = n
sum (S n) m = S (sum n m)
```

Obviously this programming discipline does not allow us to express every program the same way as before. Here are two typical examples that cannot be expressed 

```haskell
drop : (1 v : a) -> ()

copy : (1 v : a) -> (a, a)
```

We can explore what is wrong with those functions by trying to implement them and making use of _holes_.

```haskell
drop : (1 v : a) -> ()
drop v = ?hole
```

```haskell
0 a : Type
1 v : a
------------
hole : ()
```

As you can see we need to use `v` but we are only allowed to return `()`.

trying i out anyways result in this code and this corresponding error

```haskell
drop : (1 v : a) -> ()
drop v = ()
```

```haskell
There are 0 uses of linear variable v
```

Similarly for `copy` we have

```haskell
copy : (1 v : a) -> (a, a)
copy v = ?hole
```

```haskell
0 a : Type
1 v : a
-----------
hole : (a, a)
```

In which we need to use `v` twice but we're only allow to use it once. Using it twice result in this program with this error

```haskell
copy : (1 v : a) -> (a, a)
copy v = (v, v)
```

```haskell
There are 2 uses of linear variable v
```

Interestingly enough, partially implementing our program with a hole give use an amazing insight

```haskell
copy : (1 v : a) -> (a, a)
copy v = (v, ?hole)
```

```haskell
0 a : Type
0 v : a
-----------
hole : a
```

The hole has been updated to reflect the fact that though `v` is in scope, no uses of it are available, despite that we still need to make up a value of type `a` out of thin air, which is impossible.

While there are experimental ideas that allow us to recover those capabilities they are not currently present in Idris2. We will talk about those limitations and how to overcome them our "limitations and future work" section. 

In the following snipped you will notice that we use an implicit argument that hold the type of a list

```haskell
length : {a : Type} -> List a -> Nat
```

If an argument is superfluous it can be annotated with 0 indicating that it will not and cannot appear in the body of our function. While this might be strange at first glance it makes a lot of sense in a dependently typed setting.

```haskell
length : {0 a : Type} -> List a -> Nat
```

 Indeed, variables with linearity 0 Do not appear in the execution of the program but are allowed to be used during the compilation of the program and therefore are allowed unrestricted use as along as its constrained within a type signature or a rewrite .

This does not only apply type values of type "types" but to every value, for example here the same example with vector showcases an erased Nat

*vsctor length*

Exercises

Drop and copy cannot be written for arbitrary types _but_ if you know how to construct your type you can _work really hard_ to implement them. Here is an example with Nat

*dropNat*
*cooyNat*

It is worthy to notice that while dropNat effectively spends O(n) doing nothing, copy _simulates_ allocation by construction a new value that is entirely identical and takes the same space as the original one (albeit very inefficiently, one would expect a memcpy to be O(1) in the size of the input, not O(ℕ))

Here is an interface for this behavior
Drop
Copy

Can you implement this interface for List, Vector, and Binary Trees?
What about String and Int? What's wrong with them?


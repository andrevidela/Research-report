# Uses for linear types

Linear types haven’t really found a place in mainstream commercial application of software engineering. For this reason, while this section does not provide any concrete contributions, I thought it was warranted to list some new, innovative and unexpected uses for linear types.

## Session types

## Permutations

During my time on this Master program I was also working for a commercial company using Idris for their business: Statebox.

One of their project is a validator for petri-nets and petri-net executions: [FSM-oracle](https://github.com/statebox/fsm-oracle). While the technical details of this projects are outside the scope of this text, there is one aspect of it that is fundamentally linked with linear types, and that is the concept of permutation.

FSM-Oracle describes petri-nets using [_hypergraphs_](http://www.zanasi.com/fabio/files/paperCALCO19b.pdf) those hypergraphs have a concept of [_permutation_ ](https://github.com/statebox/fsm-oracle/blob/master/src/Permutations/Permutations.idr#L31) that allows to move wires around. This concept is key in a correct and proven implementation of hypergraphs. However, they also turn out to be extremely complex to implement as can attest the files [trying to fit](https://github.com/statebox/fsm-oracle/blob/master/src/Permutations/PermutationsCategory.idr) their definition into a [Category](https://github.com/statebox/fsm-oracle/blob/master/src/Permutations/PermutationsStrictMonoidalCategory.idr).

Linear types can thankfully ease the pain by providing a very simple representation of permutations:

```haskell
Permutation : Type -> Type
Premutation a = (1 ls : List a) -> List a
```

That is, a `Permutation` parameterised over a type `a` is a linear function from `List a` to `List a`. 

This definition works because no elements from the input list can be omited or reused for the output list. _Every single element_ from the argument has to find a new spot in the output list.

If we update this definition to use Vectors instead of lists we get

```haskell
Permutation : Nat -> Type -> Type
Permutation n a = (1 ls : Vect n a) -> Vect n a
```

Which allows us to recover definitions like `swap`

```haskell
swap : (1 n : Nat) -> Permutation (n + m) a
swap n xs = let (b, e) = splitAt' n xs in
        rewrite plusCommutative n m in e ++ b
```

And the categorical semantics are simply the ones from Idris types and functions.

## Compile-time string concatenation

Strings are ubiquitous in programming. That is why a lot of programming languages have spent a considerable effort in optimising string usage and string API ergonomics. Most famously Perl is notoriou for is extensive and powerful string manipulation API including the much dreaded and beloved first-class regex support (with more recent additions including built-in support for grammars).

One very popular feature to ease the ergonomics of string literals is _string interpolation_. String interpolation allows you to avoid this situation

```haskell
show (MyData arg1 arg2 arg3 arg4) = "MyData (" ++ show arg1 ++ " " ++ show arg2 ++ " " ++ show arg3 ++ ++ show arg4 ++ ")"
```

by allowing string literal to include expressions _inline_ and leave the compiler to build the expected string concatenation. One example of string interpolation syntax would look like this 

```haskell
show (MyData arg1 arg2 arg3 arg4) = "MyData ({arg1} {arg2} {arg3} {arg4})"
```

The benefits are numerous but I won’t dwell on them here. One of them however is quite unexpected: Predict compile-time concatenation with linear types.

As mentioned before, one intuition to understand the _erased linearity_ `0` is to consider those terms absent at runtime but available at compile-time. In the case of string interpolation, this intuition becomes useful in informing the programmer of the intention of the compiler while using the feature. Indeed, in the following program we declare a variable and use it inside a string interpolation statement.

```haskell
let name = "Susan"
    greeting = "hello {name}" in
    putStrLn greeting
```

However, it would be reasonable to expect the compiler to notice that the variable is also a string literals and that, because it is only used in a string interpolation statement, it can be concatenated at compile time. Effectively being equivalent to the following:

```haskell
let greeting = "hello Susan" in 
    putStrLn greeting
```

But those kind of translations can lead to very misleading beliefs about String interpolation and its performance implications. In this following example the compiler would _not_ be able to perform the concatenation at compile time:

```haskell
do name <- readLine
   putStrLn "hello {name}"
```

Because the string comes from the _runtime_.

## Runtime you say? Wait a minute

Yes, we've already established this intuition that _erased_ linearity is absent at runtime but allowed unrestricted use at compile-time. This intuition stays true here and allows us to explore the possibility of allowing the following program to compile

```haskell
let 0 name = "Susan" 
    1 greeting = "hello {name}" in
    putStrLn greeting
```

Since the variable `name` has linearity `0`, it cannot appear at runtime, which means it cannot be concatenated with the string `"hello "`, which means the only way this program compiles is if the string `"Susan"` is inlined with the string `"hello "`at compile-time.

Using holes we can describe exactly what would happen in different circumstances. As a rule, string interpolation would do its best to avoid allocating memory and performing operations at runtime. Much like our previous optimisation, it would look for values which are constructed in scope and simply inline the string without counting it as a use.

```haskell
let 1 name = "Susan"
    1 greeting = "hello {name}" in
    putStrLn greeting
```

Would result in the compile error

```haskell
There are 0 uses of linear variable name
```


Adding a hole at the end would show.

```haskell
let 1 name = "Susan"
    1 greeting = "hello {name}" in
    ?interpolation
```

```haskell
1 name : String
1 greeting : String
---------------------------
interpolation : String
```

As you can see, the variable `name` has not been consumed by the string interpolation since this transformation happens at compile time.

Having the string come from a function call however means we do not know if it has been shared before or not, which means we cannot guarantee (unless we restrict our programming language) that the string was not shared before, therefore the string cannot be replaced at compile time. 

```haskell
greet : (1 n : String) -> String
greet name = let 1 greeting = "hello {name}" in ?consumed
```

```haskell
0 name : String
1 greeting : String
----------------------------
consumed : String
```

The string `name` has been consumed and the core will therefore perform a runtime concatenation.

## Invertible functions

Yet another use of linearity appears when trying to define invertible functions, that is function that have a counterpart that can undo their actions. Such functions are extremely common in practice but aren't usually described in terms of their ability to be undone. Here are a couple example

- Addition and substraction
- `::` and `tail`
- serialisation/deserialisation

The paper about [sparcl](https://icfp20.sigplan.org/details/icfp-2020-papers/28/Sparcl-A-Language-for-Partially-Invertible-Computation) goes into details about how to implement a language that features invertible functions, they introduce a new (postscript) type constructor `• : Type -> Type` that indicate that the type in argument is invertible. Invertible functions are declared as linear functions `A• -o B•`. Invertible functions can be called to make progress one way or the other given some data using the `fwd` and `bwd` primitives:

```haskell
fwd : (A• -> B•) -> A -> B
bwd : (A• -> B•) -> B -> A
```

Invertible functions aren't necessarily total, For example `bwd (+ 1) Z` will result in a runtime error. This is because of the nature of invertible functions: the `+ 1` functions effectively adds a `S` layer to the given data. In order to undo this operation we need to _peel off_ a `S` from the data. But `Z` doesn't have a `S` constructor surrounding it, resulting in an error.

Those type of runtime errors can be avoided in Idris by adding a new implicit predicate that ensure the data is of the correct format:

```haskell
bwd : (f : (1 _ : A•) -> B•) -> (v : B) -> {prf : v = fwd f x)} -> A
```

This ensures that we only take values of `B` that come from a `fwd` operation, that is, it only accepts data that has been correctly build instead of abitrary data. If we were to translate this into our nat example it would look like this

```haskell
undo+1 : (n : Nat) -> {prf : n = S k} -> Nat
```

which ensures that the argument is a `S` of `k` for any `k`.

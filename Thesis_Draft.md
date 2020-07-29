# Table of content:  Performance improvement using linear types

- Introduction
	- Vocabulary etc
	- Programming recap
	- Idris and dependent types
	- Idris and type holes
		- Either revisited
		- Type hole usage
	- idris2 and linear types
	- Exercises
- literature review
	- (introduction to) linear types (LL, BLL, QTT)
	- use of (affine and) linear types (session types, rust, cyclone)
	- performance using linear types (Deforstation, Reference counting, free after use)
	- Graded monad and modal types (Granule, QTT semirings, co-effects)

- What's the big idea?
	- Why mutation
	- Why QTT and idris2
	- Why it would work?

- The implementation ?
	- % mutate
	- automatically mutate linear use
	- automatically dispatch linear calls

- benchmarks
	- synthetic benchmarks (fib, update, megaupdate)
	- compiler benchmarks (run the optimised version of the compiler on things and compare with unoptimised)
	- real projects (SAT, Game of life, Statebox)

- Results
	- synthetic results
		- No improvements because Chez is too smart (to verify)
		- check with JS
	- compiler results
		- No improvements because the compiler does not make heavy use of linearity
	- real projects

- Conclusion
	- Promising but currently limited
		- limited by linearity use
		- limited by runtime
	- solutions
		- Make more use of linearity (by making linear things the default -\> have a restricted version of Idris
			- linearity is now super annoying so we need graded modal types
		- Make use of linearity in the runtime directly (make a reference counted runtime)


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


# Literature review

During this literature review I will enumerate the relevant papers that hint or establish new results using linear types, mostly through the lens of performance. As we will see, most of it does not focus on performance, but rather on semantics. While those aren't our focus, they will still inform of of what is _expected_ from a modern linearly typed programming language. The goal of Idris2 is to be such a language, modern, linearly and dependently typed aimed at commercial software rather than tu be a purely academic curiosity.

## Linear logic, Girard 1987

This is the foundational paper about linear logic, interestingly enough it already highlights the limits of linear logic:
- The complexity of having to handle linear and unrestricted variables separately
- The lack of expressiveness of a purely linear calculus
- How bounds and Bounded linear logic could address those

Specifically, the mention of resource management for computer software was interesting but not very insightful. Indeed, Girard mentions how exponentials could approximate storage but nothing is said about how this would manifests in practice. Justifiably since there were no linear languages back then.

## Bounded Linear Logic, Girard 1991

Bounded linear logic improves the expressivity of linear logic while keeping its benefits: intuitionnistic-compatible logic that is computationally relevant. The key difference with linear logic is that weakening rules are _bounded_ by a finite value such that each value can be used as many time as the bound allows. In addition, some typing rules might allow it to _waste_ resources by_underusing_ the variable, hinting that affine types might bring some concrete benefits to our programming model.

As before, there is no practical application of this in terms of programming language, at least not that I could find. However this brings up the first step toward a managing _quantities_ and complexity in the language. An idea that will be explored again later with Granule and Quantitative Type Theory.

NOTE: (I should re-read this one to find more about the expected uses at the time)

## Deforestation Wadler 1988

Deforestation is a small algorithm proposed to avoid extranious allocation when performing list operations in a programming language close to System-F. This algorithm did not end up being used in practice in GHC (it was replaced by fold/unfold, TODO: find the reference) but it showed promise in the sense that it was relying on the linearity of operations. This assumption that operations on lists must be linear was made to avoid performing an effect twice which would end up in an ill-defined tree-less program. This is notable because it is the first instance of a use for linearity in the context of performance.

While deforestation itself might not be the algorithm that we want to implement today, it is likely we can come up with a similar, or even better, set of optimisation rules in idris2.

## Is there a use for linear types & Linear types can change the world, Wadler 1991

I will lump those two papers together because they serve and show the same thing with regards to linear types. Linear types can be used for in-place update and mutation instead of relying on copying. And they both provide programming API that make use of linear defintions and linear data in order to showcase where and how the code differ in both performance and API.
  
However the weakness of both those results is that the API exposed to the programmer relies on a continuation, which is largely seen as unacceptable user experience (ask your local javascript developer what they think of "callback hell"). However, we can probably reuse the ideas proposed there and rephrase them in the context of Idris2 in order to provide a more user-friendly API for this feature, maybe even make it transparent for the user.

## Reference counting as a computational interpretation of linear logic, 1995
  
It turns out that linear types can also be used to replace entirely the memory management system, this paper shows that a simple calculus augmented with memory management primitives can make use of linearity in order to control memory allocation and deallocation using linear types.

This breakthrough is not without compromises either. The calculus is greatly simplified for modern standards and the amount of manual labour required from the developper to explicitly share a value is jarring in this day and age. What's more, it is not clear how to merge this approach with modern implementation of linearity (such a Quantitative Type Theory). While this paper seems quite far removed from our end goal of a transparent but powerful memory optimisation it suggest some interesting relation between data/codata and resource management (linear infinite streams?).

## Practical affine types
  
What does it mean to have access to linear and affine types _in practice_? Indeed, most the results we've talked about develop a theory for linear types using a variant of linear logic, and then present a toy language to showcase their contribution. However this does not teach us how they would interact and manifest in existing programs or in existing software engineering workflows. Do we see emerging new programming patterns? Is the user experience improved or diminished? In what regards is the code different to read and write? All those questions can only be answered by a fully fledged implementation of a progrmming language equiped to interact with existing systems.

Practical affine types show that their implementation for linear+affine types allow to express common operations in concurent programs without any risk of data races. They note that typical stateful protocols should also be implementatble since their language is a strict superset of other which already provided protocol implementations. Those two results hint at us that linear types in a commercially-relevant programming language would provide us with additional guarantees without impeding on the existing writing or reading experience of programs. A result that we well certainly attempt to reproduce in Idris2.

## Linear Haskell 2017

Haskell already benefits from a plethora of big and small extensions, they are so prevalent that they became a meme in the community: every file must begin with a page of language extension declarations. Linear Haskell is notable in that it extends the type system to allow linear functions to be defined. It introduces the linear arrow `-o` which declares a function to be linear. Since Haskell is lazy that means "if called exactly once, then its argument is consumed exactly once".

This drastic change in the language was motivated by a concern for safe APIs, typically when dealing with unsafe or low-level code. Linear types allow to expose an API that cannot be misused while keeping the same level of expressivity and being completely backwards compatible. In addition, Linear Haskell features linear parametricity, the ability to abstract over linearity annotation. This last feature is was allows all existing APIs to be backwards compatible with linearity annotations. Idris2 does not allow to abstract over multiplicities, in that regard it would be interesting to see if we can still achieve a backward compatible API in idris that is both compatible with linear and traditional programs.

## Granule, Orchard et al. 2018

 Granule is a language that features _quantitative reasoning via graded modal types_. They even have indexed types to boot! This effort is the result of years of research in the domain of effect, co-effect, resource-aware calculus and co-monadic computation. Granule itself makes heavy use of _graded monads_ (Katsuma, Orchard et al. 2016) which allow to precisely annotate co-effects in the type system. This enables the program to model _resource management_ at the type-level. What's more, graded monads provide an algebraic structure to _combine and compose_ those co-effects. This way, linearity can not only be modelled but also _mixed-in_ with other interpretations of resources. While this multiplies the opportunities in resource tracking, this approach hasn't received the treatment it deserves with regards to performance and tracking runtime complexity.

## Quantitative type theory, Atkey 2016

Up until now we have not addressed the main requirement of our programming language: We intend to use _both_ dependent types _and_ linear types within the same language. However, such a theory was left unexplored until_I got plentty o nuttin_ from McBride and its descendant, _Quantitative type theory_, came to fill the gap. While other proposal talked about the subject, they mostly implement _indexed_ types instead of _fully dependent_ types. In order to allow full dependent types, two changes were made:
- Dependent typing can only use _erased_ variables
- Multiplicities are tracked on the _binder_ rather than being a feature of each value or of the function arrow (our beloved lollipop arrow `-o`)
While this elegantly merges the capabilities of a Martin-Löf-style type theory  (intuitionistic type theory, Per Martin-Löf, 1984) and Linear Logic, the proposed result does not touch upon potential performance improvement that such a language could feature. However it has the potential to bring together Linear types and dependent types in a way that allows precise resource tracking and strong performance guarantees.

## Counting immutable beans

As we've seen, linearity has strong ties with resource and memory management, including reference counting. Though _Counting immutable beans_ does not concern itself with linearity per se, it mentions the benefits of _reference counting_ as a memory management strategy for purely functional programs. Indeed, while reference counting has, for a long time, been disregarded in favor of runtime garbage collectors, it now has proven to be commercially viable in languages like Swift or Python. The specific results presented here are focused on the performance benefits in avoiding unnecessary copies and reducing the amount of increment and decrement operation when manipulating the reference count at runtime. It turns out the concept of "borrowing" a value without changing it reference count closely matches a linear type system with graded modalities. Indeed as long as the modality is finite and greater than 1 there is no need to decrement the reference count. Here is an illustration of this idea

```Idris
f : (2 v : Int) -> Int
f v = let 1 val1 = operation v -- operation borrow v, no need for dec
          1 val2 = operation v -- we ran out of ses for v, dec here
       in val1 + val2
```

In our example, since `v`could be shared prior to the calling of `f` we cannot prove that v can be freed, we can only decrement its reference count. However, by inspecting the reference count we could in addition reuse our assumption about "mutating unique linear variables" and either reclaim the space or reuse it in-place.


---- 
# Linear uses

As we've seen linear types have lots of promise regarding uses in modern programming practices. They allow to model common patterns that are notorious for being error-prone and the source of important security flaws. Indeed a protocol might have been proven safe but it's implementation might not be. Linear types allow stateful protocols to make use of an additional layer of guarantee. 

However those efforts have not been very successful in penetrating the mainstream of programming languages. While we will not discuss the reasons _why_ we will note that linear types can actually _help_ overcoming a common criticism of purely functional programming: That they are slow and do not/cannot provide any performance guarantee. Indeed, as we've seen in the review, linear types show a lot of promise regarding performance but have not realised that promise in practice. The hope is that Idris2 will provide the necessary infrastructure to demonstrate those ideas and finally legitimize linear types as a valid typing discipline for commercial software.
---- 

Indeed, Idris2 features both linear and dependent types, providing programmers with the tools to write elegant and correct software (Type Driven Development, Brady 2017), while ensuring performance. In this thesis I am going to reuse the intuition originally suggested by Wadler 1991 and rephrase it as 

> If you own a linear variable and it is not shared, you can feely mutate it

This somewhat mimics Rust's (Nicholas D Matsakis and Felix S Klock II. 2014) model of ownership where variables are free to be mutated as long as they are uniquely owned. But differs in that it does not make use of _uniqueness_ but rather uses linearity as a proxy for it. 

This idea can be illustrated with the following example:

```Idris
let 1 v : Int = 3
    1 v' : Int = v + 17
 in print v'
```

The bound variable `v` was created locally and is _linear_ advertising a use of `1`. Then, the function `+ 17` makes use of it and puts the result in a variable `v'`. This new variable does not need to allocate more memory and can simply reuse the one allocated for `v`, effectively mutating the memory space occupied by `v'` without losing the immutable semantics we expect.

As one can see this does away with the continuation while reaping the benefits of in-place mutation awarded by our linear property. In addition, this innocuous could be expanded to more complex examples like

```Idris
let 1 array = …
    1 array' = map f array
    1 array'' = map g array'
 in sum array''
```

Which could be executed in _constant space complexity_ effectively duplicating the results from deforestation, but in a more general setting since this approach does not make any assumption about the type of the data handled, only that operations are linear and mutations are constant in space.

# The difference between academic curiosity and comercial relevance

Commercial software needs to be:

- fast to compile
- fast to run
- easy to maintain
- easy to pick up
- easy to debug
- fit with existing workflows

Academic software usually fails in those regards:
- no concern for performance, neither compile or runtime
- no concern for learning curve
- no concern for runtime debugging tools
- no concern for industry-standard workflows
- no concern for business use-cases

Idris1 fails in those regards:
- slow to compile
- slow to run
- hard to debug sometimes
- slow to develop for when working with complex features

idris1 succeeded in those regards:
- easy to make running binaries
- easy to distribute with standard practices (containers)
- _easier_ learning curve by adopting expected defaults (non-total by default, familiar APIs) compared to competing software (Agda, Coq, Lean). Though it could be greatly improved, the fact that the skilll ceiling is extremly high explains why getting a smooth learning curve is difficult.

Idris2 aims to fix those aspects:
- fast to compile
- fast to run
- better error messages
- improve the business use-cases by introducing linear session-types etc.

It will probably fail in those regards
- runtime debugging tools

# Extending Idris2 with graded modal types and how to use them for efficient binaries

Software engineering and programming langauge have very different concerns despire using _basically_ the same tools. Research in programming languages is done with toy languages, theorem provers and pen and paper mathematical proofs (sometimes diagramatic ones). Software engineering is concerned with maintainability, expressivity and runtime speed. Though those two classes of concerns aren't necessarily mutually exclusive, they do rarely intersect. This paper however turns out to merge the two in a way that is only seldom witnessed in the academic community.

Idris2 is a programming language making use of Quantiative type theory, a type theory allowing to use both dependent types and linear-like semantics (quantitites) in the same language. The theory is based on those basic ideas:
- Quantities are a property of _binder_ rather than types of terms
- Quantities are defined in terms of a pre-oredered semi-ring rather than special types for "linear" and "unrestricted"
- Arbitrary type-level comutation is possible by restricting it to values with multuplicity 0

Most notably this theory lacks two things:
- Multiplicity polymorphism
- Multiplicity dependency
We will not concern ourselves with those limitations for now but they will come up as very obvious extension in our _future work_ section.

# introduction to linearity

Linear types have many uses that range between sesssion types (add ref), reference tracking (add ref to rust), API safety (ref to linear haskell), etc. In a nutshell, linear types describe values that can only be _used_ exactly once. If they are used less that once or more that once this will result in a type error. Here is a simple example

```haskell
-- identity is linear
id : (1 _ : a) -> a
id a = a
```

here we prove that linearity is 

# The performance hypothesis

Using mutation in an isolated case did not result in any performance improvement, even with pathological code that would typically showcase the Benedict of such benchmarks, no improvements were found. 

My best hypothesis is that the Chez optimiser is smart enough to detect those cases and perform the optimisation were looking for before using having to do it.

While the chez backend is not intended to be the only backend for Idris 2 out goal isn't to make the runtime worse in order to show any improvement.

The next step is then to perform the optimisation automatically rather than manually on a large scale program such as the Idris 2 compiler itself. 

# Performing the optimization automatically 

We want to optimise this case

```haskell
let 1 v = a :: b in
    update v
```

The key observation is that a value `v` is constructed and bounded linearly _and_ its only use is performed in-scope. 

Because we _know_ it won't be used later, we can mutate this value instead of creating a new copie within the body of `update` and return the mutated reference instead of returning a newly allocated value. 

However `update` might also be used in situations where it's argument isn't unique, for example update can be defined non-linearly

```haskell
update : (1 _ : List Nat) -> List Nat
update [] = []
update (x :: xs) = S x :: xs
```

But by virtue of subtyping can still be called with non-linear arguments. Since a shared value can _also_ be used exactly once, no invariant is broken. However, this breaks our performance fix since we cannot simply mutation whenever we deal with a linear function. We have to be sure that linearity implies uniqueness. 

This is why we need our ad-how scoping rule. It ensures the variable isn't shared before calling a linear function. 

# New idea

When matching on a data constructor. And it's linear and the argument is linear. And the value passed is linear (how do I do this???)

# Implementation and results

In order to gauge how effective in-place mutation would be for linear function I decided to start by adding a keyword that would tell the compiler to perform mutation for variable that are matched, irrespective of their linearity properties.

While this results in unsafe programs (since arbitrary mutation breaks referential transparency) , when used carefully in our benchmarks it will allow use to test how promising linearity improvements might be.

## Implementation strategy

The goal is to be able to write this program
```haskell
%mutating
update : Ty -> Ty
update (ValOnce v) = ValOnce (S v)
update (ValTwice v w) = ValTwice (S v) (S (S w))
```

where the `%mutating` annotation indicates that the value manipulated will be subject to mutation rather than construction.

If we were to write this code in a low-level c-like syntax we would like to go from the non-mutating version here

```haskell
void * update(v * void) {
    Ty* newv;
    if v->tag == 0 {
        newv = malloc(sizeof(ValOnce));
        newv->tag = 0;
        newv->val1 = 1 + v->val1;
    } else {
        newv = malloc(sizeof(ValTwice));
        newv->tag = 1;
        newv->val1 = 1 + v->val1;
        newv->val2 = 1 + 1 + v->val2;
    }
    return newv;
}
```

to the more efficient mutating version here
```haskell
void * update(v * void) {
    if v->tag == 0 {
        v->val1 = 1 + v->val1;
    } else {
        v->val1 = 1 + v->val1;
        v->val2 = 1 + 1 + v->val2;
    }
    return nv;
}
```

The two programs are very similar but the second one mutate the argument directly instead of mutating a new copy of it.

There is however a very important limitation:

### We only mutate uses of the constructor we are matching on

The following program would see no mutation

```haskell
%mutating
update : Ty -> Ty
update (ValTwice v) = ValOnce (S v)
update (ValOnce v) = ValTwice (S (S v))
```

Since the constructor we are matching on the left side of the clause does not appear on the right.

This is to avoid implicit allocation when we mutate a constructor which has more fields than the one we are given. Imagine representing data as a records:

```haskell
ValOnce = { tag : Int , val1 : Int }
ValTwice = { tag : Int , val1 : Int val2 : Int }
```

if we are given a value `ValOnce` and asked to mutate it into a value `ValTwice` we would have to allocate more space to accomodate for the extra `val2` field.
  
Similarly if we are given a `ValTwice` and are asked to mutate it into a value `ValOnce` we would have to carry over extra memory space that will remain unused.

Ideally our compiler would be able to identify data declaration that share the same layout and replace allocation for them by mutation, but for the purpose of this thesis we will ignore this optimisation and carefully design our benchmarks to make use of it. Which brings us to the next section

## Implementation details

For this to work we need to add a new constructor to the AST that represents _compiled_ programs `CExp`. We add the consturctor 

```haskell
CMut : (ref : Name) -> (args : List (CExp vars)) -> CExp vars 
```

which represents mutation of a variable identified by its `Name` in context and using the argument list to modify each of its fields.

(This new constructor has to be carried of to tress `NamedExp` `ANF` and `Lifted`, the details are irrelevants and the changes trivial)

Once this change reached the code generator it needs to output a `mutation` instructon rather than an allocation operation. Here is the code for the scheme backend

*show scheme backend implementation for CMut*

AS you can see we generate one instruction per field to mutate as well ad a final instruction to _return_ the value passed in argument, this to keep the semantics of the existing assumption about constructing new values.

## Reference nightmare

There is however an additional details that isn't as easy to implement and this is related to getting a reference to the term we are mutating. 

Let's look at our `update` function once again and update it slightly 


```haskell
%mutating
update : (1 _ : Ty) -> Ty
update arg = case arg of
                  ValTwice v => ValTwice (S (S v))
                  ValOnce v => ValOnce (S v)
```

This version makes use of there temporary variable `arg` before matching on the function argument directly. Otherwise it's the same as what we showed before.

What needs to happen is that `ValTwice` on the first clause needs to access the variable `arg` and mutate it directly. And similarly for `ValOnce`.

```haskell
case arg of
     ValTwice v => -- access `arg` and mutate it with S (S v)
                   ValTwice (S (S v))
     ValOnce v => -- access `arg` and mutate it with S v
                  ValOnce (S v)
```

However looking at the AST for pattern match clauses we see that it does not carry any information about the original value that was matched:

```haskell
ConCase : Name -> (tag : Int) -> (args : List Name) ->
                 CaseTree (args ++ vars) -> CaseAlt vars
```
# Glossary and definitions

While the initial list of fancy words in the introduction is nice it suffers from being superficial and therefore incomplete. These are more details definitions using examples and imagery

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
The structure of some piece of information, usual in the form of _text_. Syntax itself does not convey any meaning. Imagine this piece of data

*picture of a circle*

We can define a syntactic rules that allow us to express this circle, here is one: all shapes that you can draw without lifting your pen or making angles. From this definition lots of values are allowed, including |, -,  O but not + for example because there is a 90º angle between two bars.
Is it supposed to be the letter "O", the number "0" the silouhette of a planet? the back of the head of a stick figure?

##### Semantics
The meaning associated to a piece of data, most often related to syntax. From the _syntax_ definition if we have

*picture of 10*

we can deduce that the circle means "the second digit of the number 10" which is the number "0". We were able to infer semantics from context. Similarly

*picture of :)*

we can deduce that the meaning of the circle was to represent the head of a stick figure, this time from the front.

# Reference counting an linearity

if something has bounded linearity \> 1 then it can be borrowed everywhere and does not need any deference counting inc or dec

only once it reached 0 is needs a dec

since linear variables can be shared there might be multiple decs and incs but most intermediate ones can be eliminated

for example

```haskell
f : 2 a -> b

let 4 v : a = … -- inc 1
    f v -- borrowed
    id v -- borrwed
 in v -- no dec, we share it
```

or
```haskell
f : 3 a -> b
f a = do g a -- borrowed
         g a -- borrowed
         g a -- borrowed?

let 4 v : a = … --inc
    f v -- borrowed
 in v
```

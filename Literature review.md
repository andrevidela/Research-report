# Literature review

I will shortly enumerate the literature that I found relevant to linear logic and its relation to program performance. Each summary exposes parts of an incomplete story written by multiple authors during different times. Hopefully this thesis will kick off the next chapter of this tale.

## Linear logic, Girard 1987

This is the foundational paper about linear logic, interestingly enough it already highlights the limits of linear logic:
- The complexity of having to handle linear and unrestricted variables separately
- The lack of expressiveness of a purely linear calculus
- How bounds and Bounded linear logic could address those

Specifically, the mention of resource management for computer software was interesting but not very insightful. Indeed Girard mentions how exponentials could approximate storage but nothing is said about how this would manifests in practice. Justifiably since there were no Linear languages back then.

## Bounded Linear Logic, Girard 1991

Or Linear logic, the sequel.

Bounded linear logic improves the expressivity of linear logic while keeping its benefits: intuitionnistic-compatible logic that is computationally relevat. The key difference with linear logic is that weakening rules are _bounded_ by a finite value such that each value cannot be used more times than its bound allows. In addition, some typing rules might allow it to _waste_ resources by_underusing_ the variable.

As before there is no practical application of this in terms of programming language, at least not that I could find. However this brings up the first step toward a managing _quantities_ and complexity in the language. An idea that will be explored again later with Granule and Quantitative Type Theory.

## Deforestation Wadler 1988

Deforestation is a small algorithm proposed to avoid extranious allocation when performing list operations in a programming language close to System-F. This algorithm did not end up being used in practice in GHC (it was replaced by fold/unfold) but it showed promise in the sense that it was relying on the linearity of operations for the transformation to work. This assumption that operations on lists must be linear was made to avoid performing an effect twice which would end up in an ill-defined tree-less program. This is notable because it is the first instance of a use for linearity in the context of performance.

While deforestation itself might not be the algorithm that we want to implement today. I is likely we can come up with a similar, or even better, set of optimising rules in idris2.

## Is there a use for linear types & Linear types can change the world, Wadler 1991

I will lump those two papers together because they serve and show the same thing with regards to linear types. Linear types can be used for in-place update and mutation instead of relying on copying. And they both provide programming API that make use of linear defintions and linear data in order to showcase where and how the code differ in both performance and API.
  
However the weakness of both those results is that the API exposed to the programmer relies on a continuation, which is largely seen as unappealing (just ask you local javascript developer what they think of "callback hell"). We can certainly reuse the ideas proposed there and rephrase them in the context of Idris2 in order to provide a more user-friendly API for this feature, maybe even make it transparent for the user.

## Granule, Orchard et al. 2018

We skip a few year and look at what seem to be the _endgame_ for a linearly typed language. Granule is a language that features _quantitative reasoning via graded modal types_. They even have indexed types to boot! This effort is the result of years of research in the domain of effect, co-effect, resource-aware calculus and co-monadic computation. Granule itself makes heavy use of _graded monads_ (Katsuma, Orchard et al. 2016) which allow to precisely annotate co-effects in the type system. This enables the program to model _resource management_ at the type-level. What's more, graded monads provide an algebraic structure to _combine and compose_ those co-effects. This way, linearity can not only be modelled but also _mixed-in_ with other interpretations of resources. While this multiplies the opportunities in resource tracking, this approach hasn't received the treatment it deserves with regards to performance and tracking runtime complexity.

## Quantitative type theory, Atkey 2016

Up until now we have not addressed the main requirement of our programming language: We intend to use _both_ dependent types _and_ linear types within the same language. However, such a theory was left unexplored until_I got plentty o nuttin_ from McBride and its descendant, _Quantitative type theory_, came to fill the gap (Granule wasn't even out at the time and only has _indexed_ types instead of _fully dependent_ types). In order to achieve this tour de force, two changes were made:
- Dependent typing can only use _erased_ variables
- Multiplicities are tracked on the _binder_ rather than being a feature of each value or of the function arrow (our beloved lollipop arrow `-o`)
While this elegantly merges the capabilities of a Martin-Löf-style type theory  (intuitionistic type theory, Per Martin-Löf, 1984) and Linear Logic, the proposed result does not touch upon potential performance improvement that such a language could feature. However it has the potential to bring together Linear types and dependent types in a way that allows precise resource tracking and strong performance guarantees.

---- 

Idris2 is such a language, and the opportunity is there to finally bring to life the always-promised-never-delivered dream of performance and correctness within the same language. Providing programmers with the tools to write elegant and correct software (Type Driven Development, Brady 2017), while ensuring performance. In this thesis I am going to reuse the intuition originally suggested by Wadler 1991 and rephrase it as 

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
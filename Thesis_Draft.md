# Linear types and performance

## Table of content

- What are linear types
    - linear types in Idris2
- How can we use them for performance
- The work I did
    - Replacing RigCount
    - Introducing Nats
    - Introducing ranges
- The Theory
    - Merging QTT and Graded monads
    - Co-effects in the type system
    - Lol pattern matching and holes
    - Exponentials and memory management
- Future work
    - Reference counted runtime
    - linear stream fusion?
    - Linear inference, parametrisation, ergonomics?
    - Error management, exceptions and control flow?
    - Programmin security, encoding language features at the type level
    - Allowing merging of user-defined linearity semirings
    

## What are linear types

Linear types are annotation for variables that appear in addition to Types. They describe how the variable is expected and should be used inside the program. They have been developped through the 90s with their firs appearance in Linear logic (cite girard) which subsequently introduced bounded Linear logic (cite again the BLL paper).

Those results were welcomed with great interest, sparking research into how to use them with existing and experimental programming languages of the time. The semantics of linear logic seemed to match very closely with memory management and uniqueness types which were understood to be useful for programming but didn't have a language to call home and be experimented with.

Nowadays uniqueness types are found in Rust and linear types are absent from mainstream programming languages. While we will not explore whyt htat is the case we will explore the promise of linear types that was left with us 30 years ago, namenly: Linear types can change how we approach programmy by providing us additional isnsight into how we should compile them and get better performance and greater confidence in their correctness.

### Linear types in Idris2

Idris2 is a new programming language that succeeds Idris. Idris is a programming language featuring dependent types. Meaning that Types are _first-class_ and can be manipulated just like any other value.

This manipulation of types allow the programmer to write programs at the _type-level_ allowing the compiler the meaningfully increase the correctness guarantees it can provide by checking invariants that the user has defined instead of invariants defined in the language.

But this great improvement in flexibility has a lot of costs, most importatnly for us: the performance guarantee become very hard to check, enforce and reason about. 

Typically this program:

```
length : Vect n a -> Nat
length _ {n} = n

isEven : Nat -> Bool
isEven Z = True -- zero is even
isEven (S Z) = False -- one is not
isEven (S n) = not $ isEven n -- is the precedessor is even the successor isn't

isEvenVect : Vect n a -> Bool
isEvenVect = isEven . length
```

While this is non-obivous from the implementation of `isEvenVect` this will bring the length value of the vector from the type level to the term-level. However, pattern matching on this type-level information has desastrous consequence, simple operations that would be O(1) for built-in types like `Int` are now O(n) because of the recusrive nature of the data that we are pattern-matching on.

Linear types however allow to precisely tell how a value will be used. If we expect it to only be used at the type-level, then it should be annotated with 0. If it can be used at the term-level exactly once, then it should be annotated with 1. If we do not want to concern ourselves with such restrictions, then we should forego any annotation and it will be automatically inferred as ∞, which means "this value is unrestricted, it could be used 0, or any amount of times". 

```
length : {1 n : Nat} -> (0 v : Vect n a) -> Nat
length _ = n

isEven : (1 n : Nat) -> Bool
isEven Z = True
isEven (S Z) = False
isEven (S n) = not (isEven n)

isEvenVect : {0 n : Nat} -> Vect n a -> Bool
isEvenVect = isEven . length -- type error? because n has linearity 0 but 1 is expected.
```

This new version of our program highlights this behaviour of moving data from the type level to the term level and catched our intent with a type error. In order to fix it we need to remove the "erased" constraint on `n` by either making it _linear_ and use `1` instead of `0` or entirely lift all restrictions and remove the linearity annotation.

## How can we use Linear types for performance?

The link between linear types and performance has been long established ever since they were introduced, the cleverly titled _linear types can change the world_ goes through the basic idea that linear types allow in-place mutation where other program would do garbage collection and allocation. The technique presented in this paper has one particular challange that is not very palpable for the computer scientist but is a real deal breaker for every-day engineers: it relies on contiutation passing style in order to make use of the benefits of linearity. While CPS isn't _wrong_ or _problematic_ in any obvious regard, it is suffers from a bad rep with software engineers since they tend to associate this practice with _Callback hell_ (find a reference to JS callback hell)

However, the general idea can be sumarised as follow

> If our value is linear, and we know it hasn't been shared before, it is unique, and therefore we can do whatever we want to it, mutate, delete, reclaim.

As you can see, CPS allows you to tightly control the scope of a linear value so that it is unique and therefore always ensure this property holds. But in this project I will use a special case of Idris' syntax that does not require CPS and that displays this property: local let bindings.

Indeed the following listing shows that whenever a variable is bound linearly. It is, by definition, unique in its upcoming scope. It might become shared later but that does not prevent us from using the previously listed property while the variable is in scope. 

```
let 1 myList = [1,2,3,4]
    1 mutated = 3 :: tail MyList
    1 reclaimed = map show mutated
    1 deleted = tail . tail . tail . tail $ reclaimed
 in …
 ```

in this scope the variable `myList` is successively mutated, reclaimed, and deleted without any extranious allocation (except for the additional memory associated with the newly allocated strings). While a traditional functional programming language with a garbage collector would naively allocate memory for each of those lines and reclaim them at a the next collection, our implementation can deduce that since `myList` is local and linear, it must be the only copy and therefore can be mutated at will. Each line therefore saves us one allocation and one free per line.


## The work I did

For this thesis, the goal was to explore how linear types can be used for performance in this very specific usecase of locally declaring a linear variable in a local let-binding. However this situation, while promissing, is quite unlikely to happen. Indeed large long linear let-bindings aren't very common and the majority of functions do not actually accept linear values as input as the typical `dup` example shows

```
-- this cannot be linear because the arugment is used twice
dup : t -> (t, t)
dup v = (v, v)
```

However if we manage to allow more flexibility in our linear variables we might be able to allow both linearity _and_ function like `dup` to make use of them. Such extensions of linear logic arise as early as 1991 with Bounded linear logic which allow to annotate every deliriction rule with a number which precisely describes how many times the value can be reused.

In our case we make use of Quantitative Type Theory to implement our linearity rules whith a semiring and uses the multiplication and addition rules in order to update the bound of a linear variable whenever it's shared in a new context.

Idris2 was using the semiring `0`,`1`,`∞` for it linearity annotation originally. While this is useful it isn't enough in order to implement a function such as `dup`, for this we need to replace `0``1``∞` and allow any arbitrary semiring to be used as a linearity annotation.


### Removing RigCount in favor or a generic semigroup with pre-order relation


Indeed the compiler is (was) using a data type of three values in order to represent linearity annotations, this data type was then pattern matched-on and analysed during linearity checking in order to compile and check when and if linearity annotation of different bound variables was consistent. However this technique, while intuitive and effective, did not allow room for experimentation using different semirings other than 0, 1 and \omega. 

The first step was then to get rid of `RigCount` and replace it by a type variable that is constrained by a verified semiring interface


```
interface Semiring a where
    |+| : a -> a -> a
    |*| : a -> a -> a
    plusNeutral : a
    timesNeutral : a
```

This definition entirely encapsulates the necessary information to define a semi-ring along with its proofs. As such, RigCount can be reinstated and used as typealias for a new type `data ZeroOneOmega = Zero | One | Omega` which follows the same semantics as the old RigCount but now using Our semiring definition.

Interestingly enough. THis is not enough. Though QTT does not require an ordering on the linearity annotations. Pattern matching on them poses a challenge that cannot be solved without using an ordering relation on the linearity values. Thankfully this has already been noticed and fixed in Granule as mentionned in it founding paper [reference to granule] in which the linearity annotation (there called graded parameter) is a pre-ordered semi-ring. the ordering allows to combine multiple semiring values together which is exactly what we need to do for pattern matching: attemping to merge the values together and error if they are not compatible with each other.

Finally, the last addition, Idris uses the assumption that by default, variables are bound with an _unchecked_ linearity annotation. This behaviour is translated by the property that an unchecked linearity value is trivially compatible with every other value. In therms of our pre-ordered semiring, this is equivalent to a `top` value that is defined for every element in the preorder and for which every value is smaller than `top`.

This replacement of linearity variables has also surfaced a lot of patterns in the existing implementation that are curious and not yet understood like


```
if isErased x then erased else top
```

can also be implemented with

```
x |*| top
```

Since `Zero` times `top`equals `Zero` (thanks to the properties of our Semiring, top has no particular meaning regarding traditional arithmetic where top would be considered to be "infinite" and multiplying zero and infinity would not be defined) this multiplication is equivalent to the previous `if`-statement, however, the semantics associated with it are different. In QTT the multiplication is only used to update the context in order to account for a tensor operation that introduces `n` new copies (I think ? I'm saying that from memory I need to check again). However, in the idris compiler this if-statment is only used ad-hoc to update some local state about the current linearity values of what is being compiled. Sometimes this state isn't even carried over to the rest of the compilation. It is unclear if this behaviour is epxected or if it is symptomatic of a hole in the theory or implementation.

## The Theory

The theory allowing us to confidently make those changes and reap the benefits is a mix of old a new ideas that span the last 30 years. Linear logic and Bounded linear logic provide the basic building blocs by addition promoton and deleriction rules to a typical STLC. Graded monads and indexed monads provide us with the necessary framework to update values in context and use this contextual information to direct the memory mangement properties of our programs. Finally QTT allows us to (re)-introduce dependent types in our calculus by assigning multiplicites to variable binders and restricting type-level computation to mutliplcity 0 variables. However those features don't magically come together and some work is required in order to reconcille QTT with graded monads and with the original promise of linear logic regarding performance.

### Merging QTT And graded parameterised monads

QTT uses a semiring in order to describe linearity of bound variables. This original implementation of QTT in Idris2 used a 0, 1, omerga semiring with additoin, multiplication, zero, and one as neutral and omega as the default linearity. 

However there is technically nothing preventing us, in principle, from replacing this semiring by something else. Ideally we should be able to use other semiring snad get different semantics. Like graded modalities for nat, or affine semantics for intervals. 

While this sounds doable in theory, the practice shows that we need more than a semiring in order to implement a programming language such as idris on top of QTT. Features like Pattern matching, implicit binding of variable, linearity inference,  all require more information than a semiring provide. That is why we actually need a bounded semilattice in our impleemntation, the upper bound serves as our "default" (very permissible linearity) and the ordering allows to combine values with different linearities when matching over them.

A program working with quantitative type theory can also be defined as an object in the category of _quantitative Categories with families_ which objets are categories themselves. Programs are morphisms within it. A program in a language such as granule is also an object in a category but in the category of graded monads. finding a functor between the two would provide a way to convert from one language to the other. A bijective functor would prove that they actually support the same feature set.

If such a functor doesn't exist there might be a product category that has two projections (are they forgetful functors?), one for graded monads and one for QCwF which unifies the two theories.

### Expanding the semantics of linearity to re-introduce Exponentials

Using 0 1 and omega as linearity annotation is a fine idea in itself but brings up a set of new challenges: What about programs which _want_ to be linear (for performance reason) but cannot because they don't have a linear usage of variables.

one way to fix this issue is to re-introduce exponentials but with 0,1, omega as linearity annotation we cannot introduce them at all! indeed, increasing the bound of a 0 term will break things (I think? I need to check, but intuitively it seems the semantics of an erased value do not play well with exponentials since suddenly the variable isn't erased anymore) and inceasing the bound of 1 doesn't go anywhere, omega cannot be used as a valid since it means "unchecked", anything goes. we need somehting akin to girard's bounded linear logic where the exponential is defined in terms of a finite bound. For that we are going to make use of our removal of RigCount and use Nat with an infinite bound as our new semiring. Our pre-order is the order on Nat. Our top value is the infinite value, 0 and 1 stay the same, addition and multiplication are the ones defined on Nats. 

With this new semiring we can equip our calculus with a new constructor for exponentials using values of the semiring that aren't 0, aren't top and do not result in top when added together.

```
let 1 v = 4
    3 increase = exp 2 v in f v -- where f uses its argument three times
```

that is now we can, given a value in our semiring, increase the bound of our linearities without breaking the contract that they will be used exactly the number of times advertised.

## Exponentials and ranges

Another semiring we can use now are intervals, or ranges. This semiring allows us to recover affine semantics in our linearity annotations, indeed a variable with linearity `[0..1]` can be used 0 or 1 time but there is no way to know which one it will be until we run the program. combining ranges with our previous semiring we get a large spectrum of modalities that can describe our programs things like [0..w], [4..6] [1..2] all become possible.

## Future work

despite this progress in expressivity we stil haven't tacked some important challenged with linear types. While playing with the semiring is useful, we still don't have a good solution for interacting between term and type level, this shows up in two crucially missing features

### Reference counted runtime

### Linear Stream fusion

Stream fusion with lists is a very succesful optimisation in Haskell. However it makes use of a lot of _clever_ compiler magic that isn't always applicable. This is a trade-off between performance and consistency. More programs can take advantage of stream fusion, however the some of them won't be able to be optimised. While this is perfectly acceptable, Idris2 can do better thanks to linearity. Indeed, The original paper on deforestation and stream fusion made use of linearity in order to rewrite expression and get rid of allocation, provided we knew they were linear. We can now in Idris, re-introduce this original algorithm and combine it with existing fold/unfold Haskell implementation in order to :

- get consistent and _ensure_ stream fusion is happening for some data structure. This will make program APIs a lot more clear since it will be impossible to use them in a way that will break the performance guarantees
- Get some amount of performance back when the original deforestation algorithm doesn't apply. Maybe we can discover interesting interaction betwen the two algorithm if we interleave them and introduce some linearity-inference in the mix.

### Linear inference, Parametric linearity and ergonomics

Sometimes linearity is too restrictive, specially for library users. Someone might want to use a library which features linearity but their own code is not written in linear style. As of today this makes the entire library unusable since the compiler will, unsuccessfully, try to merge unchecked linearities with rigid ones, which will result in an unfixable type error for our user.

One solution would be to relax the linearity merging rules but this might introduce unsoundness in the calculus, or ruin our efforts at opimisation since now, sometimes linear typing behaves with the expected performance guarantees, but sometimes, when the arguments given aren't linear, it does not.

Another one, which is one that _linear haskell_ has been using, is to use parametricity in the linearity of functions exposed by the compiler. 


```
maybeLinear : forall l . (a -o_l b) -o a -o_l b 
```

this function might be trivial but it clearly exposes that _if_ the function passed in is linear, then everything is linear. If the function passed in argument has no guarantees, then we do not know what is going on with a and b.

Technically speaking, as pragmatic compiler designers, we could simply synthesize non-linear versions of each linear functions so that users who are un-interested in linearity can still use them. However this does not entirely solve the problem as there exists functions which are partially linear and partially parametric. This brings us to our second problem

### Error management, exceptions and control flow

Linearity is often a barrier to writing programs in the existing imperative-like syntax using do-notation, monad transformers, exceptions, branching control flow etc.

Take this simple example

```
mayFail : (computation : Either String Int) -> (1 v : Int) -> Either String Int
mayFail (Left err) _ = Left err
mayFail (Right a) b = Right (a * b)
```

In this example the value v is ignored when the pattern on the left maps to `Left` which doesn't make it linear but affine. There are multiple ways to go about solving this problem. One of them is using `Intervals` which allow to simulate affine semantics. Affine means that, while we do not know the exact number of uses. We know it is bounded by some finite value.

It would look like this

```
mayFail : (computation : Either String Int) -> ([0..1] v : Int -> Either String Int
```

Another solution woud be to allow type-level computation to affect the multiplicity of a variable

```
LinearFail : Either a b -> Nat
LinearFail (Left _) = 0
LinearFail (Right _) = 1

mayFail : (computation : Either String Int) 
       -> ((LinearFail computation) v : Int) -> Either String Int
```

While this is a bit verbose it is _extremely_ powerful and desirable, it is the topic of the next possible area of research: Allowing type indices to interacti with linearity anotations.


### Allowing type indices to interact with linearity

Dependent types are extremely useful when used in conjunction with data types in order to restrict some values or semantics about them. parameterising a datatype at the type level in order to restrict the values it can take is commonly referred to as _indexing_, where the type parameter is the _index_ of the datatype. Granule already allows a great deal of interaction between type indices and linearity, however this is allowed by a fundamental difference between type-level and term-level definitions. Term-level values are not allowed to show up as linearity annotations in Granule. While this restriction should also apply for Idris, it is impossible to check for, indeed, thanks to the flexibility of dependent types, one is unable to tell if a value comes from the term-level or the type level.

However there is hope. We might be able to restrict type-level interaction to erased types (just like is already the case with general type-level computation) but only when interacting with Nat types, or `Nat`-like types, which brings us to our third limitation

### Allow user-defined semirings to be used in the type-checking mechanism

While intervals provide a great deal of expressivity, they do not encapuslate the entire realm of possible programs out there. While it is true that our goal is to restrict the amount of possible programs that are _correct_ we also want to allow _new ways_ of expressing the correctness of your programs. Dependent types are a step in that direction, linear type are another, allowing user-defined semirings to be used by the type checked in order to enforce invariants that only users can predicts would be a step equivalent in complexity and in power as the one from hindley-milner to Martin-lof dependent types. Suddenly, values that were only handled by the user can also be used by the compiler and this now provide new ways of checking for invariants. Granule shares this goal of allowing user-defined linearities but hasn't implemented it as of yet. There is no doubt that such a feature will exist at some point in the future, we just need more time to figure out the details, because now both type checking and linearity checking are dependent.

One typical example of how this would be useful is in access restriction of variables, imagine a semring with values `Public`, `Private`, `Anything` where private values cannot be exposed through the api (think about cryptographic secrets, tokens, identities) but public ones can, programs have to juggle private and public data but never _leak_ any private data. using a non-linear type system it would be trivial to accidentally write

```
leak : (public : Int) -> (private : Int) -> Int
leak pub priv = priv `mod` pub
```

where the private key is leaked simply by calling this function with `1` as its first argument

however with the signatures

```
mod : (Public a b : Int) -> Int

leak : (Public pub : Int) -> (Private priv : Int) -> Int
leak pub priv = priv `mod` pub -- compile error
```

would result in a compile error since the private key is used as a public field

This allows us to implement what were previously language features inside the type-system making them simply a library in our new language.

We could the imagine more complicated models of private/public/protected APIs only using user-defined semirings mixing up different concepts like linearity, affine types, performance, etc. Such an area of use would be smart-contracts on blockchains which suffer from extremly complex resource management that entirely depend on the semantics of the blockchain so that each has to be special-purpose. While also requiring very strick resource-checking and security access checking.

Currently, there is no way to interact with linearity annotation outside of writing them now manually 

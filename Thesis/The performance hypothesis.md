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

The key observation is that a value `v` is constructed and bound linearly _and_ its only use is performed in-scope. 

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
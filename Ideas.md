# The infinite abyss of ideas nobody has time for

## Use levitation for optimising buffer reads

Make `Vect n a` go fast (and indexing a list with an `Elem` go fast too)

## Use levitation in the Idris 2 compiler to generate derived instances

Since with levitation we know if a type has a type parameter we could derive functor, applicative 
etc, for it. We could use indices to genereate uninhabited instances, and use the constructors to 
implement Eq and DecEq instances.

## Use levitation in the Idris2 compiler to avoid dealing with primitives 

When typechecking we could have a mapping between primitive types and types we can represent as a 
levitated type. `Int32` could be `Vect 32 Bool` and all proofs could use this datatype instead. 
Strings could be `List Char` and `Char` could be `Vect 8 Bool`. Then the mapping could replace all
those types and operations on those types by their primitive versions. The extra bonus is that types
that already look like `Nat`
or are aliases for `Nat` could be replaced too even if they aren't called `Nat`, avoiding relying 
on the exising "NatHack".

## Automatic reference counting using linear/graded modal types

I mean they're the same thing aren't they? If they arent, isn't there a way to 
go from one to the other?

## Make a VR editor

Only allow predefined operations on files, use 3d space to navigate the project. Use arms and hand 
motions to operate on the file. WOrking on an implementation should feel like blacksmithing.

## An Idris2 hackathon

Let's make everything happen

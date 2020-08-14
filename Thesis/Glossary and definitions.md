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
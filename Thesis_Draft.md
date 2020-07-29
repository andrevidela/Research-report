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


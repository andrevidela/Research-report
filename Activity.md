# TODO

- [ ] fix file read error on compiling the prelude
- [ ] fix version number on idris makefile
  - when you compile idris with `make idris2` and then compile again, but from another commit. The new binary is indeed compiled but it retains its old version number.
- [ ] write a tool that measures compile time between two commits of idris2
- [ ] write a tool that measute compile time of prelude in idris2 using 2 commits of idris2
- [ ] finish re-reading linear haskell
- [ ] split the PR for documentation with the WIP branch
- Nicola 
  - [ ] test the benchmarks by Nicola (_10.10_)

- Bitwise multiplication 
  - [ ] finish multiplication and use it as benchmark?(_14.10_)
  - [ ] ~~keep looking for ways to implement data declarations as Containers~~ (_14.10_ what was that?)
  - [ ] implement in idris 2 (_17.10_)
  - [ ] see if I can introduce linear annotations (_17.10_)
- Idris-bench
  - 25.10:
    - [ ] given a path to idris and a file to compile, compile the file `String -> String -> IO ()`
    - [ ] given a path to idris and a file, benchmark the compiled executable `(idris : String) -> (file : String) -> IO Clock`
    - [ ] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
    - [ ] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
    - [ ] print the resulsts nicely
    - [ ] cleanup the garbage nicely
  - 29.10
    - [ ] average the results over n runs
    - [ ] give a target for the output
    - [ ] cleanup the garbage nicely
- Fractal nets
  - idea: compose nets and compose layers, see if they give the same result, see if they commute in ther category theory interpretation
  - look into http://events.cs.bham.ac.uk/syco/6/
- GNN
  - idea: abstract over the data structure used for convolution, use categorical morphisms to convert from one object to the other (derivable euclidean spaces and finite descrete graphs)

#10.02

- stream 11
- little typer

# 09.02

- went back to using rig type as a value on the context record

# 08.02

- tried to put the rigcount as a type parameter but its starting to contaminate everything. Maybe I should put it as a value in `Context` to avoid the spreading of the disease. This might also make it more flexible if I want to bring a semiring from the user program.

# 07.02

- still sick but much better
- worked some more on refactoring rigcount away

# 06.02

- very sick
- worked on rigcount and semirings

# 05.02

- watched opengames from Jules
- streamed ep 10
- keep going with linear use

# 04.02

- almost fixed that versio nnumber issue, lots of recompiles

# 03.02

- streamed ep 9
- started looking into that version number thing again
  
  
# 31.1

- streamed ep 8
- [x] gave a go to replace the logging into its own file but that wouldn't actually give us any benefits since it depends on `Session` `Ctxt` and `Refs` which are all defined in `Context` and `Options`, which means we can't import `Logging` from `Context` anyways since `Logging` would have to import `Context`. The solution would be to split again the file into `Context.Data` where all the data types live but that would make a much bigger diff that what was intended. This is particularly problematic for the self-hosting efforts
  
# 28.1

very refreshed from the break!

# 27.1

took a break
  
# 26.1

- streamed for a bit

Very tired 

# 25.01

uploaded last VOD of stream

# 24.01

- went to second capod course for teaching
- streamed about prelude and pushing tag down to CCon

# 23.01

Went to Capod course for teaching 
Edited and uploaded VOD from steam 
# 22.01

- working on DataCon, CCon and NamedType

# 21.01 break day
  
  
- watched modalities in type theory  http://youtu.be/SLJDwhRg5Yk
- watched ordinal notations in agda  https://youtu.be/Rt2OrG3IHkU
- rewatched quantitative type reasoning in granule  https://youtu.be/2HOtpcrmXMQ

# 20.01

- put a reminder to fill up this page
- finished my research proposal
- streamed ep 3
  - worked some more on pattern matching on function types.

# 13.01

- streamed again
- started looking into erasing of pi types
  
# 10.01

- streamed again
- [x] make cosmetic PR

  
# 09.01

- [x] started streaming
- [ ] make cosmetic PR
  
# 08.01

back in business
- [x] tried to setup streaming

------------------------ 2020------------------------


# 15.12

- test fail due to corrupt TTC, whut?

# 12.12

- [x] try to fix the compile errors due to the new tag
  - it compiles!
  
# 11.12

- [x] installed and setup streaming software on personal laptop

# 9.12

- [x] setup uni laptop
- [ ] try to fix the compile errors due to the new tag
# 06.12

- got the uni laptop, started setting it up but I don't have access to the firmware password so I can't boot in recovery mode or on a usb-stick
- meeting with edwin, new ideas about how to go about implementing in-place updates
- might try to see if there is a bug with dependent function types getting eroneously erased when they shouldnt
  - I should write a test case
  - I should see what happens if I delete the line
  
# 05.12

- [x] read little typer chapter 4
- [x] find a way to detect uses of linearity 1 and then deallocate them
  - im just gonna use let!
  
# 04.12

- [x] read little typer chapter 1
- [x] read little typer chapter 2
- [x] read little typer chapter 3

  
# 02.12

- [x] read LInear types can change the world 
  - that is true
  - maybe I should use let! for unique binding
 

# 01.12 

- [x] watch "how to write a paper" from SPJ

# 28.11

- worked on the paper some more

# 27.11

- started watching how to write a great research paper by SPJ
- started working on an outline for the memory-reclaim paper

# 26.11

- keep going through the codebase, maybe `GlobalDef` wasn't the right choice?

# 25.11

- Added a tag that tracks if a definition is unique or not.
- wrote more documentation


# 21.11

- rough day (legal etc)
- [x] re-organised research report

# 20.11

- [x] contact package manager student to add typedefs as benchmark
  - probably not until next semester
- [x] fixed computer
- [x] figure out how to deallocate on chez backend
  - Asked edwin, apparently, data is held in vectors. they should be able to be mutated in place whenever something needs to be removed or replaced.

- Meeting with edwin
  - borrowing?
  - use levitation to detect nat-like structure and vect-like buffers
  - linear API? How to do them? How to implement typeclasses/interfaces?
  - parametricity on linearity?
  - granule-like parametricity on linearity?
  - OTT Observational Type Theory -> QOTT, Quantitative Observational Type Typeory.

# 19.11

- [x] reading though practical levitation

# 11.11 -> 17.11

London etc

# 10.11

- [ ] implement levitation in Idris
  - found this paper instead https://itu.dk/people/asal/pubs/msc-thesis-report.pdf

# 9.11

Tried to replace `RigCount` to an abstract `Semiring` but it didn't
work very well, there were a lot a pattern matching on `Rig0` and
`Rig1`. Probably fixable with a view but it's too much work for not
very much payoff. It might also increase compilation time by a lot

# 5.11
- [ ] started working on metric spaces textbook
  - started implementing examples in Idris
- attending talk from Jan de Muijnck @jfdm. Notes:
  - not using free SMC
  - using linear to model the fact that you can't plug a cable twice
  - constrained version of verilog constructs

# 4.11
 
 - [x] finish reading walder's paper on linear types
   - started implementing this mess

# 1.11

- got heavily distracted by neural networks and urban simulation, spent the day looking at cities skyline API and how to implement CNN but abstracting over the convolution. Read https://arxiv.org/abs/1711.10455

# 31.10

- started looking into convolutional neural network 
  - I think I should be able to modify Swift For TensorFloow to take any metric space instead of a euclidean space for convolution. This should allow to use not only Graph convolution networks but any other metric space with any kind of data that cannot trivially be converted to euclidean space. Moreover if we find a way to translate between graphs and euclidean spaces we can see if the same training data yields the same results depending on the metric space used.
- start reading the gentle art of levitation
- start reading those https://homepages.inf.ed.ac.uk/wadler/topics/linear-logic.html

# 30.10 SPLS

Got lectures for levitation and linear-types

# 29.10

- [x] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
- [x] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
- [x] print the results nicely

those took me forever but it works I even have a folder for pathological cases

here is what's left:

- [x] given a commit, build the correct verion of Idris
- [ ] average the results over n runs
- [ ] give a target for the output
- [ ] cleanup the garbage nicely


## 28.10

- The great benchmark suite:
  - [x] benchmark any arbitrary program : `Lazy (IO ()) -> IO Clock` and `Lazy (IO Int) -> IO (Maybe Clock)
  - [x] compile Idris itself from a commit or branch `(commit : String) -> IO ()`
  - [x] benchmark idris compilation itself `(commit : String) -> IO (Maybe Clock)`
  - [x] given a path to idris and a file to compile, compile the file `String -> String -> IO ()`
  - [x] given a path to idris and a file, benchmark the compiled executable `(idris : String) -> (file : String) -> IO Clock`


# 25.10

- Got sick of running benchmark scripts by hand and the amount of .sh files is unweildy, started writing a benchmark program in idris
  - [x] benchmark any arbitrary program : `Lazy (IO ()) -> IO Clock` and `Lazy (IO Int) -> IO (Maybe Clock)
  - [x] compile Idris itself from a commit or branch `(commit : String) -> IO ()`
  - [x] benchmark idris compilation itself `(commit : String) -> IO (Maybe Clock)`
  - [ ] given a path to idris and a file to compile, compile the file `String -> String -> IO ()`
  - [ ] given a path to idris and a file, benchmark the compiled executable `(idris : String) -> (file : String) -> IO Clock`
  - [ ] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
  - [ ] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
  - [ ] print the resulsts nicely
  - [ ] cleanup the garbage nicely

# 24.10

# 23.10

- [x] Idris2 doesn't compile? Edwin pls
  - turns out public re-exports are broken in Idris1? I had to add `Control.Catchable` in `Idris/Package.idr`
  - nvm that wasn't it. I does work on the REPL but not when compiling from scratch. Might be due to some import state
    transfering over when loading multiple files in the REPL.
  - nuking everything and rebuilding worked ¯\\\_(ツ)\_/¯ 

# 22.10

- [ ] start looking into how to reclaim memory when a linear value has been 
      pattern matched on.
  - basically put logs and compiled the compiler again
  - I should automate the running of benchmarks for each new commit

# 21.10

- [x] finish bitwise mutiplication
 - [x] implement in idris 2
 - [x] see if I can introduce linear annotations
   - sort of but they don't seem to be doing anything I should add more and 
     make another version which has a lot of them and another one with very few
     
Gave up on Karatsuba, it's too error prone and it's not directly related to the
thesis, I'll kee the basic addition functions and use those as benchmark. They
should be enough to showcase when linearity matters or not.

# 17.10

- [x] read chapter 5 of Edwin's thesis
  - should be fun to implement in Idris, we'll see if I have enough time
- [ ] finish bitwise mutiplication
- [ ] implement in idris 2
- [ ] see if I can introduce linear annotations

# 16.10

worked on bitwise multiplication

# 15.10

worked on typedefs and internet

# 14.10

- [x] build latest version of Idris and try IdrisLib again
  - [x] built the tests as well, here are the results:
  
```
  
time echo 1 | ./emissionsgame2 0.452 total
time echo 2 | ./emissionsgame2 1.674 total
time echo 4 | ./emissionsgame2 11.841 total
time echo 6 | ./emissionsgame2 1:33.36 total

time echo 1 | ./emissionsgame2fast 0.335 total
time echo 2 | ./emissionsgame2fast 1.230 total
time echo 3 | ./emissionsgame2fast 6.357 total
time echo 6 | ./emissionsgame2fast 26.484 total
time echo 8 | ./emissionsgame2fast 2:57.46 total

time echo 1 | ./emissionsgame2fast2 0.296 total
time echo 2 | ./emissionsgame2fast2 1.068 total
time echo 4 | ./emissionsgame2fast2 5.773 total
time echo 6 | ./emissionsgame2fast2 26.567 total
time echo 8 | ./emissionsgame2fast2 3:10.961 total
```

- [x] fix chez version
- [x] port the existing fibonacci benchmarks to Idris2
  - made a repo at https://github.com/andrevidela/idris-bench
- [ ] finish multiplication and use it as benchmark?
- [ ] keep looking for ways to implement data declarations as Containers
- [x] watch javascript for idris developers
  - hilarious, should watch it with other people too


# 11.10
 - [x] Tried reading through algebraic types and see if there is a universal way of detecting types that can be represented with a continuous buffer in memory instead of chasing pointers.
 - Read through Idris 2 code to see where data declaration were handled and how they were inserted in context but couldn't find anything.
 - Interestingly this is where having a compiler written in a dependently typed language can be useful since it could allow us to write things such as "Cont" the category of containers or things like Typedefs with Pi-types which could represent all datatypes in Idris. Interestingly enough this could also be a contender to implement "derive" instead of going through elaborator reflection.

# 10.10

- [ ] test the benchmarks by Nicola
  - I guess I'll do that tomorrow in the plane
- [x] read about fibrations (https://bartoszmilewski.com/2019/10/09/fibrations-cleavages-and-lenses/)
  - I should try to implement that with Idris-ct later
- [x] watch this Microsoft research talk about lean (https://www.youtube.com/watch?v=Dp-mQ3HxgDE)
  - No mention of Agda or cubical type theory, might be interesting to compare lean with cubical agda, specialy in terms of quotients
- [x] finish implementing Fibonacci etc
  - interestingly `(n : Nat) -> Vect n Nat` does not allocate a vector of size `n` immediately
  - only in idris2, still have to implement idris2
  - should create github repo as well

# 9.10

too sick to do anything

I guess I read "clowns to the left jokers to the right" by McBride


# 8.10

- [x] run examples for IdrisLib
  - had to add a bunch of `--allow-capitalized-pattern-variables` options in makefiles
  - run `make all` in `SequentialDecisionProblems/examples`
  - `./example1` with input `5` `5` already takes forever
  - Looks like the examples weren't ported to Idris 2 mhhhh
  
- [x] write runtime programs from haskell and scala benchmarks
  - [x] port prime sieve
  - [x] port fibonacchi
  - [x] port vector sum
  - [x] string concatenation 


# 7.10

- [x] Attending Pgr presentations

# 04.10

- [x] send email to potsdam
- [x] find the haskell examples
  - trying out https://gitlab.haskell.org/ghc/nofib
  - had some trouble with cabal and regex-compat
  - it works? not sure how to read output
- [x] writes scripts for benchmark idris-ct compile time
  - idris-ct takes forever zzzzz 
  - result:s
  ```
  idris --build idris-ct.ipkg 2> /dev/null  1040.68s user 73.42s system 56% cpu 32:38.09 total
  idris2 --build idris-ct.ipkg 2> sleep.stderr  47.78s user 6.41s system 99% cpu 54.457 total
  ```
  - nice x22 speedup on Idris-ct
- [x] check training on monday
- [x] answer botta about PIK and slow runtime, ask for examples
  - updated thesis draft with idea for improving runtime by allowing O(1) memory allocation




# 03.10

- [ ] find an adapt haskell examples
- [ ] write a script that measures compilation time
- [ ] write a script that measures run time
- [x] ask anton about access to the game again
  - Maybe once the project is better defined, might not use the name of it for the paper.
- [x] scan the amazon locker at Agnes Blackadder Haugh

#### What actually happened

Wrote emails all day for law insurance and managing matters in Switerland

# 02.10

- [x] resend emails to Edwin if he didn't answer
- [x] call to schedule application for national insurance number
  - meeting at 14:50 in Glasgow
  - Contact Fred to see if I should visit strathclyde as well
- [x] compile them + TParsec, Idris-CT, + all dependencies with Idris 2
  - probably won't work as is, but if any of them work, keep an eye on them for future benchmarks
  - [x] Idris2Libs
    - Had to remove `-V --allow-capital-pattern-variables`
    - stuck on `1/1: Building ..tests.Linear (./tests/Linear.idr)`
  - [x] Idris-ct Idris2 branch
    - something like 10x faster than idris 1
  - [x] TParse Idris 2 branch
    - something like 4x faster than Idris1
- [x] meeting at 2pm with Edwin
  Topics:
  - Idris2 from personal repo to Idris-dev?
    - dunno, maybe when it's self hosted?
  - Does my case study sound like an interesting challenge?
    -Yay
  - Laptop?
    - no progress
  - potsdam repo?
    - [ ] send email to potsdam for other repos for benchmarks
  - vacation days?
    - tell at least someone

## Meeting notes: next steps

- deploy infrastructure for benchmarking + see with CI
- 2 approachs: convert programs from non linear to linear or design a new implementation with linear in mind and see what happens.

## delayed

- find an adapt haskell examples

# 01.10


- [x] fix cs account with new password
- [x] figure out accomodation
- [x] contacted health inssurance
- [x] meeting at 2pm with statebox
- [x] compile Idris 2
  - removed network tests though
- [x] figure out national insurance number
  - no answer, will call tomorrow
- [x] figure out laptop + monitors (no US layout, maybe worth using a desktop instead?)
  - sent a message to Edwin, we'll see if uni makes an exception
- [x] fix wifi access on iPad
  - I was typing the wrong password all along ;__;
- [x] find big idris repos (potsdam repo?)
  - found IdrisLibs and Idris2libs, are there others?
- [x] compile them + TParsec, Idris-CT, + all dependencies with Idris 1
  - [x] tparsec
  - [x] idris-ct
  - [ ] IdrisLibs (compile failed)
  
##### delayed:
- compile them + TParsec, Idris-CT, + all dependencies with Idris 2


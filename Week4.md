## 21

- [x] finish bitwise mutiplication
 - [x] implement in idris 2
 - [x] see if I can introduce linear annotations
   - sort of but they don't seem to be doing anything I should add more and 
     make another version which has a lot of them and another one with very few
     
Gave up on Karatsuba, it's too error prone and it's not directly related to the
thesis, I'll kee the basic addition functions and use those as benchmark. They
should be enough to showcase when linearity matters or not.

## 22

- [ ] start looking into how to reclaim memory when a linear value has been 
      pattern matched on.
  - basically put logs and compiled the compiler again
  - I should automate the running of benchmarks for each new commit

## 23

- [x] Idris2 doesn't compile? Edwin pls
  - turns out public re-exports are broken in Idris1? I had to add `Control.Catchable` in `Idris/Package.idr`
  - nvm that wasn't it. I does work on the REPL but not when compiling from scratch. Might be due to some import state
    transfering over when loading multiple files in the REPL.
  - nuking everything and rebuilding worked ¯\\\_(ツ)\_/¯ 

## 24

## 25

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

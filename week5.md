## 28

- The great benchmark suite:
  - [x] benchmark any arbitrary program : `Lazy (IO ()) -> IO Clock` and `Lazy (IO Int) -> IO (Maybe Clock)
  - [x] compile Idris itself from a commit or branch `(commit : String) -> IO ()`
  - [x] benchmark idris compilation itself `(commit : String) -> IO (Maybe Clock)`
  - [x] given a path to idris and a file to compile, compile the file `String -> String -> IO ()`
  - [x] given a path to idris and a file, benchmark the compiled executable `(idris : String) -> (file : String) -> IO Clock`
  - [ ] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
  - [ ] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
  - [ ] print the resulsts nicely
  - [ ] cleanup the garbage nicely

# 29

- [x] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
- [x] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
- [x] print the resulsts nicely

those took me forever but it works I even have a folder for pathological cases

here is what's left:

- [x] given a commit, build the correct verion of Idris
- [ ] average the results over n runs
- [ ] give a target for the output



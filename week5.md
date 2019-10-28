## 28

- The great benchmark suite:
  - [x] benchmark any arbitrary program : `Lazy (IO ()) -> IO Clock` and `Lazy (IO Int) -> IO (Maybe Clock)
  - [x] compile Idris itself from a commit or branch `(commit : String) -> IO ()`
  - [x] benchmark idris compilation itself `(commit : String) -> IO (Maybe Clock)`
  - [ ] given a path to idris and a file to compile, compile the file `String -> String -> IO ()`
  - [ ] given a path to idris and a file, benchmark the compiled executable `(idris : String) -> (file : String) -> IO Clock`
  - [ ] given a path to idris and a directory, benchmark the whole directory `(idris : String) -> (dir : String) -> IO (String, Clock)`
  - [ ] given a path to idris and a directory, benchmark the whole tree recursively `(idris : String) -> (dir : String) -> IO FileTree Clock`
  - [ ] print the resulsts nicely
  - [ ] cleanup the garbage nicely

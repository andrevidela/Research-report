# Master plan to a successful thesis

- benchmark Idris compilation types and output code performance
- write some example with and without linear types
- figure out how to make linear types faster
  - free after pattern match on linear 1
  - erase linearity 0 (already done), measure the performance improvement
- Write about the results: good, bad, inconclusive

fun case study:

- Take the current C++ parser for [Arcaea](https://arcaea.lowiro.com/en)
- reimplement the parser in Idris exposing the C FFI
- compare the performance between C++, Idris 1 and Idris 2

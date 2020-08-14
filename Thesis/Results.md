# Results
  
In this section I will present the results obtained from the compiler optimisation. In case you skipped the theoretical section here is the case we are otimising away:

```haskell
let 1 v = MkValue
    1 result = update v -- this update should be a mutation
in 
    result
```

if the update function is written linearly then it should reuse the memory space taken by `v`, if it isn't, then it will allocate a new value.

Our expectation is that our programs will run fasters for 2 reasons:
- Allocation is slower than mutation
- Mutation avoids short lived variables that need to be garbage collected

Indeed allocation will always be slower than simply updating parts of the memory. Memory allocation requires finding a new memory spot that is big enough, writing to it, and then retuning the pointer to that new memory address. Something allocation of big buffers will trigger a reshuffling of the memory layout because the available memory is so fragmented that a single continuous buffer of memory of the right size isn't avaiable.

Obviously all those behaviours are hidden from the programmer through _virtual memory_ which allows to completely ignore the details of how memory is actually laid out and shared between processes. Operating systems do a great job a sandboxing memory space and avoid unsafe memory operations. Still, those operations happen, and make the performance of a program a lot less consistent than if we did not have to deal with it.

In addition, creating lots of short lived objects in memory will create memory pressure and trigger garbage collection during the runtime of our program. A consequence of automatic garbage collection is that memory management is now outside the control of the programmer and can trigger at times that are indesirable for the purpose of the programs. Real-time applications in particular suffer from garbage collection because it makes the performance of the program hard to predict, an unacceptable trade-off when execution need to be guaranteed to run within a small time-frame.

All the benchmarks were run on a laptop with the following specs:
- Intel core-i5 8257U (8th gen), 256KB L2 cache, 6MB L3 cache
- 16Gb of ram at 2133Mhz
While this computer has a base clock of 1.4Ghz, it features a boost clock of 3.9Ghz which is particularly useful for single-core application like ours. However, turbo-boost might introduce an uncontrollable level of variance in the results since it triggers based on a number of parameters that aren't all under control (like ambiant temperature, other programs running, etc). Because of this I've disabled turbo boost on this machine and run all benchmarks at a steady 1.4Ghz.

## Results1: Fibonacci

Out first test suite runs the benchmark on our 3 fibonacci variants. As a refresher they are as follow:
- The first one is implemented traditionally, carrying at all times 2 Ints representing the last 2 fibonacci numbers and computing the next one
- Second one boxes those Ints into a datatype that will be allocated every time it is changed
- The Third one will make use of our optimisation and mutate the boxes values instead of discarding the old one and allocating a new one.

The hypothesis is as follows: Chez is a very smart and efficient runtime, and our example is small and simple. Because of this, we expect a small difference in runtime between those three versions. However, the memory pressure incurred in the second example will trigger the garbage collector to interfere with execution and introduce uncertainty in the runtime of the program. This should translate in our statistical model as a greater variance in the results rather than a strictly smaller mean.

### The results

Here are there results of running our benchmarks 100 times in a row:

* graph of results after 100 attempts*
The command line used was
```haskell
build/exec/benchmarks -d ../idris2-fib-benchmarks -o results.csv -p $(which idris2dev) 
```

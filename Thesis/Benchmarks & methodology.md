# Benchmarks & methodology

In order to test our performance hypothesis I have designed a suite of synthetic benchmarks and a list of real-world programs. Benchmarks are programs that are used to measure some aspects of performance. Having multiple benchmarks allows us to use one as our control group and then change some variables in other benchmarks to measure the impact of our changes.

In our case the control group is the benchmark results of each of the example files at a specific commit of the Idris2 compiler, without using our optimisation. The variables we are going to introduce is the new mutation instruction for the same program.

There are 2 types of benchmarks we want to write:
- synthetic benchmarks designed to show off our improvements.
- real-world benchmarks designed to test its influence on programs that were not specifically designed to show off our improvements.
	 
The goal of the first category is to explore what is our "best case scenario" and then go from there. Indeed, if the best case scenario doesn't provide any results, then either there is something wrong with our implementation, or there is something wrong with our idea.

The goal of the first category is to have a baseline of performance improvement for regular programs. The goal isn't necessarily to prove them fast, but to build up a realistic library of program that we want to for in the long run. One typical course of action we hope to achieve is the following:

- Benchmark X doesn't show any improvement over the original compiler implementation
- We change one function from an unrestricted definition to a linear one
- We find a performance improvement

This will inform us of the benefits and limitation of our optimisation in a concrete and measurable way. 

## Synthetic benchmarks

Synthetic benchmarks are designed to show off a particular effect of a particular implementation. They are not representative of real world programs and are mostly there to establish a baseline so that variables can be tweaked with further testing. For this project I have designed 3 benchmarks which are all expected to highlight our optimisation in different ways.

## Fibonnaci

One cannot have a benchmark suite without computing fibonacci, in this benchmark suite we are going to tweak the typical fibonacci implementation to insert an allocating function within our loop. Our mutation optimisation should get rid of this allocation and make use of mutation instead. Because of this we are going to look at three variants

### Traditional Fibonacci

This version is the one you would expect from a traditionnal implementation in a functional programming langauge

*insert definition of fibonnaci normall*

As you can see it does not perform any extraneous allocation since it only makes use of primitive values like `Int` which are not heap-allocated. If our optimisation works correctly we expect to reach the same peformance signature as this implementation

### Allocating fibonnaci

This version of fibonnaci does allocate a new value for each call of the `update` function. We expect this version to perform worse than the previous one, both in memory and runtime, because those objects are allocated on the heap (unlike ints), and allocating and reclaiming storage takes more time than mutating values.

*insert allocating fib*

### Mutating Fibonacci

This version is almost the same as the previous one except our `update` function should now _not_ allocate any memory, while this adds a function call compared to the first version we do not expect this version to have a significanly different performance profile as the first one

*insert mutating fib*

## Lots of allocations

This benchmark is a bit naive but effectively demonstrate our idea in a very direct way: We are going to allocate linearly a lot of variables and mutate them. This should result in a more efficient bytecode but it's unclear if the performance improvement will be significant. Indeed, it might be that the targeted backend (chez scheme) is able to already detect this control flow and optimise it for us without any effort on our part.

## Prime Sieve

Finding prime numbers is an age-old problems that computers are notoriosly good at compared to humans. Much like fibonacci, this problem is  staple in the realm of computer benchmarks, allowing us to compare our solutions to other existing programing languages and features.

## Real-world benchmarks

For our real world benchmarks we are going to use whatever is available to us. Since the ecosystem is still small we only have a handful of programs to pick from. For this purpose I've elected the following programs:

- The Idris2 compiler itself
- A Sat solver

The Idris2 compiler itself has the benefit of being a large scale program with many parts that aren't immediately obvious if they would benefit from memory optimisation or not. Having our update statement be detected and replaced automatically will allow us to understand if our optimisation can be performed often enough, where and if it results in tangible performance improvements.

Sat solvers themselves aren't necessarily considered "real-world" programs in the same sense that compilers or servers are. However they have two benefits:
- You can make them arbitrarily slow to make the performance improvement very obvious by increasing the size of the equations to satisfy
- They still represent a real-life case study where a program need to be fast and where traditional functional programming has fallen short compared to imperative programs, using memory unsafe operations. If we can implement a fast SAT solver in our functional programming language, then it is likely we can also implement fast versions of other programs that were traditionally reserved to imperative, memory unsafe programming languages.

# Measurements

The benchmarks were run with a command link script written in idris itself which takes a source folder and recursively traverses it in order to find programs to execute and measure their runtime.

This benchmarking program itself can be found at [https://github.com/andrevidela/idris-bench](https://github.com/andrevidela/idris-bench).

The program itself takes a number of arguments:

- `-p idrisPath` the path to the idris2 compiler we want to use to compile our tests. This is used to test the different between different compiler versions. Typically running the benchmarks with our optimized compiler and running the benchmarks without our optimisation can be done by calling the program with two different version of the idris2 compiler.
- `-t testPath` The path to the root folder containing our test files
- `-o fileOutput` The file that will be written with our results as a CSV file
- `--stdout` Alternatively, the output can be redirected to stdout (this option is mutually exclusive with `-o`)
- `-c count` The number of times each file has to be benchmarked. This is to get multiple results and avoid lucky/unluck variations.

# Statistical analysis

For our results we are simply going to look at the mean of the results and the variance. Since we consider each result to be equiprobable the expected value equals the mean. For this we are going to rely on another script that will take out CSV output and compute the mean and variance of our timing results and output them as another CSV file. Again the code can be found here [https://github.com/andrevidela/idris-bench](https://github.com/andrevidela/idris-bench).

## 14

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

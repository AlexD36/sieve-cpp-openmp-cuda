# Sieve of Eratosthenes: Sequential vs OpenMP vs CUDA

![C++](https://img.shields.io/badge/C%2B%2B-17-blue?style=flat-square)
![OpenMP](https://img.shields.io/badge/OpenMP-4.5-5e9c40?style=flat-square)
![CUDA](https://img.shields.io/badge/CUDA-11.2-76b900?style=flat-square)

This project implements the **Sieve of Eratosthenes** algorithm using three different approaches:
- **Sequential** (C++)
- **OpenMP** (parallelized on CPU)
- **CUDA** (parallelized on GPU)

The goal is to compare the performance of these implementations in terms of execution time and scalability across CPU and GPU architectures.

![ChatGPT Image Apr 6, 2025, 12_52_51 AM](https://github.com/user-attachments/assets/aa51ff30-f217-4aed-8532-977ab46250c4)

## How to run

### Prerequisites

- C++ compiler (e.g., GCC, Clang)
- OpenMP support
- CUDA toolkit (for GPU implementation)

### Compilation

1. **Sequential C++ implementation**:
   - `g++ -o sieve_sequential sieve_sequential.cpp`
   - `./sieve_sequential`

2. **OpenMP implementation**:
   - `g++ -fopenmp -o sieve_openmp sieve_openmp.cpp`
   - `./sieve_openmp`

3. **CUDA implementation**:
   - `nvcc -o sieve_cuda sieve_cuda.cu`
   - `./sieve_cuda`

### Usage

Run the program for a given number `n` to find all prime numbers up to `n`. For example:

```bash
./sieve_sequential 1000000
./sieve_openmp 1000000
./sieve_cuda 1000000
```

### Performance Analysis


This project also includes performance benchmarks to compare the execution times of each implementation. You can find the results in the results/ directory.

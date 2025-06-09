
![C++](https://img.shields.io/badge/C%2B%2B-17-blue?style=flat-square)
![OpenMP](https://img.shields.io/badge/OpenMP-4.5-5e9c40?style=flat-square)
![CUDA](https://img.shields.io/badge/CUDA-12.8-76b900?style=flat-square)

The project implements the **Sieve of Eratosthenes** algorithm using nine variants:
- **CUDA**
- **CUDA (odd-only)**
- **CUDA (bool-to-char)**
- **OpenMP**
- **OpenMP (odd-only)**
- **OpenMP (bool-to-char)**
- **Sequential**
- **Sequential (odd-only)**
- **Sequential (bool-to-char)**

The goal is to compare the performance of these implementations in terms of execution time and scalability across CPU and GPU architectures.


# Results

 ![412](https://github.com/user-attachments/assets/7c8bc51f-ffb8-49da-bc9c-5e5ef638a964)
![3124125](https://github.com/user-attachments/assets/ee5daf87-cfa7-41dd-984e-56cd1ff8bca2)
![214212224](https://github.com/user-attachments/assets/624442a9-c9fb-400e-8f9f-49e447433436)

# Tested on : 

- AMD Ryzen 7 5800H @ 3.20 GHz
- Cores / Threads: 8 Cores, 16 Threads
- GPU: NVIDIA GeForce RTX 3050 Ti Laptop GPU (4GB GDDR6)
- CUDA Cores: 2560
- Architecture: Ampere (GA107)

## Parallelization

### Why Parallelize?

The Sieve of Eratosthenes is inherently a good candidate for parallelization because the task of marking multiples of prime numbers can be distributed across multiple threads or CUDA cores. However, care must be taken in choosing **what part** of the algorithm to parallelize.

### Why the Inner Loop, Not the Outer?

In this implementation, only the **inner loop** was parallelized. The **outer loop** iterates over potential prime numbers `i`, and its correctness depends on whether `primes[i]` is still marked as true. If multiple threads were allowed to execute the outer loop in parallel, they might **read or write `primes[i]` simultaneously**, causing **race conditions** and invalidating the sieve.

Instead, by keeping the outer loop sequential and parallelizing the **inner loop that marks the multiples of `i`**, we ensure thread-safe behavior. Once `i` is known to be prime, each multiple of `i` (`i*i`, `i*i+2i`, `i*i+4i`, ...) can be marked independently. This results in **safe, data-parallel execution**.

###  How It Scales

* **OpenMP:** Each thread handles a chunk of the inner loop range with no overlap.
* **CUDA:** Each thread in a CUDA block marks one or more multiples, avoiding conflicts via index arithmetic.
* This approach scales well and is **efficient, correct, and portable** across CPUs and GPUs.

---

## Optimization

### 1. Odd-Only Sieve

The **odd-only optimization** eliminates all even numbers from the sieve (except `2`). Since all even numbers greater than `2` are known to be composite, there's no need to store or process them. Instead of maintaining an array for all integers, the sieve tracks only odd values:

* Original index: `i → i`
* Optimized index: `i → 2*i + 3`

This **reduces memory usage by nearly 50%** and also cuts the number of inner-loop iterations in half. It’s particularly effective for **high values of `n`**, significantly speeding up runtime and reducing cache misses.

### 2. Replacing `vector<bool>` with `vector<char>`

While `vector<bool>` might seem like an efficient choice, in C++ it's a **bit-packed structure**, not a true container of `bool`s. Each element isn't a separate byte—it’s a **bit**, and accessing it requires proxy logic (bit masking, shifting, etc.).

In **parallel environments**, this causes:

* Overhead per access
* Potential thread contention (especially in CUDA/global memory)
* Poor cache behavior due to false sharing (multiple bits in one byte)

Replacing `vector<bool>` with `vector<char>` or `uint8_t` solves all of these:

* Each element is **one byte**, accessible directly
* No proxies, no masking
* Greatly improved **thread safety** and **data locality**
* Slightly higher memory use, but drastically better **performance** and **scalability**


# How to run

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


This project also includes performance benchmarks to compare the execution times of each implementation. You can find the results in the `results/benchmark.txt` directory or in `benchmark_final.txt`.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.


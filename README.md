
![C++](https://img.shields.io/badge/C%2B%2B-17-blue?style=flat-square)
![OpenMP](https://img.shields.io/badge/OpenMP-4.5-5e9c40?style=flat-square)
![CUDA](https://img.shields.io/badge/CUDA-12.8-76b900?style=flat-square)

The project implements the **Sieve of Eratosthenes** algorithm using six variants:
- **Sequential**
- **Sequential (odd-only)**
- **OpenMP**
- **OpenMP (odd-only)**
- **CUDA**
- **CUDA (odd-only)**

The goal is to compare the performance of these implementations in terms of execution time and scalability across CPU and GPU architectures.


# Results

![412](https://github.com/user-attachments/assets/faf48922-8654-4b03-8ccc-2f39d872e373)
![3124125](https://github.com/user-attachments/assets/ee5daf87-cfa7-41dd-984e-56cd1ff8bca2)
![214212224](https://github.com/user-attachments/assets/624442a9-c9fb-400e-8f9f-49e447433436)

# Tested on : 

- AMD Ryzen 7 5800H @ 3.20 GHz
- Cores / Threads: 8 Cores, 16 Threads
- GPU: NVIDIA GeForce RTX 3050 Ti Laptop GPU (4GB GDDR6)
- CUDA Cores: 2560
- Architecture: Ampere (GA107)


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


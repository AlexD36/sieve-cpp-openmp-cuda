#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>
#include <cuda_runtime.h>

using namespace std;

// CUDA kernel: Each thread processes one odd number i starting from 3 to sqrt(n)
__global__ void sieve_kernel(bool* primes, int n, int sqrt_n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int i = 2 * tid + 3;  // Map thread index to odd number (3, 5, 7, ...)

    if (i > sqrt_n || !primes[i >> 1]) return;

    // Start marking from i*i and mark every 2*i (since only odd numbers are stored)
    for (int j = i * i; j <= n; j += 2 * i) {
        primes[j >> 1] = false;
    }
}

// Optimized GPU Sieve of Eratosthenes using odd numbers and unified memory
void sieve_cuda_optimized(int n) {
    int size = (n >> 1) + 1;  // Only odds: 0 maps to 1, 1 to 3, ...
    bool* primes;

    // Allocate unified memory accessible by host and device
    cudaMallocManaged(&primes, size * sizeof(bool));

    // Initialize all to true
    for (int i = 0; i < size; ++i)
        primes[i] = true;

    int sqrt_n = static_cast<int>(sqrt(n));
    int threads = 512;
    int blocks = (sqrt_n / 2 + threads - 1) / threads;

    // Launch kernel
    sieve_kernel << <blocks, threads >> > (primes, n, sqrt_n);
    cudaDeviceSynchronize();

    // (Optional) Print primes up to n
    /*
    cout << "2 ";
    for (int i = 1; i < size; ++i) {
        if (primes[i])
            cout << (2 * i + 1) << " ";
    }
    cout << endl;
    */

    // Cleanup
    cudaFree(primes);
}

int main() {
    vector<int> values = { 10000000, 100000000, 1000000000 };

    ofstream results_file("results/benchmark_cuda.txt", ios::app);

    results_file << "Benchmark Results for Optimized Sieve of Eratosthenes (CUDA version, odd numbers only)\n";
    results_file << "=====================================================================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "-------------------------------------------------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        sieve_cuda_optimized(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";
    }

    results_file.close();

    cout << "Benchmark results saved to 'results/benchmark_cuda.txt'" << endl;

    return 0;
}

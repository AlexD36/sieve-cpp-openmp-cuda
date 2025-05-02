#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>

using namespace std;

// CUDA kernel to mark non-prime multiples of a given odd prime i
__global__ void mark_multiples(bool* primes, int n, int i) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int start = i * i + idx * 2 * i;

    if (start <= n && start >= 0 && (start & 1)) { // only mark odd multiples
        primes[start >> 1] = false; // map odd number to index: number = 2*i + 1 → index = i
    }
}

// Host function to run the Sieve of Eratosthenes on the GPU (only odds)
void sieve_cuda(int n) {
    int size = (n >> 1) + 1; // Only odd numbers, 0 maps to 1, 1 maps to 3, ...
    bool* host_primes = new bool[size];
    bool* device_primes;

    // Initialize all as true (only odd numbers), 2 is special
    host_primes[0] = true; // represents number 1 (non-prime, but we'll ignore it)
    for (int i = 1; i < size; ++i) {
        host_primes[i] = true; // i maps to number 2*i + 1
    }

    cudaMalloc(&device_primes, size * sizeof(bool));
    cudaMemcpy(device_primes, host_primes, size * sizeof(bool), cudaMemcpyHostToDevice);

    int sqrt_n = static_cast<int>(sqrt(n));

    for (int i = 3; i <= sqrt_n; i += 2) {
        if (host_primes[i >> 1]) {
            int count = ((n - i * i) / (2 * i)) + 1;
            int blockSize = 256;
            int numBlocks = (count + blockSize - 1) / blockSize;

            mark_multiples << <numBlocks, blockSize >> > (device_primes, n, i);
            cudaDeviceSynchronize();
        }
    }

    cudaMemcpy(host_primes, device_primes, size * sizeof(bool), cudaMemcpyDeviceToHost);

    // Cleanup
    cudaFree(device_primes);
    delete[] host_primes;
}

int main() {
    // Values of n for which to benchmark the algorithm
    vector<int> values = { 10000000 , 100000000 , 1000000000 };

    // Open the file to save benchmark results
    ofstream results_file("results/benchmark_cuda.txt", ios::app);

    // Write header to the benchmark file
    results_file << "Benchmark Results for Sieve of Eratosthenes (CUDA version, odd numbers only)\n";
    results_file << "==============================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------\n";

    // Run and time the sieve for each value of n
    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        sieve_cuda(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        // Print execution time to console
        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;

        // Save execution time to file
        results_file << n << "\t" << duration.count() << "\n";
    }

    // Close the results file
    results_file.close();

    cout << "Benchmark results saved to 'results/benchmark_cuda.txt'" << endl;

    return 0;
}
#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>

using namespace std;

// CUDA kernel to mark non-prime multiples of a given prime i
__global__ void mark_multiples(bool* primes, int n, int i) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int start = i * i + idx * 2 * i;

    if (start <= n && start >= 0) {
        primes[start] = false;
    }
}

// Host function to run the Sieve of Eratosthenes on the GPU
void sieve_cuda(int n) {
    bool* host_primes = new bool[n + 1];
    bool* device_primes;

    // Initialize all numbers as prime (true), except 0 and 1
    for (int i = 0; i <= n; i++) host_primes[i] = true;
    host_primes[0] = host_primes[1] = false;

    // Allocate memory on the GPU
    cudaMalloc(&device_primes, (n + 1) * sizeof(bool));
    cudaMemcpy(device_primes, host_primes, (n + 1) * sizeof(bool), cudaMemcpyHostToDevice);

    int sqrt_n = static_cast<int>(sqrt(n));

    // Loop through all potential prime numbers up to sqrt(n)
    for (int i = 2; i <= sqrt_n; ++i) {
        // Only proceed if i is marked as prime
        if (host_primes[i]) {
            int count = ((n - i * i) / (2 * i)) + 1;
            int blockSize = 256;
            int numBlocks = (count + blockSize - 1) / blockSize;

            // Launch the CUDA kernel to mark non-prime multiples of i
            mark_multiples << <numBlocks, blockSize >> > (device_primes, n, i);
            cudaDeviceSynchronize(); // Ensure the kernel completes before moving on
        }
    }

    // Copy the result back to host
    cudaMemcpy(host_primes, device_primes, (n + 1) * sizeof(bool), cudaMemcpyDeviceToHost);

    // Cleanup GPU and CPU memory
    cudaFree(device_primes);
    delete[] host_primes;
}

int main() {
    // Values of n for which to benchmark the algorithm
    vector<int> values = { 10000000 , 100000000 , 1000000000 };

    // Open the file to save benchmark results
    ofstream results_file("results/benchmark_cuda.txt", ios::app);

    // Write header to the benchmark file
    results_file << "Benchmark Results for Sieve of Eratosthenes (CUDA version)\n";
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

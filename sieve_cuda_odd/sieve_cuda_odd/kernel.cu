#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>

using namespace std;

// CUDA kernel to mark non-prime multiples of a given odd prime i
__global__ void mark_multiples(char* primes, int n, int i) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int start = i * i + idx * 2 * i;

    if (start <= n && start >= 0 && (start & 1)) {
        primes[start >> 1] = 0; // mark as non-prime
    }
}

// Host function to run the Sieve of Eratosthenes on the GPU (only odds)
void sieve_cuda(int n) {
    int size = (n >> 1) + 1; // only odds (1, 3, 5, ..., n)
    char* host_primes = new char[size];
    char* device_primes;

    // Initialize all as prime (1), index 0 represents 1 (non-prime, ignored)
    host_primes[0] = 1;
    for (int i = 1; i < size; ++i) {
        host_primes[i] = 1;
    }

    cudaMalloc(&device_primes, size * sizeof(char));
    cudaMemcpy(device_primes, host_primes, size * sizeof(char), cudaMemcpyHostToDevice);

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

    cudaMemcpy(host_primes, device_primes, size * sizeof(char), cudaMemcpyDeviceToHost);

    // Cleanup
    cudaFree(device_primes);
    delete[] host_primes;
}

int main() {
    vector<int> values = { 10000000 , 100000000 , 1000000000 };

    ofstream results_file("results/benchmark_cuda.txt", ios::app);
    results_file << "Benchmark Results for Sieve of Eratosthenes (CUDA version, odd numbers only)\n";
    results_file << "==============================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        sieve_cuda(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";
    }

    results_file.close();
    cout << "Benchmark results saved to 'results/benchmark_cuda.txt'" << endl;

    return 0;
}

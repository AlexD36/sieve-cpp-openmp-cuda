#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>

using namespace std;

// CUDA kernel to mark non-prime multiples of a given odd prime i
__global__ void mark_multiples(unsigned char* primes, int n, int i) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int start = i * i + idx * 2 * i;

    if (start <= n && start >= 0 && (start & 1)) {
        primes[start >> 1] = 0;  // Mark as non-prime (0)
    }
}

// Host function to run the Sieve of Eratosthenes on the GPU (odd-only)
vector<unsigned char> sieve_cuda(int n) {
    int size = (n >> 1) + 1;
    vector<unsigned char> host_primes(size, 1); // Initialize all odd positions as prime (1)

    // Ignore position 0 (represents number 1, not prime)
    host_primes[0] = 0;

    unsigned char* device_primes;
    cudaMalloc(&device_primes, size * sizeof(unsigned char));
    cudaMemcpy(device_primes, host_primes.data(), size * sizeof(unsigned char), cudaMemcpyHostToDevice);

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

    cudaMemcpy(host_primes.data(), device_primes, size * sizeof(unsigned char), cudaMemcpyDeviceToHost);
    cudaFree(device_primes);

    return host_primes;
}

// Afiseaza toate numerele prime reprezentate in vectorul odd-only
void print_primes(const vector<unsigned char>& primes, int n) {
    cout << "Numere prime pana la " << n << ":\n";
    cout << 2 << " ";  // Include 2 manual

    for (int i = 1; (2 * i + 1) <= n; ++i) {
        if (primes[i]) {
            cout << (2 * i + 1) << " ";
        }
    }
    cout << "\n" << endl;
}

int main() {
    vector<int> values = { 10000000 , 100000000 , 1000000000 };

    ofstream results_file("results/benchmark_cuda.txt", ios::app);
    results_file << "Benchmark Results for Sieve of Eratosthenes (CUDA version, odd numbers only, with char)\n";
    results_file << "=====================================================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "---------------------------------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        vector<unsigned char> primes = sieve_cuda(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";

        //print_primes(primes, n);  // Afisare numerelor prime
    }

    results_file.close();
    cout << "Benchmark results saved to 'results/benchmark_cuda.txt'" << endl;

    return 0;
}

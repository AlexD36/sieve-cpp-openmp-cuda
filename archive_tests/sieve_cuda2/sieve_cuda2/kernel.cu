#include <iostream>
#include <cmath>
#include <vector>
#include <chrono>
#include <fstream>
#include <cuda_runtime.h>

using namespace std;

#define GET_BIT(array, index) ((array[(index) >> 3] >> ((index) & 7)) & 1)
#define CLEAR_BIT(array, index) (array[(index) >> 3] &= ~(1 << ((index) & 7)))

// CUDA kernel pentru marcare multipli folosind bit-packing
__global__ void sieve_bitpacked(uint8_t* bit_array, int n, int sqrt_n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    int i = 2 * tid + 3; // doar impari

    if (i > sqrt_n) return;

    int idx = (i - 3) >> 1;  // indexul în array pentru i
    if (!GET_BIT(bit_array, idx)) return;

    for (int j = i * i; j <= n; j += 2 * i) {
        int j_idx = (j - 3) >> 1;
        CLEAR_BIT(bit_array, j_idx);
    }
}

// Funcție host care gestionează bit-array-ul și lansează kernelul
void sieve_cuda_bitpacked(int n) {
    int bit_count = (n - 1) / 2;  // doar imparii > 2
    int byte_count = (bit_count + 7) / 8;

    uint8_t* bit_array;
    cudaMallocManaged(&bit_array, byte_count);
    cudaMemset(bit_array, 0xFF, byte_count); // Setează totul pe 1 (true)

    int sqrt_n = static_cast<int>(sqrt(n));
    int threads = 512;
    int blocks = ((sqrt_n / 2) + threads - 1) / threads;

    sieve_bitpacked << <blocks, threads >> > (bit_array, n, sqrt_n);
    cudaDeviceSynchronize();

    // Exemplu: afisează primele 20 de numere prime
    /*
    cout << "2 ";
    int printed = 1;
    for (int i = 0; i < bit_count && printed < 20; ++i) {
        if (GET_BIT(bit_array, i)) {
            cout << (2 * i + 3) << " ";
            printed++;
        }
    }
    cout << endl;
    */

    cudaFree(bit_array);
}

int main() {
    vector<int> values = { 10000000, 100000000, 1000000000 };

    ofstream results_file("results/benchmark_cuda_bitpacked.txt", ios::app);
    results_file << "Benchmark Results for Bitpacked CUDA Sieve of Eratosthenes\n";
    results_file << "==========================================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        sieve_cuda_bitpacked(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";
    }

    results_file.close();
    cout << "Benchmark saved in 'results/benchmark_cuda_bitpacked.txt'\n";

    return 0;
}

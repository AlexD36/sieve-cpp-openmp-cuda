#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
#include <fstream>
#include <cstdlib> // for system()
#include <omp.h>

using namespace std;

// Function to find prime numbers up to n using the Sieve of Eratosthenes (OpenMP version)
void sieve_openmp(int n) {
    // Boolean vector to mark prime numbers
    vector<bool> primes(n + 1, true);
    primes[0] = primes[1] = false;

    int sqrt_n = static_cast<int>(sqrt(n));

    // Mark 2 as prime, as we will skip even numbers later
    if (n >= 2) primes[2] = true;

    // Parallelize the outer loop
#pragma omp parallel for schedule(dynamic)
    for (int i = 3; i <= sqrt_n; i += 2) {
        if (primes[i]) {
            // Removed inner loop paralelization
            for (int j = i * i; j <= n; j += 2 * i) {
                primes[j] = false;
            }
        }
    }
}

int main() {
    // List of values for which we want to benchmark the Sieve of Eratosthenes
    vector<int> values = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };

    //Setting the number of threads !(may differ on your machine)
    omp_set_num_threads(16);

    // Open the file to save benchmark results
    ofstream results_file("results/benchmark.txt", ios::app);

    // Write the header in the results file
    results_file << "Benchmark Results for Sieve of Eratosthenes (OpenMP version)\n";
    results_file << "==============================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------\n";

    // Measure execution time for each value of n
    for (int n : values) {
        // Measure the execution time
        auto start = chrono::high_resolution_clock::now();

        // Call the OpenMP version of the Sieve of Eratosthenes
        sieve_openmp(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        // Display the execution time for the user
        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;

        // Save the results to the file
        results_file << n << "\t" << duration.count() << "\n";
    }

    // Close the results file
    results_file.close();

    cout << "Benchmark results saved to 'results/benchmark.txt'" << endl;

    return 0;
}

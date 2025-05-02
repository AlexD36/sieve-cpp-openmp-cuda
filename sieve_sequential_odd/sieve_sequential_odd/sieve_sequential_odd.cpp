#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
#include <fstream>
#include <cstdlib> // for system()
#include <filesystem> // C++17

using namespace std;

// Function to find prime numbers up to n using the Sieve of Eratosthenes (optimized for odd numbers)
void sieve_sequential(int n) {
    // Boolean vector to mark prime numbers
    vector<bool> primes(n + 1, false);
    if (n >= 2) primes[2] = true; // 2 is the only even prime

    // Mark all odd numbers as true (potential primes)
    for (int i = 3; i <= n; i += 2) {
        primes[i] = true;
    }

    // Sieve of Eratosthenes algorithm, skipping even numbers
    int limit = static_cast<int>(sqrt(n));
    for (int i = 3; i <= limit; i += 2) {
        if (primes[i]) {
            // Mark only odd multiples of i as non-prime
            for (int j = i * i; j <= n; j += 2 * i) {
                primes[j] = false;
            }
        }
    }

    // Optional: Print primes
    /*
    cout << "Prime numbers up to " << n << ": ";
    for (int i = 2; i <= n; i++) {
        if (primes[i]) {
            cout << i << " ";
        }
    }
    cout << endl;
    */
}


int main() {
    // List of values for which we want to benchmark the Sieve of Eratosthenes
    vector<int> values = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };


    // Open the file to save benchmark results (append mode)
    ofstream results_file("results/benchmark.txt", ios::app);

    // Write header for the benchmark results file
    results_file << "Benchmark Results for Sieve of Eratosthenes (Sequential version)\n";
    results_file << "==============================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------\n";

    // Measure execution time for each value of n
    for (int n : values) {
        // Measure the execution time
        auto start = chrono::high_resolution_clock::now();

        // Call the sequential Sieve of Eratosthenes function
        sieve_sequential(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        // Display the execution time for the user
        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;

        // Save the results to the benchmark file
        results_file << n << "\t" << duration.count() << "\n";
    }

    // Close the benchmark file
    results_file.close();

    cout << "Benchmark results saved to 'results/benchmark.txt'" << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
#include <fstream>
#include <cstdlib>
#include <filesystem>

using namespace std;

// Functie care returneaza vectorul cu marcajele primalitatii
vector<char> sieve_sequential(int n) {
    vector<char> primes(n + 1, 0);
    if (n >= 2) primes[2] = 1;  // 2 este prim

    for (int i = 3; i <= n; i += 2) {
        primes[i] = 1;  // initial presupunem ca toate imparele sunt prime
    }

    int limit = static_cast<int>(sqrt(n));
    for (int i = 3; i <= limit; i += 2) {
        if (primes[i]) {
            for (int j = i * i; j <= n; j += 2 * i) {
                primes[j] = 0;
            }
        }
    }

    return primes;
}

// Afiseaza toate numerele prime pana la n
void print_primes(const vector<char>& primes, int n) {
    cout << "Numere prime pana la " << n << ":\n";
    for (int i = 2; i <= n; ++i) {
        if (primes[i]) {
            cout << i << " ";
        }
    }
    cout << "\n" << endl;
}

int main() {
    vector<int> values = { 10000000, 100000000, 1000000000 };

    ofstream results_file("results/benchmark.txt", ios::app);
    results_file << "Benchmark Results for Sieve of Eratosthenes (Sequential odd-only version with char)\n";
    results_file << "==============================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "----------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        vector<char> primes = sieve_sequential(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";

        // Afiseaza toate numerele prime
        //print_primes(primes, n);
    }

    results_file.close();
    cout << "Benchmark results saved to 'results/benchmark.txt'" << endl;

    return 0;
}

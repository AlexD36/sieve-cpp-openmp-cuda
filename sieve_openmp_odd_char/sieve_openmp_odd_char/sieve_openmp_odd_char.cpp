#include <iostream>
#include <vector>
#include <cmath>
#include <chrono>
#include <fstream>
#include <omp.h>

using namespace std;

// Functie care executa sieve folosind doar numere impare si paralelizare cu OpenMP
vector<char> sieve_openmp_odd(int n) {
    int size = (n - 1) / 2;  // Reprezinta doar numerele impare: 3, 5, 7, ...
    vector<char> primes(size, 1); // primes[i] corespunde numarului (2*i + 3)

    int sqrt_n = static_cast<int>(sqrt(n));

    for (int i = 0; (2 * i + 3) <= sqrt_n; ++i) {
        if (primes[i]) {
            int p = 2 * i + 3;
            int start = (p * p - 3) / 2;

#pragma omp parallel for schedule(dynamic)
            for (int j = start; j < size; j += p) {
                primes[j] = 0;
            }
        }
    }

    return primes;
}

// Afiseaza toate numerele prime, inclusiv 2, din vectorul odd-only
void print_primes(const vector<char>& primes, int n) {
    cout << "Numere prime pana la " << n << ":\n";
    cout << 2 << " "; // 2 este singurul prim par

    for (int i = 0; i < primes.size(); ++i) {
        if (primes[i]) {
            cout << (2 * i + 3) << " ";
        }
    }
    cout << "\n" << endl;
}

int main() {
    vector<int> values = { 10000000, 100000000, 1000000000 };
    omp_set_num_threads(16);

    ofstream results_file("results/benchmark_openmp_odd.txt", ios::app);
    results_file << "Benchmark Results for Sieve of Eratosthenes (OpenMP odd-only version)\n";
    results_file << "==============================================================\n";
    results_file << "n\tExecution Time (seconds)\n";
    results_file << "--------------------------------------------------------------\n";

    for (int n : values) {
        auto start = chrono::high_resolution_clock::now();

        vector<char> primes = sieve_openmp_odd(n);

        auto end = chrono::high_resolution_clock::now();
        chrono::duration<double> duration = end - start;

        cout << "n = " << n << " , Execution time: " << duration.count() << " seconds." << endl;
        results_file << n << "\t" << duration.count() << "\n";

        // Afisam toate numerele prime pentru acest n
       // print_primes(primes, n);
    }

    results_file.close();
    cout << "Benchmark results saved to 'results/benchmark_openmp_odd.txt'" << endl;

    return 0;
}

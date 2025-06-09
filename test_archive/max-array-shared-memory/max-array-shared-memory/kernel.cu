#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <stdio.h>
#include <climits>

using namespace std;

__global__ void findMax(int* input, int* block_max, int N) {
    __shared__ int shared_mem[128];
    int global_idx = blockIdx.x * blockDim.x + threadIdx.x;
    int thread_id = threadIdx.x;

    if (global_idx < N) {
        shared_mem[thread_id] = input[global_idx];
    }
    else {
        shared_mem[thread_id] = INT_MIN;
    }

    __syncthreads();

    for (int pos = blockDim.x >> 1; pos > 0; pos >>= 1) {
        if (thread_id < pos) {
            if (shared_mem[thread_id] < shared_mem[thread_id + pos]) {
                shared_mem[thread_id] = shared_mem[thread_id + pos];
            }
        }
        __syncthreads();
    }

    if (thread_id == 0) {
        block_max[blockIdx.x] = shared_mem[0];
    }
}

int main() {
    int N;
    cout << "Introduceti dimensiunea vectorului: ";
    cin >> N;

    int* array_host = new int[N];
    int result_host = 0;

    for (int i = 0; i < N; i++) {
        array_host[i] = rand() % 1000;
        cout << array_host[i] << " ";
    }
    cout << endl;

    int* array_device;
    int* partial_max;
    int* result_device;

    cudaMalloc((void**)&array_device, N * sizeof(int));

    int num_blocks = (N + 127) / 128;
    cudaMalloc((void**)&partial_max, num_blocks * sizeof(int));
    cudaMalloc((void**)&result_device, sizeof(int));

    cudaMemcpy(array_device, array_host, N * sizeof(int), cudaMemcpyHostToDevice);

    dim3 block_size(128);
    dim3 grid_size(num_blocks);

    // Prima etapa: reducere in blocuri
    findMax << <grid_size, block_size >> > (array_device, partial_max, N);

    // A doua etapa: reducere finala pe maximele partiale
    findMax << <1, 128 >> > (partial_max, result_device, num_blocks);

    cudaMemcpy(&result_host, result_device, sizeof(int), cudaMemcpyDeviceToHost);

    cout << "Maximul este: " << result_host << endl;

    cudaFree(array_device);
    cudaFree(partial_max);
    cudaFree(result_device);
    delete[] array_host;

    return 0;
}

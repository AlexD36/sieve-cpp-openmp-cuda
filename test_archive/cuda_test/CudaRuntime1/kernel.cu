#include <iostream>
#include <cmath>
#include <cuda_runtime.h>
#include <cstdlib>
#include <ctime>
#include <fstream>

using namespace std;

const int N = 1000;
const int M = 1000;

__global__ void meanFilter(float* input, float* output, int width, int height) {
    int i = blockIdx.y * blockDim.y + threadIdx.y;
    int j = blockIdx.x * blockDim.x + threadIdx.x;

    if (i > 0 && i < height - 1 && j > 0 && j < width - 1) {
        float sum = 0.0f;

        for (int i_prim = i - 1; i_prim <= i + 1; i_prim++) {
            for (int j_prim = j - 1; j_prim <= j + 1; j_prim++) {
                sum += input[i_prim * width + j_prim];
            }
        }

        output[i * width + j] = sum / 9.0f;
    }
    else if (i < height && j < width) {
        output[i * width + j] = input[i * width + j];
    }
}

void generateImage(float* image, int width, int height) {
    srand(time(NULL));
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
            // Generăm o imagine cu valori aleatorii între 0 și 1
            image[i * width + j] = static_cast<float>(rand()) / RAND_MAX;
        }
    }
}

void saveImagePGM(const char* filename, float* image, int width, int height) {
    std::ofstream file(filename, std::ios::binary);
    if (!file) {
        std::cerr << "Nu s-a putut deschide fișierul pentru scriere\n";
        return;
    }

    file << "P5\n" << width << " " << height << "\n255\n";

    unsigned char* buffer = new unsigned char[width * height];
    for (int i = 0; i < width * height; i++) {
        buffer[i] = static_cast<unsigned char>(image[i] * 255.0f);
    }

    file.write(reinterpret_cast<char*>(buffer), width * height);
    file.close();
    delete[] buffer;
}

int main() {

    float* h_input, * h_output;
    h_input = new float[N * M];
    h_output = new float[N * M];


    generateImage(h_input, M, N);


    float* d_input, * d_output;
    cudaMalloc((void**)&d_input, N * M * sizeof(float));
    cudaMalloc((void**)&d_output, N * M * sizeof(float));


    cudaMemcpy(d_input, h_input, N * M * sizeof(float), cudaMemcpyHostToDevice);


    dim3 blockSize(16, 32);
    dim3 gridSize((M + blockSize.x - 1) / blockSize.x, (N + blockSize.y - 1) / blockSize.y);


    meanFilter << < gridSize, blockSize >> > (d_input, d_output, M, N);


    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        std::cout << "CUDA Error: " << cudaGetErrorString(error) << std::endl;
    }

    cudaMemcpy(h_output, d_output, N * M * sizeof(float), cudaMemcpyDeviceToHost);

    saveImagePGM("imagine_originala.jpg", h_input, M, N);
    saveImagePGM("imagine_filtrata.jpg", h_output, M, N);

    std::cout << "Filtrare completă. Imaginile au fost salvate." << std::endl;

    delete[] h_input;
    delete[] h_output;
    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
}
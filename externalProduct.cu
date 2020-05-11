#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define N 3
#define M 3

//Data: a and b inputs, output: c.
int matrixA[N][M], matrixB[N][M], matrixC[N*N][M*M];

//Runs in GPU cores.
__global__ void tensorProduct(int n, int m, int *matrixA, int *matrixB, int *result)
{
  int i = threadIdx.x;
  int j = threadIdx.y;  

  //Perform tensor product.
  for (int k = 0; k < n; k++){
    for (int l = 0; l < m; l++){
      result[(j * m + l) + (i * n + k) * m * m] = matrixA[i*m+j] * matrixB[k*m+l];
    }
  }
}

void tensorProductDevice(int n, int m, int *a, int *b, int *c){

  //Parameters.
  int *aD, *bD, *cD;
  int matrixSize = n * m * sizeof(int);
  int resultSize = n * n * m * m * sizeof(int);

  dim3 blocks(1,1);
  dim3 threads(n,m);

  //1. Assign memory
  cudaMalloc(&aD, matrixSize);
  cudaMalloc(&bD, matrixSize);
  cudaMalloc(&cD, resultSize);

  //2. Set device 0, copy the information to device.
  cudaSetDevice(0);
  cudaMemcpy(aD, a, matrixSize, cudaMemcpyHostToDevice);
  cudaMemcpy(bD, b, matrixSize, cudaMemcpyHostToDevice);

  //Execute kernel.
  tensorProduct<<<blocks, threads>>>(n, m, aD, bD, cD);
  
  //Copy data from device back to host.
  cudaMemcpy(c, cD, resultSize, cudaMemcpyDeviceToHost);
  
  //Free memory.
  cudaFree(aD);
  cudaFree(bD);
  cudaFree(cD);

}

int main(){

  srand(time(NULL));

  //Fill the matrices.
  for(int i = 0; i < N; i++){
    for (int j = 0; j < M; j++){
      matrixA[i][j] = 1 + rand() % 5;
      matrixB[i][j] = 1 + rand() % 5;
    }
  }

  //Call to perform tensor operation.
  tensorProductDevice(N, M, (int *) matrixA, (int *) matrixB, (int *) matrixC);
  
  
  printf("Elements of A:\n");
  for (int i = 0; i < N; i++){
    for (int j = 0; j < M; j++){
      printf("%d\t", matrixA[i][j]);
    }
    printf("\n");
  }
  printf("\n");

  printf("Elements of B:\n");
  for (int i = 0; i < N; i++){
    for (int j = 0; j < M; j++){
      printf("%d\t", matrixB[i][j]);
    }
    printf("\n");
  }
  printf("\n");

  printf("Result:\n");
  for (int i = 0; i < N * N; i++){
    for (int j = 0; j < M * M; j++){
      printf("%d\t", matrixC[i][j]);
    }
    printf("\n");
  }
  printf("\n");
}
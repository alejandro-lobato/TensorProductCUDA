#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define N 2
#define M 3

int a[N][M], b[N][M], c[N*N][M*M];

__global__ void tensorProduct(int rB, int cB, int *a, int *b, int *result)
{
  int i = threadIdx.x;
  int j = threadIdx.y;  


  //Se queda.
  for (int k = 0; k < rB; k++)
  {
    for (int l = 0; l < cB; l++)
    {
      result[(i * rB + k) * cB * cB + (j * cB + l)] = a[i*cB+j] * b[k*cB+l];
    }
  }
}

void printMatrix(int matrix[N][M])
{
  for (int i = 0; i < N; i++)
  {
    for (int j = 0; j < M; j++)
    {
      printf("%d\t", matrix[i][j]);
    }
    printf("\n");
  }
}

void initMatrix(int matrix[N][M])
{
  for (int i = 0; i < N; i++)
  {
    for (int j = 0; j < M; j++)
    {
      matrix[i][j] = rand() % 5;
    }
  }
}

void tensorProductDevice(int rB, int cB, int *a, int *b, int *c){
  int *aD, *bD, *cD;
  int size = rB * cB * sizeof(int);
  int sizeRes = rB * rB * cB * cB * sizeof(int);

  dim3 bloques(1,1);
  dim3 hilos(N,M);

  cudaMalloc(&aD, size);
  cudaMalloc(&bD, size);
  cudaMalloc(&cD, sizeRes);

  cudaSetDevice(0);
  cudaMemcpy(aD, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(bD, b, size, cudaMemcpyHostToDevice);

  tensorProduct<<<bloques , hilos>>>(rB, cB, aD, bD, cD);
  
  cudaMemcpy(c, cD, sizeRes, cudaMemcpyDeviceToHost);
  
  cudaFree(aD);
  cudaFree(bD);
  cudaFree(cD);

}

int main()
{
  //int rA = 2;
  //int cA = 2;
  //int cB = 2;
  //int rB = 3;
  //int rR = rA * rB;
  //int cR = cA * cB;

  srand(time(NULL));
  initMatrix(a);
  initMatrix(b);

  tensorProductDevice(N, M, (int *) a, (int *) b, (int *) c);

  printf("Matrix A:\n");
  printMatrix(a);

  printf("Matrix B:\n");
  printMatrix(b);

  printf("Result: R:\n");
  for (int i = 0; i < N * N; i++)
  {
    for (int j = 0; j < M * M; j++)
    {
      printf("%d\t", c[i][j]);
    }
    printf("\n");
  }
  
  free(a);
  free(b);
  free(c);
}
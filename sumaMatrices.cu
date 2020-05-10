#include <stdio.h>
#include <stdlib.h>

#define M 10
#define N 10

// __device__ double z[128][128];

double a[M][N], b[M][N], c[M][N];

//Hace toda la poop.
__global__ void kernelSumaMatrices(double *a, double *b, double *c, int m, int n)
{
int i = threadIdx.x;
int j = threadIdx.y;

//   a[i][j] = b[i][j] + b[i][j];
   a[i*n+j] = b[i*n+j] + c[i*n+j];
}

void sumaMatricesEnDevice(double *a, double *b, double *c, int m, int n) {
 double *aD, *bD, *cD;
 int size=m*n*sizeof(double);
 dim3 bloques(1,1);
 dim3 hilos(10,10);

// 1. Asignar memoria
  cudaMalloc(&aD, size);
  cudaMalloc(&bD, size);
  cudaMalloc(&cD, size);

  cudaSetDevice(0);
  cudaMalloc(&cD, size);

// 2. Copiar datos del Host al Device
   cudaMemcpy(bD, b, size, cudaMemcpyHostToDevice);
   cudaMemcpy(cD, c, size, cudaMemcpyHostToDevice);
//   cudaMemcpy(aD, a, size, cudaMemcpyDefault);
//   cudaMemcpy(bD, b, size, cudaMemcpyDefault);

   // 3. Ejecutar kernel
   kernelSumaMatrices<<<bloques , hilos>>>(aD, bD, cD, m, n);

// 4. Copiar datos del device al Host
  cudaMemcpy(a, aD, size, cudaMemcpyDeviceToHost);
  //cudaMemcpy(a, aD, size, cudaMemcpyDefault);

// 5. Liberar Memoria
cudaFree(aD); cudaFree(bD); cudaFree(cD);
}

int main() {
int i, j;

//   a=(double *)malloc(M*N*sizeof(double));
//   b=(double *)malloc(M*N*sizeof(double));
//   c=(double *)malloc(M*N*sizeof(double));

  for (i=0; i<M; i++) {
     for (j=0; j<N; j++) {
        b[i][j] = c[i][j] = i+j;
     }
  }

sumaMatricesEnDevice((double *)a, (double *)b, (double *)c, M, N);

  for (i=0; i<M; i++) {
     for (j=0; j<N; j++) {
        printf("%3.2f ", a[i][j]);
     }
     printf("\n");
  }

  free(a); free(b); free(c);
}


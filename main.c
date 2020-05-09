#include <stdlib.h>
#include <stdio.h>
#include <time.h>

// __global__
void tensorProduct(int rA, int cA, int rB, int cB, int cR, int a[][cA], int b[][cB], int result[][cR])
{
  int cont = 0;
  for (int i = 0; i < rA; i++)
  {
    for (int j = 0; j < cA; j++)
    {
      for (int k = 0; k < rB; k++)
      {
        for (int l = 0; l < cB; l++)
        {
          result[i * rB + k][j * cB + l] = a[i][j] * b[k][l];
          cont += 1;
        }
      }
    }
  }
}

void printMatrix(int row, int col, int matrix[row][col])
{
  for (int i = 0; i < row; i++)
  {
    for (int j = 0; j < col; j++)
    {
      printf("%d\t", matrix[i][j]);
    }
    printf("\n");
  }
}

void initMatrix(int row, int col, int matrix[row][col])
{
  for (int i = 0; i < row; i++)
  {
    for (int j = 0; j < col; j++)
    {
      matrix[i][j] = rand() % 10;
    }
  }
}

void main()
{
  int rA = 2;
  int cA = 2;
  int cB = 2;
  int rB = 3;
  int rR = rA * rB;
  int cR = cA * cB;

  int a[rA][cA];
  int b[rB][cB];
  int result[rR][cR];

  srand(time(NULL));
  initMatrix(rA, cA, a);
  initMatrix(rB, cB, b);

  tensorProduct(rA, cA, rB, cB, cR, a, b, result);

  printf("Matrix A: R: %d, C: %d\n", rA, cA);
  printMatrix(rA, cA, a);

  printf("Matrix B: R: %d, C: %d\n", rB, cB);
  printMatrix(rB, cB, b);

  printf("Result: R: %d, C: %d\n", rR, cR);
  printMatrix(rR, cR, result);
}
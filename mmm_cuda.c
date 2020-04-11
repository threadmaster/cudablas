#ifdef __cplusplus
extern "C" {
#endif
    void mmm_( int *len,  double *a, double *b, double*c );
#ifdef __cplusplus
    }
#endif

/* C U D A   B L A S   S E C T I O N  */

#include <stdlib.h>
#include <stdio.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>

void cudablas_mmm( cublasHandle_t handle, double *A, double *B, double *C, 
                   int DIM, double alpha, double beta){

    const double *d_alpha = &alpha;
    const double *d_beta = &beta;

    // Call the actual double precision matrix multiplication library function
    cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, DIM, DIM, DIM, d_alpha, A, DIM, B, DIM, d_beta, C, DIM);

}

void mmm_( int *len,  double *A, double *B, double *C ){

    int DIM = *len;
    double alpha = 1.0;
    double beta = 0.0;
    void *d_A, *d_B, *d_C;

    
    cudaError_t cudaStat;
    cudaError_t err;
    char *errorstring;

    // Create CUDA card device handles
    cublasHandle_t handle;
    cublasCreate(&handle);

    // Allocate memory on the card to store the matrices
    if ( (cudaStat = cudaMalloc(&d_A, DIM*DIM * sizeof(double))) != cudaSuccess ){
          errorstring = cudaGetErrorString(err);
          printf("Device memory allocation failed with err: %s.\n", errorstring);
          cudaFree(d_A);
          cudaDeviceReset();
          exit(1);
          }
    if ( (cudaStat = cudaMalloc(&d_B, DIM*DIM * sizeof(double))) != cudaSuccess ){
          errorstring = cudaGetErrorString(err);
          printf("Device memory allocation failed with err: %s.\n", errorstring);
          cudaFree(d_A);
          cudaFree(d_B);
          cudaDeviceReset();
          exit(1);
          }
    if ( (cudaStat = cudaMalloc(&d_C, DIM*DIM * sizeof(double))) != cudaSuccess ){
          errorstring = cudaGetErrorString(err);
          printf("Device memory allocation failed with err: %s.\n", errorstring);
          cudaFree(d_A);
          cudaFree(d_B);
          cudaFree(d_C);
          cudaDeviceReset();
          exit(1);
          }

    // Copy the matrices to the card remember first to arguments are always destination and then source.
    // The last argument determines the type of transfer - not the direction of transfer.
    cudaMemcpy(d_A, A, DIM*DIM* sizeof(double), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, DIM*DIM* sizeof(double), cudaMemcpyHostToDevice);

    // Call the matrix multiplication function that is GPU based
    cudablas_mmm(handle, d_A, d_B, d_C, DIM, alpha, beta);

    // Copy the matrix C back from the card to the host computer
    cudaMemcpy(C,d_C,DIM*DIM*sizeof(double),cudaMemcpyDeviceToHost);

    // Free the memory on the CUDA card
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // Free the memory used for the devince handle
    cublasDestroy(handle);

}




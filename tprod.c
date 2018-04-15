#ifdef __cplusplus
extern "C" {
#endif
    void tprod_(double *a, int *lena,
                  double *b, int *lenb,
                  double *c, int *lenc); 
#ifdef __cplusplus
    }
#endif

void tprod_( double *a, int *lena,
        double *b, int *lenb,
        double *c, int *lenc){

int i, j;

for (i = 0; i<*lena; i++) {
   for (j=0; j<*lenb; j++) {
      *(c+i* *lenc+j) = *(a+i) * *(b+j);
   }
}

//printf("Len C = %d\n", lenc);
}


 

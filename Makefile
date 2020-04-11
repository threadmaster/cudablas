# Makefile to Compile agains CUDABlas on Godsey Systems 
#
# Andrew J. Pounds, Ph.D.
# Departments of Chemistry and Computer Science
# Mercer University
# Spring 2020 
#

F95 = gfortran   
CC = gcc 
FFLAGS = -cpp -O2 -frepack-arrays -finline-functions  -Wall  
CFLAGS = -O3 -Wall -funsafe-math-optimizations 
COPTFLAGS = -ffast-math -fprefetch-loop-arrays -ftree-vectorize -ftree-vectorizer-verbose=7
OLDFORMAT = -fixed-form
LIBFLAG = 
GCCOPT = -param l2-cache-size=2048 
CUBLAS = /usr/local/cuda/lib64/libcublas.so /usr/local/cuda/lib64/libcudart.so

debug ?= n
ifeq ($(debug), y)
    CFLAGS += -g -DDEBUG
else
    CFLAGS += -O3 -mtune=native -march=native 
endif

#NOTE -- for Quadro P4000 use sm_61, for P100 use sm_60
NVCC = nvcc
NVCCFLAGS = -DCUBLAS -arch sm_61 -I/usr/local/cuda/include/
COPTFLAGS = -O3 
LIBFLAG = $(CUBLAS)  

OBJS = array.o walltime.o cputime.o tprod.o mmm_cuda.o  
       

all: driver 

driver : driver.o $(OBJS)    
	$(F95) -o driver driver.o $(OBJS) $(CUBLAS) 

driver.o : driver.f90 array.o   
	$(F95) $(FFLAGS) -c driver.f90  

array.o : array.f90
	$(F95) -c array.f90

mmm_cuda.o : mmm_cuda.c
	$(NVCC) $(NVCCFLAGS) $(COPTFLAGS) -c mmm_cuda.c

tprod.o : tprod.c
	$(CC) $(CFLAGS) -c tprod.c

# Timing Library targets 

walltime.o : walltime.c
	$(CC) $(CFLAGS) -c walltime.c

cputime.o : cputime.c
	$(CC) $(CFLAGS) -c cputime.c

lib: cputime.o walltime.o
	ar -rc liblbstime.a cputime.o walltime.o
	ranlib liblbstime.a

# Default Targets for Cleaning up the Environment
clean :
	rm *.o

pristine :
	rm *.o
	touch *.cc *.c *.f *.f90 
	rm *.mod

ctags :
	ctags *.f90


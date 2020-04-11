program adriver 

use array
integer :: N, iter

real (kind=8) :: wall_start, wall_end
real (kind=8) :: cpu_start, cpu_end
real (kind=8) :: trace, ONE, ZERO

integer :: startval, stopval, stepval
real (kind=8) :: walltime
real (kind=8) :: cputime 
real (kind=8) :: mflops, mflops2
external walltime, cputime

! Use these to read the command line arguments
! of startval, stopval, and stepval

character (len=8) :: carg1, carg2, carg3

call get_command_argument(1, carg1)
call get_command_argument(2, carg2)
call get_command_argument(3, carg3)

! Use Fortran internal files to convert command line arguments to ints

read (carg1,'(i8)') startval
read (carg2,'(i8)') stopval
read (carg3,'(i8)') stepval
 
do iter = startval, stopval, stepval
  

N = iter

ONE = 1.0D0
ZERO = 0.0D0

allocate ( veca(N), stat=ierr)
allocate ( vecb(N), stat=ierr)
allocate ( matrixa(N,N), stat=ierr)
allocate ( matrixb(N,N), stat=ierr)
allocate ( matrixc(N,N), stat=ierr)

do i = 1, N 
     veca(i) = 1.0
     vecb(i) = 1.0 / sqrt( dble(N))
enddo

!call zeromat( N );

call tprod(veca, N, vecb, N, matrixa, N);
call tprod(veca, N, vecb, N, matrixb, N);

wall_start = walltime()
cpu_start = cputime()

call mmm(N, matrixa, matrixa, matrixc);
!call dgemm('N','N',N,N,N,ONE,matrixa,N,matrixb,N,ZERO,matrixc,N)

cpu_end = cputime()
wall_end = walltime()

trace = 0.0;

do i=1, N 
     trace = trace + matrixc(i,i)
enddo

!print *,  "The trace is ", trace

mflops  = 2.0D0 * dble(N)**3 / (cpu_end-cpu_start) / 1.0D6
mflops2 = 2.0D0 * dble(N)**3 / (wall_end-wall_start)/ 1.0D6
 
print *, N, trace, cpu_end-cpu_start, wall_end-wall_start,  mflops, mflops2


!print *, " "
!print *, " Run took ", minutes, " minutes and ", seconds, &
!         " seconds of processor time."
!print *, " "
!print *, " "
!print *, " Run took ", w_minutes, " minutes and ", w_seconds, &
!         " seconds of wall clock time."
!print *, " "

if (allocated(matrixa) ) deallocate(matrixa)
if (allocated(matrixb) ) deallocate(matrixb)
if (allocated(matrixc) ) deallocate(matrixc)
if (allocated(veca)    ) deallocate(veca)
if (allocated(vecb)    ) deallocate(vecb)

enddo


end program adriver 
 

subroutine readoutput(outputf, Nlen, Nr)
! read seismogram time-series from QSSP output
!
! Input:
!      outputf: file name of output file of QSSP.
!      Nlen: length of time seires,
!      Nr: number of receivers/stations.
! Output:
!      no explicit output of this subrouine,
!      but the matirx 'seisdata' in module 'seismogram' is allocated and assigned here.
!
!
! Written by
! Shenjian Zhang <sjzhang@pku.edu.cn>
! 17 May 2020

use seismogram
implicit none

! declaration
character(len=80),intent(in) :: outputf    ! file name of output of QSSP
integer(kind=4),intent(in) :: Nlen, Nr     ! length of time series, number of stations
integer(kind=4) :: i            ! index
integer(kind=4) :: flag, ierr   ! function/subroutine status
real(kind=8) :: time            ! time axis when read outputs of QSSP

! allocate matrix for seismograms
allocate(seisdata(Nlen, Nr), stat=ierr)
if(ierr .ne. 0)stop ' Error in readoutput: seisdata not allocated. '
seisdata(:,:) = 0.0    ! single-precison

! read output file of QSSP
open(201, file=outputf, iostat=flag)
! skip first line for station names
read(201, *)
! Nlen rows for Nlen time sampling
! (Nr+1) columns for Nr stations and 1 time-axis
do i = 1, Nlen
    read(201, *)time, seisdata(i,:)
enddo

return
end subroutine

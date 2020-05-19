subroutine readinput(inputf, prefix, dt, Nlen, event, Nr)
! read information from input file for QSSP
!
! Input:
!      inutf: file name of input file for QSSP.
! Output:
!      prefix: prefix for output file of QSSP, set in section RECEIVER PARAMETERS,
!      dt: time sampling interval,
!      Nlen: length of the seimogram time series,
!      event: 3-element vector for event information as lat., lon., and depth,
!      Nr: number of receivers/stations.
!
!
! Written by
! Shenjian Zhang <sjzhang@pku.edu.cn>
! 17 May 2020

use station
implicit none

! declaration
! arguements
character(len=80),intent(in) :: inputf          ! input file name
character(len=80),intent(out) :: prefix         ! prefix for output file of QSSP
real(kind=8),intent(out) :: dt                  ! time sampling interval
integer(kind=4),intent(out) :: Nlen             ! length of time series
real(kind=8),dimension(3),intent(out) :: event  ! 1: latitude of event, 2: longitude, 3: depth
integer(kind=4),intent(out) :: Nr               ! number of receivers
! 'global' para,
integer(kind=4) :: i, j            ! index
integer(Kind=4) :: flag, ierr      ! function/subroutine status
! receiver parameters
integer(kind=4) :: Npre  ! length of prefix for output
real(kind=8) :: grnwin, twin       ! time-window of Green's functions, time-win. of seismograms
! Green's function parameters
integer(kind=4) :: Ngrn            ! number of Green's function dataset
real(kind=8) :: srad               ! radius of source for Green's function calculation
character(len=80) :: dire_gf       ! directory to store Green's function set
! source parameters
integer(kind=4) :: Nsrc, typesrc   ! number of source pathes, type-index for source
real(kind=8) :: munit,mrr,mtt,mpp,mrt,mpr,mtp,trss  ! scalar moment, 6 elements of moment tensor (type 1)
real(kind=8) :: strike,dip,rake                     ! 3 angles for double-couple source (type 2)
real(kind=8) :: fe,fn,fz                            ! 3 elements of single force vector (type 3)
real(kind=8),allocatable,dimension(:,:) :: sinfo    ! information of each source patch (Nsrc*4)
                                                    ! 1-3 are the same as 'event', the 4th element is the origin time of each patch
                                                    ! all source patches are sorted by the origin time

! read input file
open(unit=201, file=inputf, iostat=flag)
if(flag .ne. 0) then
    write(*, *)"Unable to open the QSSP input file ", inputf
    close(201)
    stop
endif
! uniform station depth
call skipline(201)
read(201, *)stdep
! space-time sampling parameters
call skipline(201)
read(201, *)grnwin, dt
do i = 1, 5    ! read rest 5 lines of this section
    read(201, *)
enddo
! self-gravitating
call skipline(201)
read(201, *)
! wave types
call skipline(201)
read(201, *)
! Green's function
call skipline(201)
read(201, *)Ngrn, srad, dire_gf
do i = 1, Ngrn
    read(201, *)
enddo
! source parameters
call skipline(201)
read(201, *)Nsrc, typesrc
allocate(sinfo(Nsrc,4), stat=ierr)
if(ierr .ne. 0)stop ' Error in readinput: sinfo not allocated. '
sinfo(:,:) = 0.d0
! consider different source parameter format
if(typesrc .eq. 1) then
    do i = 1, Nsrc
        read(201, *)munit,mrr,mtt,mpp,mrt,mpr,mtp,&
        &sinfo(i,1),sinfo(i,2),sinfo(i,3),sinfo(i,4),trss
    enddo
else if(typesrc .eq. 2) then
    do i = 1, Nsrc
        read(201, *)munit,strike,dip,rake,&
        &sinfo(i,1),sinfo(i,2),sinfo(i,3),sinfo(i,4),trss
    enddo
else if(typesrc .eq. 3) then
    do i = 1, Nsrc
        read(201, *)munit,fe,fn,fz,&
        &sinfo(i,1),sinfo(i,2),sinfo(i,3),sinfo(i,4),trss
    enddo
else
    stop ' Bad selection for the source data format!'
endif
! sort sinfo by origin time, which is sinfo(:,4)
! event: elat, elon, edep
do j = 1,3
    event(j) = sinfo(1,j)
enddo
! receiver parameters
call skipline(201)
read(201, *)    ! selection of observables
read(201, *)prefix    ! prefix in output file names
! length of prefix
Npre = len(trim(adjustl(prefix)))
read(201, *)twin    ! time  window of synthetic seismograms
Nlen = int(twin/dt)+1    ! length of seismograms
read(201, *)    ! filter
read(201, *)    ! slowness
read(201, *)Nr  ! number of receivers
allocate(stin(Nr,3), stat=ierr)
if(ierr .ne. 0)stop ' Error in readinput: stin not allocated. '
stin(:,:) = 0.d0
allocate(stname(Nr), stat=ierr)
if(ierr .ne. 0)stop ' Error in readinput: stname not allocated. '
! loop of every receiver
do i = 1, Nr
    read(201, *)stin(i,1),stin(i,2),stname(i),stin(i,3)
enddo
! no need to read model paramters

return
end subroutine

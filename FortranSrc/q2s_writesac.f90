subroutine writesac(Nr, Nlen, dt, prefix, datatype, direction, event)
! write seismograms to SAC format files, one SAC file for one station.
!
! Input:
!      Nr: number of stations,
!      Nlen: length of time seires,
!      dt: time sampling interval,
!      prefix: prefix for output file of QSSP, set in section RECEIVER PARAMETERS,
!      datatype: code for type of observable in QSSP output,
!      direction: code for channel direction,
!      event: 3-element vector for event information as lat., lon., and depth.
! Output:
!      no explicit output of this subrouine,
!      Nr*SAC files are created.
!
!
! Shenjian Zhang, <sjzhang@pku.edu.cn>
! 17. May. 2020


use station
use seismogram
use sacio
implicit none

! declaration
! arguements
integer(kind=4),intent(in) :: Nlen, Nr     ! length of time series, number of stations
real(kind=8),intent(in) :: dt              ! time sampling interval
character(len=80),intent(in) :: prefix     ! prefix for output file of QSSP
character(len=12),intent(in) :: datatype, direction       ! code of observable and channel
real(kind=8),dimension(3),intent(in) :: event             ! 1: latitude of event, 2: longitude, 3: depth
integer(kind=4) :: i            ! index
integer(kind=4) :: flag         ! function/subroutine status
real(kind=4) :: dt4, b4         ! delta t and b for SAC header, SINGLE-PRECISION
character(len=80) :: sprefix, prefixup ! short version, upper case of prefix for output file of QSSP
character(len=80) :: sacname                   ! name of SAC file
character(len=10) :: sstaname, stnameup        ! short version and uppercase of station name
type(sachead) :: header         ! head of SAC file

dt4 = real(dt, kind=4)
do i = 1, Nr
    ! upper case of prefix and station name
    sprefix = trim(adjustl(prefix))
    sstaname = trim(adjustl(stname(i)))
    call upper(sprefix(1:len(sprefix)), prefixup, len(sprefix), len(prefixup))
    call upper(sstaname(1:len(sstaname)), stnameup, len(sstaname), len(stnameup))
    ! file name of SAC
    sacname = trim(adjustl(prefixup))//'.'//trim(adjustl(stnameup))//'.'//trim(adjustl(datatype))//'.'//trim(adjustl(direction))//'.SAC'
    ! use reduced time as origin time for each seismogram
    b4 = real(stin(i,3), kind=4)
    ! initailize SAC head
    call sacio_newhead(header,dt4,Nlen,b4)
    header%kevnm = prefix
    header%evla = real(event(1), kind=4)
    header%evlo = real(event(2), kind=4)
    header%evdp = real(event(3), kind=4)
    header%kstnm = stname(i)
    header%kcmpnm = direction
    header%stla = real(stin(i,1), kind=4)
    header%stlo = real(stin(i,2), kind=4)
    header%stdp = real(stdep*1.0E3, kind=4)
    ! component azimuth / incident angle
    select case(direction)
    case('BXE')
        header%cmpaz = 90.0
        header%cmpinc = 90.0
    case('BXN')
        header%cmpaz = 0.0
        header%cmpinc = 90.0
    case('BXZ')
        header%cmpaz = 0.0
        header%cmpinc = 0.0
    case default
        header%cmpaz = SAC_rnull
        header%cmpinc = SAC_rnull
    endselect
    ! write SAC file
    call sacio_writesac(trim(adjustl(sacname)), header, seisdata(:,i), flag)
    write(*,*)'Create SAC file: ', trim(adjustl(sacname))
enddo

return
end subroutine

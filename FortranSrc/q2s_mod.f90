module station
! allocatable arguements for station information.
real(kind=8) :: stdep    ! uniform station depth
real(kind=8),allocatable,dimension(:,:) :: stin    ! station info.
character(len=10),allocatable,dimension(:) :: stname   ! station names
end module

module seismogram
! allocatable arguement for seismogram time series
! due to format restriction of SAC, SINGLE-PRECESION is used here.
real(kind=4),allocatable,dimension(:,:) :: seisdata
end module

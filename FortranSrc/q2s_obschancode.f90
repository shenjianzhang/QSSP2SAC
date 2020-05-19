subroutine obs_chan_code(fname, datatype, direction)
! obtain channel code (E/N/Z) or (EE/EN/EZ/NN/NZ/ZZ) and
! type of output observables of QSSP from the file name of QSSP output.
!    -observable code       -observabl type (in QSSP output)
!     DISP                   (disp)lacement!
!     VELO                   (velo)city
!     ACCE                   (acce)leration
!     ROTA                   (rota)tion
!     ROTA.RATE              rotation rate (rota_rate)
!     STRN                   (strain)
!     STRN.RATE              strain rate (strain_rate)
!     STRS                   (stress)
!     STRS.RATE              stress rate (stress_rate)
!     GRAV                   (gravitation)
!     GRME                   (gravimeter)
!
! Input:
!      fname: file name of QSSP output.
!
! Output:
!      datatype: code for type of observable in QSSP output,
!      direction: code for channel direction.
!
!
! Shenjian Zhang, <sjzhang@pku.edu.cn>
! 17. May. 2020

implicit none

! declaration
character(len=80),intent(in) :: fname                   ! file name
character(len=12),intent(out) :: datatype, direction    ! code of observable and channel
integer(kind=4) :: Nfn         ! character length of file name
character(len=4) :: sdtype     ! short data type, e.g. DISP, VELO

Nfn = len(trim(adjustl(fname)))

! the observables in QSSP output can be divided into THREE subgroups:
! (1) 3-component vector: disp, velo, acce, rota, rota_rate, gravitation
! (2) 6-element tensor: strain, strain_rate, stress, stress_rate
! (3) 1-element scalar: gravimeter

! ==== (1) 3-component vector ====
if(fname(Nfn-5:Nfn) .eq. '_e.dat' .or. fname(Nfn-5:Nfn) .eq. '_n.dat' .or. fname(Nfn-5:Nfn) .eq. '_z.dat' )then
    ! channel code
    select case(fname(Nfn-4:Nfn-4))
    case('e')
        direction = 'BXE'
    case('n')
        direction = 'BXN'
    case('z')
        direction = 'BXZ'
    case default
        stop 'Uknown direction/channel code of QSSP output.'
    endselect
    ! observable type
    if(fname(Nfn-14:Nfn-6) .eq. 'rota_rate')then
        datatype = 'ROTA.RATE'
    else if(fname(Nfn-16:Nfn-6) .eq. 'gravitation')then
        datatype = 'GRAV'
    else if(fname(Nfn-9:Nfn-6) .eq. 'disp' .or. fname(Nfn-9:Nfn-6) .eq. 'velo' .or. &
        &fname(Nfn-9:Nfn-6) .eq. 'acce' .or. fname(Nfn-9:Nfn-6) .eq. 'rota') then
        sdtype = fname(Nfn-9:Nfn-6)
        select case(sdtype)
        case('disp')
            datatype = 'DISP'
        case('velo')
            datatype = 'VELO'
        case('acce')
            datatype = 'ACCE'
        case('rota')
            datatype = 'ROTA'
        case default
            stop 'Uknown observable code of QSSP output.'
        endselect
    else
        stop 'Uknown observable code of QSSP output.'
    endif

! ==== (2) 6-element tensor ====
else if(fname(Nfn-6:Nfn) .eq. '_ee.dat' .or. fname(Nfn-5:Nfn-5) .eq. '_en.dat' .or. fname(Nfn-5:Nfn-5) .eq. '_ez.dat' &
& .or. fname(Nfn-6:Nfn) .eq. '_nn.dat' .or. fname(Nfn-6:Nfn) .eq. '_nz.dat' .or. fname(Nfn-6:Nfn) .eq. '_zz.dat' )then
    ! channel code
    select case (fname(Nfn-5:Nfn-4))
    case('ee')
        direction = 'BEE'
    case('en')
        direction = 'BNE'
    case('ez')
        direction = 'BEZ'
    case('nn')
        direction = 'BNN'
    case('nz')
        direction = 'BNZ'
    case('zz')
        direction = 'BZZ'
    case default
        stop 'Uknown direction/channel code of QSSP output.'
    endselect
    ! observable type
    if(fname(Nfn-10:Nfn-7) .eq. 'rate')then
        if(fname(Nfn-17:Nfn-12) .eq. 'strain')then
            datatype = 'STRN.RATE'
        elseif(fname(Nfn-17:Nfn-12) .eq. 'stress')then
            datatype = 'STRS.RATE'
        else
            stop 'Uknown observable code of QSSP output.'
        endif
    elseif(fname(Nfn-12:Nfn-7) .eq. 'strain')then
        datatype = 'STRN'
    elseif(fname(Nfn-12:Nfn-7) .eq. 'stress')then
        datatype = 'STRS'
    else
        stop 'Uknown observable code of QSSP output.'
    endif

! ==== (3) 1-element scalar ====
elseif(fname(Nfn-13:Nfn-4) .eq. 'gravimeter')then
    direction = 'BXX'
    datatype = 'GRME'

else
    stop 'Uknown observable/channel code of QSSP output.'

endif

return
end subroutine

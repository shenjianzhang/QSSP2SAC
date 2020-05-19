subroutine upper(strin, strout, Nlin, Nlout)
! change lower case in a string to upper case.
!
! Input:
!      strin: input string,
!      Nlin: length of input string,
!      Nout: length of output string.
! Output:
!      strout: output string.
!
!
! Shenjian Zhang, <sjzhang@pku.edu.cn>
! 17. May. 2020

implicit none

! declaration
character(len=Nlin),intent(in) :: strin
character(len=Nlout),intent(out) :: strout
integer(kind=4),intent(in) :: Nlin, Nlout
integer(kind=4) :: i,ascidx

do i = 1, Nlin
    ascidx = iachar(strin(i:i))
    if (ascidx .ge. iachar('a') .and. ascidx .le. iachar('z')) then
        strout(i:i) = achar(ascidx - 32)
    else
        strout(i:i) = strin(i:i)
    endif
enddo

return
end subroutine

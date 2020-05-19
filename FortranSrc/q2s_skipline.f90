subroutine skipline(fileunit)

implicit none

integer(kind=4) :: fileunit,iostat
character(len=1) :: readin    ! read the first character of the line

! read the first letter of the line
20 read(fileunit,'(a)',iostat=iostat)readin
if(iostat .ne. 0) then
    stop 'Error occured during read'
end if

! if the first letter is not '#', move back to the beginning of this line
! and stop this subroutine.
if(readin(1:1) .ne. '#') then
    backspace(fileunit)
    return
else
    ! if the first letter is '#', read next line.
    goto 20
end if

return
end

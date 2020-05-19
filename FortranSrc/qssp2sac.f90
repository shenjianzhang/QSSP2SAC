! This program convert synthetic seismograms calculated by QSSP
! to SAC (Seismic Analysis Code) format.
!
! Convert synthetic seismograms calculated by [QSSP](ftp://ftp.gfz-potsdam.de/pub/home/turk/wang/qssp2020-code+input.rar) to SAC file format.
!
! ## Features:
! 1. Convert outputs of QSSP to SAC-format with one command or script;
! 2. Write basic header information like location of event and station, name of event and station, and channel name;
! 3. Highlight observable types and directions according to QSSP outputs in the name of SAC files.
!
! ## Compilation
! A makefile called `makefile` can be used to compile your code.
! ```
! $ cd ./FortranSrc/
! $ make makefile
! ```
! Otherwise, you can compile the code straightforwardly as
! ```
! $ cd ./FortranSrc
! $ ifort *.f90 -o qssp2sac
! ```
!
! ## Usage:
! After compilation, an executable program is created (e.g. qssp2sac). THen you can run it as any other executable programs using `./`:
!
! You need to type the name of input file for QSSP, which contains all parameters to synthesize the seismograms with QSSP, and
! the name of output file of QSSP, which contains the synthetic seismograms.
! ```
!  $ ./qssp2sac
!  The input file for QSSP is:
! qssp.inp
! The output seismograms of QSSP is:
! qssp.out
! ```

!Note
! - `qssp.inp` and `qssp.out` are in the SAME directory as `qssp2sac`, in the other word, they should be
!   in the current working directory; (using absolute or relative path will be added in the furture)
! - `qssp.inp` is the input file with parameters for QSSP;
! - `qssp.out` is one of several output files after running QSSP with the input file `qssp.inp`;
! - the file name of `qssp.out` should follow the format as *prefix_observable_direction.dat*, in which
!   *prefix* is set in section RECEIVER PARAMETERS in `qssp.inp`, *observable* is the one you select in
!   section RECEIVER PARAMETERS in `qssp.inp` and direction is from *e/n/z* or *ee/en/ez/nn/nz/zz* upon
!   different observables.
! - JUST REMEMBER NOT TO RENAME OUTPUT FILES OF QSSP WHEN USING THIS SCRIPT.
!
! ## Example:
! Assuming you run QSSP with the input data file `qssp_exmaple.inp` and obtain 3 outputs as `example_disp_e.dat`
!`example_disp_n.dat`, and `example_disp_z.dat` (these four files could be found in folder `./Example`).
! Then you could run the command as
!```
! $ cd ./Example
! $ mv ../FortranSrc/qssp2sac ./
! $ ./qssp2sac
!  The input file for QSSP is:
! qssp_example.inp
!  The output seismograms of QSSP is:
! example_disp_e.dat
!  Create SAC file: EXAMPLE.STA1.DISP.BXE.SAC
!  Create SAC file: EXAMPLE.STA2.DISP.BXE.SAC
!```
!and get two SAC files as `EXAMPLE.STA1.DISP.BXE.SAC` and `EXAMPLE.STA2.DISP.BXE.SAC`. You could check header information
!and plot waveform using program SAC (Seismic Analysis Code).
!
!
! Written by
! Shenjian Zhang <sjzhang@pku.edu.cn>
! 17 May 2020

program qssp2sac

implicit none

! ======== declearation ========
! input and output file names for QSSP
! prfixname is a prefix for output QSSP, set in section  RECEIVER PARAMETERS in input file
character(len=80) :: qsspinput, qsspoutput,prfixname
! code for SAC file names
character(len=12) :: observable, channel
! Length of seismograms, number of stations
integer(kind=4) :: Ndata, Nst
! delta t of seismograms
real(kind=8) :: deltat
! event-related information
real(kind=8),dimension(3) :: evin    ! event info.


! ======== section 0 read in para.(file names)
write(*,*)"The input file for QSSP is: "
read(*,*)qsspinput
write(*,*)"The output seismograms of QSSP is: "
read(*,*)qsspoutput
! ======== section 1 read parameters from QSSP input file =========
call readinput(qsspinput, prfixname, deltat, Ndata, evin, Nst)
! ======== section 2 read seismograms from QSSP output file ========
! read seismograms from QSSP output
call readoutput(qsspoutput, Ndata, Nst)
! re-format observable and channel code
call obs_chan_code(qsspoutput, observable, channel)
! ======== section 3 write SAC files for each station ========
call writesac(Nst, Ndata, deltat, prfixname, observable, channel, evin)

end program

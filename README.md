#QSSP2SAC

## Python Script

Convert synthetic seismograms calculated by [QSSP](ftp://ftp.gfz-potsdam.de/pub/home/turk/wang/qssp2020-code+input.rar) to SAC file format.

### Features:
1. Convert outputs of QSSP to SAC-format with one command or script;
2. Write basic header information like location of event and station, name of event and station, and channel name;
3. Highlight observable types and directions according to QSSP outputs in the name of SAC files.

### Prerequisites
Module `sactrace` of `obspy.io.sac` is used for SAC writing, so the tool box [ObsPy](https://github.com/obspy/obspy/wiki)
(Beyreuther et al., 2010) is needed. See [ObsPy homepage](https://github.com/obspy/obspy/wiki#installation) for the instructions of installation.

### Usage:
```
$ python qssp2sac.py qssp.inp qssp.out
```
Note
- `qssp.inp` and `qssp.out` are in the SAME directory of `qssp2sac.py`, in the other word, they should be
  in the current working directory; (using absolute or relative path will be added in the furture)
- `qssp.inp` is the input file with parameters for QSSP;
- `qssp.out` is one of several output files after running QSSP with the input file `qssp.inp`;
- the file name of `qssp.out` should follow the format as *prefix_observable_direction.dat*, in which
  *prefix* is set in section RECEIVER PARAMETERS in `qssp.inp`, *observable* is the one you select in
  section RECEIVER PARAMETERS in `qssp.inp` and direction is from *e/n/z* or *ee/en/ez/nn/nz/zz* upon
  different observables.
- JUST REMEMBER NOT TO RENAME OUTPUT FILES OF QSSP WHEN USING THIS SCRIPT.

### Example:
Assuming you run QSSP with the input data file `qssp_exmaple.inp` and obtain 3 outputs as `example_disp_e.dat`
`example_disp_n.dat`, and `example_disp_z.dat` (these four files could be found in folder `./Example`).
Then you could run the command as
```
$ cd ./Example
$ mv ../qssp2sac.py ./
$ python qssp2sac.py qssp_example.inp exmaple_disp_e.dat
QSSP input file is qssp_example.inp
QSSP output file is example_disp_e.dat
Create SAC file: EXAMPLE.STA1.DISP.BXE.SAC
Create SAC file: EXAMPLE.STA2.DISP.BXE.SAC
```
and get two SAC files as `EXAMPLE.STA1.DISP.BXE.SAC` and `EXAMPLE.STA2.DISP.BXE.SAC`. You could check header information
and plot waveform using program SAC (Seismic Analysis Code).

### Reference
*M. Beyreuther, R. Barsch, L. Krischer, T. Megies, Y. Behr and J. Wassermann* (2010)
[ObsPy: A Python Toolbox for Seismology](http://www.seismosoc.org/Publications/SRL/SRL_81/srl_81-3_es/)
SRL, 81(3), 530-533
[DOI: 10.1785/gssrl.81.3.530](http://dx.doi.org/10.1785/gssrl.81.3.530)

#!/usr/bin/env python3

"""
Convert synthetic seismograms calculated by [QSSP](ftp://ftp.gfz-potsdam.de/pub/home/turk/wang/qssp2020-code+input.rar) to SAC file format.

## Features:
1. Convert outputs of QSSP to SAC-format with one command or script;
2. Write basic header information like location of event and station, name of event and station, and channel name;
3. Highlight observable types and directions according to QSSP outputs in the name of SAC files.

## Prerequisites
Module `sactrace` of `obspy.io.sac` is used for SAC writing, so the tool box [ObsPy](https://github.com/obspy/obspy/wiki)
(Beyreuther et al., 2010) is needed. See [ObsPy homepage](https://github.com/obspy/obspy/wiki#installation) for the instructions of installation.

## Usage:
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

## Example:
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

Written by
Shenjian Zhang <sjzhang@pku.edu.cn>
13 May 2020
"""

import sys
import warnings
import numpy as np
from obspy.io.sac import SACTrace

def skipcmmt(f):
    ''' Skip comments lines beginning with '#'
    and return the first line without '#'
    '''
    line = '#'
    while line[0] == '#' :
        line = f.readline()
    return(line)

def readinput(qsspin):
    ''' Read some info. from QSSP input file 'qsspin'
    '''
    fi = open(qsspin, 'r')
    # Uniform receiver depth
    linetmp = skipcmmt(fi)
    linelist = linetmp.split()
    rdep = float(linelist[0])
    # Time sampleing
    linetmp = skipcmmt(fi)
    linelist = linetmp.split()
    dt = float(linelist[1])
    for i in range(0, 5):
        fi.readline()
    # Sefl-gravitating
    linetmp = skipcmmt(fi)
    # Wave types
    linetmp = skipcmmt(fi)
    # Green's function
    linetmp = skipcmmt(fi)
    linelist = linetmp.split()
    ngrn = int(linelist[0])
    for i in range(0, ngrn):
        fi.readline()
    # Source para.
    linetmp = skipcmmt(fi)
    linelist = linetmp.split()
    nsrc = int(linelist[0])
    typesrc = int(linelist[1])
    sinfo = np.zeros((nsrc,4))
    # first source patch should be the one for hypocentre
    # could add a sort for origin time of each patch
    if typesrc == 1:
        for i in range(0, nsrc):
            linetmp = fi.readline()
            linelist = linetmp.split()
            sinfo[i,0] = linelist[7]    # slat
            sinfo[i,1] = linelist[8]    # slon
            sinfo[i,2] = linelist[9]    # sdep
            sinfo[i,3] = linelist[10]   # sorg
    elif typesrc == 2:
        for i in range(0, nsrc):
            linetmp = fi.readline()
            linelist = linetmp.split()
            sinfo[i,0] = linelist[4]    # slat
            sinfo[i,1] = linelist[5]    # slon
            sinfo[i,2] = linelist[6]    # sdep
            sinfo[i,3] = linelist[7]    # sorg
    elif typesrc == 3:
        for i in range(0, nsrc):
            linetmp = fi.readline()
            linelist = linetmp.split()
            sinfo[i,0] = linelist[4]    # slat
            sinfo[i,1] = linelist[5]    # slon
            sinfo[i,2] = linelist[6]    # sdep
            sinfo[i,3] = linelist[7]    # sorg
    else:
        print('bad selection for the source data format!')
        exit()
    # sort sinfo by origin-time (sinfo[:,3])
    # NEED TO BE DONE
    # set first row as the hypocentre
    srcinfo = sinfo[0,:]
    # Receiver para.
    linetmp = skipcmmt(fi)     # selection of output types
    linetmp = fi.readline()    # prefix of outputs
    prefix = linetmp.split()[0]
    if prefix[0] == "'" or prefix[0] == '"':
        prefix = eval(prefix)
    else:
        pass
    linetmp = fi.readline()    # time window length of outputs
    linelist = linetmp.split()
    timeout = float(linelist[0])
    linetmp = fi.readline()    # filter
    linetmp = fi.readline()    # slowness
    linetmp = fi.readline()    # receivers
    linelist = linetmp.split()
    nr = int(linelist[0])
    rinfo = np.zeros((nr,3))
    rname = []    # list of names
    for i in range(0,nr):
        linetmp = fi.readline()
        linelist = linetmp.split()
        rinfo[i,0] = linelist[0]    # rlat
        rinfo[i,1] = linelist[1]    # rlon
        rinfo[i,2] = linelist[3]    # trdc
        rnametmp = linelist[2]      # rnames
        if rnametmp[0] == "'" or rnametmp[0] == '"':
            rnametmp = eval(rnametmp)
        else:
            pass
        rname.append(rnametmp)
    # ignore model para.
    # close the file
    fi.close()
    # return args
    return dt, srcinfo, prefix, nr, rdep, rinfo, rname

def readoutput(qsspout):
    '''Read QSSP output files'''
    qsspdata = np.loadtxt(qsspout, dtype=np.float32, skiprows=1)
    seisdata = qsspdata[:,1:]    # only seismograms ignoring time
    return seisdata

def datatype_channel(prfx, fname):
    ''' Get channel code (E/N/Z) or (EE/EN/EZ/NN/NZ/ZZ) and
    type of output observables of QSSP from the file name of QSSP output.
    -observable code       -observabl type (in QSSP output)
     DISP                   (disp)lacement
     VELO                   (velo)city
     ACCE                   (acce)leration
     ROTA                   (rota)tion
     ROTA.RATE              rotation rate (rota_rate)
     STRN                   (strain)
     STRN.RATE              strain rate (strain_rate)
     STRS                   (stress)
     STRS.RATE              stress rate (stress_rate)
     GRAV                   (gravitation)
     GRME                   (gravimeter)
    '''
    # Read channel(E,N,Z) from QSSP output filename
    list3c = ['_e.dat', '_n.dat', '_z.dat']
    list6c = ['ee.dat', 'en.dat', 'ez.dat', 'nn.dat', 'nz.dat', 'zz.dat']
    if fname[-6:] in list3c:
        chancode = 'BX'+fname[-5].upper()
        if fname[-5] == 'e':
            az = 90
            inc = 90
        elif fname[-5] == 'n':
            az = 0
            inc = 90
        else:
            az = 0
            inc = 0
    elif fname[-6:] in list6c:
        chancode = 'B'+fname[-6:-4].upper()
        az = -12345.0
        inc = -12345.0
    else:
        chancode = 'BXX'
        az = -12345.0
        inc = -12345.0
    # read type of outputs from QSSP output filename
    listdva = ['disp', 'velo', 'acce', 'rota']
    listsig = ['strain', 'stress']
    if fname[len(prfx)+1:len(prfx)+5] in listdva:
        if fname[len(prfx)+6:len(prfx)+10] == 'rate':
            observ = fname[len(prfx)+1:len(prfx)+5].upper() + '.RATE'
        else:
            observ = fname[len(prfx)+1:len(prfx)+5].upper()
    elif fname[len(prfx)+1:len(prfx)+7] in listsig:
        observtmp = fname[len(prfx)+1:len(prfx)+4]+fname[len(prfx)+6]    # 'strn' for strain, 'strs' for stress
        if fname[len(prfx)+8:len(prfx)+12] == 'rate':
            observ = observtmp.upper() + '.RATE'
        else:
            observ = observtmp.upper()
    elif fname[len(prfx)+1:len(prfx)+12] == 'gravitation':
        observ = 'GRAV'
    elif fname[len(prfx)+1:len(prfx)+11] == 'gravimeter':
        observ = 'GRME'
    else:
        observ = 'UNKNOWN'
        print('Unknown output observables of QSSP.')
    return chancode, az, inc, observ

def main():
    print('QSSP input file is', sys.argv[1])
    print('QSSP output file is', sys.argv[2])
    qsspinput = sys.argv[1]
    qsspoutput = sys.argv[2]
    # read header info.s from QSSP input file
    deltat, spara, prfx, nr, rdepth, rpara, rnames = readinput(qsspinput)
    # read seismograms from QSSP output files
    seis = readoutput(qsspoutput)
    # read channel code and observable types
    chan, caz, cin, datatype = datatype_channel(prfx, qsspoutput)
    # write SAC files for each receiver/station
    for i in range(0, nr):
        # name for SAC file
        sacname = prfx.upper() + '.' + rnames[i].upper() + '.' + datatype + '.' + chan + '.SAC'
        header = {'iztype': 'io', 'o': 0, 'b': rpara[i,2], 'delta': deltat, \
        'kevnm': prfx, 'evla': spara[0], 'evlo': spara[1], 'evdp': spara[2],\
        'kstnm': rnames[i], 'kcmpnm': chan, 'cmpaz': caz, 'cmpinc': cin, \
        'stla': rpara[i,0], 'stlo': rpara[i,1], 'stdp': rdepth*1e3, \
        'lcalda': True}
        tr = SACTrace(data=seis[:,i], **header )
        tr.write(sacname)
        print('Create SAC file:', sacname)

if __name__ == '__main__':
    main()

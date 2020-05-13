#!/usr/bin/env python3

import sys
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
    return
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

def main():
    print('QSSP input file is', sys.argv[1])
    print('QSSP output file is', sys.argv[2])
    qsspinput = sys.argv[1]
    qsspoutput = sys.argv[2]
    # read header info.s from QSSP input file
    deltat, spara, prfx, nr, rdepth, rpara, rnames = readinput(qsspinput)
    # read seismograms from QSSP output files
    seis = readoutput(qsspoutput)

    # Write SAC files
    # read channel(E,N,Z) from QSSP output filename
    list3c = ['_e.dat', '_n.dat', '_z.dat']
    list6c = ['ee.dat', 'en.dat', 'ez.dat', 'nn.dat', 'nz.dat', 'zz.dat']
    if qsspoutput[-6:] in list3c:
        chan = 'BX'+qsspoutput[-5].upper()
        if qsspoutput[-5] == 'e':
            caz = 90
            cin = 90
        elif qsspoutput[-5] == 'n':
            caz = 0
            cin = 90
        else:
            caz = 0
            cin = 0
    elif qsspoutput[-6:] in list6c:
        chan = 'B'+qsspoutput[-6:-4].upper()
        caz = -12345.0
        cin = -12345.0
    else:
        chan = 'BXX'
        caz = -12345.0
        cin = -12345.0
    #
    for i in range(0, nr):
        # name for SAC file
        sacname = prfx.upper() + '.' + rnames[i].upper() + '.' + chan + '.SAC'
        header = {'iztype': 'io', 'o': 0, 'b': rpara[i,2], 'delta': deltat, \
        'kevnm': prfx, 'evla': spara[0], 'evlo': spara[1], 'evdp': spara[2],\
        'kstnm': rnames[i], 'kcmpnm': chan, 'cmpaz': caz, 'cmpinc': cin, \
        'stla': rpara[i,0], 'stlo': rpara[i,1], 'stdp': rdepth*1e3, \
        'lcalda': True}
        tr = SACTrace(data=seis[:,i], **header )
        tr.write(sacname)

if __name__ == '__main__':
    main()

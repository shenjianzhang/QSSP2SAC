# makefile for compilation of QSSP2SAC (Fortran)

objs = qssp2sac_main.o q2s_readinput.o q2s_readoutput.o q2s_obschancode.o \
       q2s_writesac.o q2s_skipline.o upper.o sacio.o q2s_mod.o

# compiler: ifort
FC = ifort
FFLAGS = -traceback
#FFLAGS = -traceback -check all
# compiler: gfortran
#FC = gfortran
#FFLAGS = -fbacktrace

# make a rule
%.o : %.f90
		$(FC) -c $< $(FFLAGS)

# compile
qssp2sac : $(objs)
		$(FC) -o qssp2sac $(FFLAGS) $^
station.mod seismogram.mod : q2s_mod.f90
		$(FC) -c q2s_mod.f90 $(FFLAGS)
sacio.mod : sacio.f90
		$(FC) -c sacio.f90 $(FFLAGS)
q2s_mod.o : q2s_mod.f90
qssp2sac_main.o : qssp2sac_main.f90
q2s_readinput.o : station.mod q2s_readinput.f90
q2s_readoutput.o : seismogram.mod q2s_readoutput.f90
q2s_obschancode.o : q2s_obschancode.f90
q2s_writesac.o : station.mod seismogram.mod sacio.mod q2s_writesac.f90
q2s_skipline.o : q2s_skipline.f90
upper.o : upper.f90
sacio.o : sacio.f90

# clean
.PHONY : clean
clean :
		-rm *.o *.mod

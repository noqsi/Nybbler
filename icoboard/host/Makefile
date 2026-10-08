
CFLAGS = -I. -Wall
LDLIBS = -lpigpio

.PHONY : all clean

all : nyrun
	sudo chown root nyrun
	sudo chmod u+s nyrun

nyrun : nyif.o nyrun.o

nyif.o : nyif.h

clean : 
	rm -f nyrun nyif.o nyrun.o

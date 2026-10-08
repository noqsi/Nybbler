# Use the development assembler and host driver

NYASM=../../assembler/nyasm
NYSA=../../assembler/nysa
NYRUN=../host/nyrun

# For benefit of the assembler
export AWKDIR=../../assembler

%.nyobj : %.nyasm
	$(NYASM) $< >$@

# note that basics must go first here to wind up in low memory
# where the functions and variables belong

%.nyasm : %.nysa basics.nysa
	$(NYSA) basics.nysa $< >$@

%.pdf : %
	enscript -o $<.ps --title="Nybbler Assembly Listing" $<
	ps2pdf $<.ps
	rm $<.ps

.PHONY : shout countdown clean

countdown : countdown.nyobj
	$(NYRUN) countdown.nyobj

shout : shout.nyobj
	$(NYRUN) shout.nyobj

clean : 
	rm -f *.nyasm *.nyobj *.pdf *.ps

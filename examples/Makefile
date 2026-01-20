# Use the development assembler and host driver

NYASM=../assembler/nyasm
NYSA=../assembler/nysa
NYRUN=sudo ../host/nyrun

# For benefit of the assembler
export AWKDIR=../assembler

%.nyobj : %.nyasm
	$(NYASM) $< >$@

%.nyasm : %.nysa
	$(NYSA) basics.nysa $< >$@

%.pdf : %
	enscript -o $<.ps --title="Nybbler Assembly Listing" $<
	ps2pdf $<.ps
	rm $<.ps

.PHONY : countdown clean

countdown : countdown.nyobj
	$(NYRUN) <countdown.nyobj

clean : 
	rm -f *.nyasm *.nyobj *.pdf *.ps

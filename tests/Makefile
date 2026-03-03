# Use the development assembler and host driver

NYASM=../assembler/nyasm
NYRUN=../host/nyrun

# For benefit of the assembler
export AWKDIR=../assembler

%.nyobj : %.nyasm utils.nyasm
	$(NYASM) utils.nyasm $< >$@

%.pdf : %
	enscript -o $<.ps --title="Nybbler Assembly Listing" $<
	ps2pdf $<.ps
	rm $<.ps

.PHONY : check test divcheck countcheck clean

check : test countcheck divcheck

# Only need to make this if you change test.nyasm

test.out : test.nyobj
	$(NYRUN) test.nyobj >test.out

test : test.nyobj
	$(NYRUN) test.nyobj | diff - test.out
	@echo "test OK"

countcheck : count.nyobj countcheck.awk
	$(NYRUN) count.nyobj | gawk -f countcheck.awk
	
divcheck : division.nyobj divcheck.awk
	@echo "This should take a minute or so:"
	$(NYRUN) division.nyobj | gawk -f divcheck.awk
	@echo "test OK"

clean : 
	rm -f *.nyobj *.pdf *.ps

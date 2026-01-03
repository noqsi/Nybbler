
test : test.nyobj nyasm.awk
	sudo ../host/nyrun <test.nyobj | less

test.pdf : test.ps
	ps2pdf test.ps

test.ps : test.nyobj
	enscript -o test.ps --title="Nybbler Assembly Listing" test.nyobj

test.nyobj : test.nyasm
	./nyasm.sh test.nyasm >test.nyobj


test : test.nyobj
	sudo ../host/nyrun <test.nyobj

test.pdf : test.ps
	ps2pdf test.ps

test.ps : test.nyobj
	enscript -C -o test.ps --title="Nybbler Assembly Listing" test.nyobj

test.nyobj : test.nyasm
	./nyasm.sh test.nyasm >test.nyobj

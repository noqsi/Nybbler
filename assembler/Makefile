
test : test.nyobj nyasm.awk
	sudo ../host/nyrun <test.nyobj | less

test_gemini : test_gemini.nyobj nyasm.awk
	sudo ../host/nyrun <test_gemini.nyobj | less

test.pdf : test.ps
	ps2pdf test.ps

test.ps : test.nyobj
	enscript -o test.ps --title="Nybbler Assembly Listing" test.nyobj

test.nyobj : test.nyasm
	./nyasm.sh test.nyasm >test.nyobj

test_gemini.nyobj : test_gemini.nyasm
	./nyasm.sh test_gemini.nyasm >test_gemini.nyobj
	
test-jmp : test-jmp.nyobj nyasm.awk
	sudo ../host/nyrun <test-jmp.nyobj 

test-jmp.nyobj : test-jmp.nyasm
	./nyasm.sh test-jmp.nyasm >test-jmp.nyobj
	
division : division.nyobj nyasm.awk
	sudo ../host/nyrun <division.nyobj 

division.nyobj : division.nyasm
	./nyasm.sh division.nyasm >division.nyobj

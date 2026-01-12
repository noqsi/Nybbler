
test : test.nyobj
	sudo ../host/nyrun <test.nyobj | less

test_gemini : test_gemini.nyobj
	sudo ../host/nyrun <test_gemini.nyobj | less

test.pdf : test.ps
	ps2pdf test.ps

test.ps : test.nyobj
	enscript -o test.ps --title="Nybbler Assembly Listing" test.nyobj

test.nyobj : test.nyasm nyasm.awk
	./nyasm.sh test.nyasm >test.nyobj

test_gemini.nyobj : test_gemini.nyasm nyasm.awk
	./nyasm.sh test_gemini.nyasm >test_gemini.nyobj
	
test-jmp : test-jmp.nyobj
	sudo ../host/nyrun <test-jmp.nyobj 

test-jmp.nyobj : test-jmp.nyasm nyasm.awk
	./nyasm.sh test-jmp.nyasm >test-jmp.nyobj
	
division : division.nyobj
	sudo ../host/nyrun <division.nyobj 

division.nyobj : division.nyasm nyasm.awk
	./nyasm.sh division.nyasm >division.nyobj

divcheck : division.nyobj divcheck.awk
	sudo ../host/nyrun <division.nyobj | gawk -f divcheck.awk

count : count.nyobj
	sudo ../host/nyrun <count.nyobj 

count.nyobj : count.nyasm nyasm.awk
	./nyasm.sh count.nyasm >count.nyobj


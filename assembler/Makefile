
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

count.nyobj : count.nyasm utils.nyasm nyasm.awk
	./nyasm.sh utils.nyasm count.nyasm >count.nyobj

countdown.nyasm : countdown.nysa nysa nysa.awk
	./nysa countdown.nysa >countdown.nyasm

countdown.nyobj : countdown.nyasm utils.nyasm nyasm.awk
	./nyasm.sh utils.nyasm countdown.nyasm >countdown.nyobj

countdown : countdown.nyobj
	sudo ../host/nyrun <countdown.nyobj 

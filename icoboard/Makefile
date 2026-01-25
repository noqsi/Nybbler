nybbler: nybbler12.bin
	icoprog -p < nybbler12.bin

clean:
	rm -f nybbler12.blif nybbler12.asc nybbler12.bin 

nybbler12.blif: nybbler12.v pi_interface.v RAM.v core.v
	yosys -p 'synth_ice40 -top top -blif nybbler12.blif' nybbler12.v \
		pi_interface.v RAM.v core.v

nybbler12.asc: nybbler12.blif icoboard.pcf
	arachne-pnr -d 8k -p icoboard.pcf -o nybbler12.asc nybbler12.blif

nybbler12.bin: nybbler12.asc
	icetime -d hx8k -c 25 nybbler12.asc
	icepack nybbler12.asc nybbler12.bin

flash: 
	icoprog -f < nybbler12.bin

lint:
	verilator --lint-only nybbler12.v pi_interface.v RAM.v core.v

.PHONY: nybbler flash clean lint


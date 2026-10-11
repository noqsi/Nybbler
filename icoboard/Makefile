# For getting started with programming

start:
	$(MAKE) -C host
	icoprog -p < nybbler12.bin
	$(MAKE) -C tests	

# Build and upload firmware from Verilog source

nybbler: nybbler12.bin
	icoprog -p < nybbler12.bin

# Upload to flash, so the board powers up as a Nybbler

flash: 
	icoprog -f < nybbler12.bin

# Check source code for mistakes and poor practices

lint:
	verilator --lint-only -Ilint nybbler12.v pi_interface.v RAM.v core.v

# Test your Nybbler

test:
	$(MAKE) -C tests	

clean:
	rm -f nybbler12.blif nybbler12.asc 
	$(MAKE) -C host clean
	$(MAKE) -C tests clean
	$(MAKE) -C examples clean

nybbler12.blif: nybbler12.v pi_interface.v RAM.v core.v
	yosys -p 'synth_ice40 -top top -blif nybbler12.blif' nybbler12.v \
		pi_interface.v RAM.v core.v

nybbler12.asc: nybbler12.blif icoboard.pcf
	arachne-pnr -d 8k -p icoboard.pcf -o nybbler12.asc nybbler12.blif

nybbler12.bin: nybbler12.asc
	icetime -d hx8k -c 25 nybbler12.asc
	icepack nybbler12.asc nybbler12.bin

.PHONY: nybbler flash clean lint start


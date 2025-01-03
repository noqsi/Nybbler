
ifeq ($(shell bash -c 'type -p icoprog'),)
SSH_RASPI ?= ssh pi@raspi
else
SSH_RASPI ?= sh -c
endif

help:
	@echo
	@echo "make example.blif      run synthesis, generate BLIF netlist"
	@echo "make example.asc       run place and route, generate IceStorm ASCII file"
	@echo "make example.bin       run timing analysis, generate iCE40 BIN file"
	@echo
	@echo "make prog_sram         FPGA SRAM programming, (re)starts FPGA from SRAM"
	@echo "make prog_flash        serial flash programming, does not touch FPGA"
	@echo "make prog_erase        erase first flash block"
	@echo
	@echo "make reset_halt        stop FPGA and keep in reset"
	@echo "make reset_boot        (re)start FPGA from serial flash"
	@echo
	@echo "make clean             remove output files"
	@echo

example.blif: example.v
	yosys -p 'synth_ice40 -blif example.blif' example.v

example.asc: example.blif icoboard.pcf
	arachne-pnr -d 8k -p icoboard.pcf -o example.asc example.blif

example.bin: example.asc
	icetime -d hx8k -c 25 example.asc
	icepack example.asc example.bin

prog_sram: example.bin
	$(SSH_RASPI) 'icoprog -p' < example.bin

prog_flash: example.bin
	$(SSH_RASPI) 'icoprog -f' < example.bin

prog_erase:
	$(SSH_RASPI) 'icoprog -e'

reset_halt:
	$(SSH_RASPI) 'icoprog -R'

reset_boot:
	$(SSH_RASPI) 'icoprog -b'

clean:
	rm -f example.blif example.asc example.bin \
		nybbler12.blif nybbler12.asc nybbler12.bin 

nybbler12.blif: nybbler12.v pi_interface.v RAM.v core.v
	yosys -p 'synth_ice40 -top top -blif nybbler12.blif' nybbler12.v \
		pi_interface.v RAM.v core.v

nybbler12.asc: nybbler12.blif icoboard.pcf
	arachne-pnr -d 8k -p icoboard.pcf -o nybbler12.asc nybbler12.blif

nybbler12.bin: nybbler12.asc
	icetime -d hx8k -c 25 nybbler12.asc
	icepack nybbler12.asc nybbler12.bin

nybbler: nybbler12.bin
	$(SSH_RASPI) 'icoprog -p' < nybbler12.bin

lint:
	verilator --lint-only nybbler12.v pi_interface.v RAM.v core.v

.PHONY: prog_sram prog_flash reset_halt reset_boot clean lint


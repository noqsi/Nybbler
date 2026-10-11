# Nybbler on the icoBoard

The following instructions are for building and operating a 12 bit Nybbler on a [Trenz icoBoard](https://www.trenz-electronic.de/en/Products/Trenz-Electronic/Open-Hardware/icoBoard/) hosted on a Raspberry Pi computer.

## Getting started

Install [icoprog](https://github.com/cliffordwolf/icotools/tree/master/icoprog).

Install *pigpio*:

`sudo apt-get pigpio`

In the *icoboard* directory, type

`make`

This will compile the `nyrun` tool, upload the Nybbler firmware to the icoBoard, and run some tests.

Now you're ready to try the examples in the *icoboard/examples* directory, and start using the assembler for your own project.

## Working with the Verilog Source

To make your own additions and changes to the nybbler12 design you'll need some more tools.

On the Raspberry Pi, install the [Project IceStorm development tools](https://prjicestorm.readthedocs.io/en/latest/overview.html#where-are-the-tools-how-to-install), using the Ubuntu instructions.

To be able to "lint" the source,

`sudo apt install verilator`

### Useful make targets in the icoboard directory

`make lint` checks the Verilog source for mistakes and poor practices.

`make nybbler` translates the Verilog source to a bitfile and uploads it to the board.

`make test` runs the tests from the *icoboard/tests* directory.

`make flash` uploads the bitfile to flash, so the icoBoard will power up as a Nybbler.
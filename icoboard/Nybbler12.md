# 12 bit Nybbler Implementation

## Core
The 12 bit core `core.v` has the following implementation details and extensions to the basic Nybbler architecture.

### Memory
Code and data memory are separate. The processor cannot access code memory as data: it can only execute instructions from it. Both 4k word memory spaces are fully populated with RAM.

Input/output has its own address space and its own access instructions.

### Host communication
An instruction of FFF, nominally an infinite loop, halts the processor. A host processor may detect this and take some suitable action. See [the Pi interface spec](pi_interface.md) for the electrical details, and [icoboard/examples/basics.nysa](examples/basics.nysa) for implementation of host communication using this feature to communicate with the `nyrun` command on the host.

### Extended instructions

code | name | function
-----|------|---------
0    | x_input | Read from input
1    | x_output | Write to output

`extend x_input` replaces the address of an I/O register on the top of the stack with the result of reading it.

`extend x_output` writes the value next on the stack to the I/O address on the top of the stack. The address is dropped, leaving the value on the top of the stack.

## I/O devices

### PMODs

Each PMOD on the icoBoard supports 8 digital pins.

PMOD | data address | enable address
-----|--------------|---------------
1 | 0 | 1
2 | 2 | 3
3 | 4 | 5
4 | 6 | 7

To obtain the state of the pins, use `x_input` to read from the "data address" above. To enable pins as outputs, write a suitable mask to the "enable address" using `x_output`. Writing to the "data address" will control the enabled bits. Reading from the "enable address" will yield the mask currently in effect.

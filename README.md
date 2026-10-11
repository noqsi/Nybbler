# Nybbler
Simple nanocomputer

## Architecture
* Intended for FPGA implementation
* Four bit instructions (nybbles)
* Fixed word length may be any multiple of 4 bits
* Multiple instructions per instruction word
* Two hardware stacks, call/return and arithmetic

See *Nybbler.md* for architectural details.

## Software
Cross-assembler in AWK with preprocessor for structured code. See *nyasm.md* and *nysa.md* in the *assembler* directory.

There is test and demonstration code under the *icoboard* directory.

## Implementation
The *icoboard* directory contains a 12 bit, Harvard architecture implementation for the Trenz Electronic icoBoard hosted on a Raspberry Pi. See *README.md* in the *icoboard* directory.
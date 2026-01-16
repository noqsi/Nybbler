Three bits control the interface.

* DIR (GPIO 20) is 0 for reading, 1 for writing.
* CLK (GPIO 21) pulses high to read or write.
* SEL (GPIO 17) selects the data path.

If DIR and CLK are both zero, the Raspberry Pi may read a byte of status information from the interface.

SEL |READ | WRITE | POLL
---- | ---- | ---- |---
0 | DR   | DR  | STAT
1 | DRX | CMD | STATX

There are two registers, each split into two components.

* The unified data register, UDR (12 bits), has its MSBs in the DRX register (4 bits), and its LSBs in the DR register.
* The unified address register, UAR, has its MSBs in the ARX register (8 bits) and its LSBs in the AR register. ARX is two parts: its four MSBs are a memory segment number. Its four LSBs are the MSBs of the memory address within a segment.

Segment | Contents | Size (words)
--- | --- | ---
1 | Data memory | 4096
2 | Code memory | 4096
3 | Number stack | 256
4 | Return stack | 256
5 | Processor registers | 4

Processor Registers

\# | Function | Bits
--- | --- | ---
0	| Program counter | 12
1 | Top of stack | 12
2 | Return stack pointer | 8
3 | Number stack pointer | 8



A write with SEL=1 sends a command byte to the interface. There are 8 commands, each associated with a bit in the command byte.

BIT | Command
--- | ---
0 | Write DR to DRX
1 | Write DR to AR
2 | Write DR to ARX
3 | Increment address
4 | Read memory
5 | Write memory
6 | Start processor
7 | Halt processor

The increment address command increments the 12 bit address part of the UAR. It does not change the segment field.

Multiple commands may be combined, except that increment address prevents any other change to AR or ARX. The increment occurs after any memory read or write. If you read and write memory in one command, you swap DR with the addressed memory cell. If you start and halt the processor in one command, the processor will execute a single instruction word (which could be as many as three instructions).

The least significant bit of the STAT register is 1 if the processor is running, 0 if it is halted. Other bits in STAT and STATX may be assigned in the future.
## Features
* Simple, minimalist instruction set.
* Word-oriented: data, address, and instruction words are all the same size.
* Scalable: word size may be any multiple of 4 bits.
* Stack-oriented, natural for FORTH and similar low-level languages.
* Simple, efficient function linkage encourages factored code.

## Data model

For any implementation, binary data comes in words whose size is a fixed multiple of four bits. 8, 12, 16, 20, ... bit implementations are possible. 4 bits is logically possible but unlikely to be useful. Instruction and data words are the same size.

Data encoding is modular two's complement binary. Addresses and literal data embedded within instruction words are sign-extended when used.

## Memory model

Data and instruction memory spaces are separate. Memory is addressed as words of the implementation's fixed size.

### Registers

Address | Name | Function
------- | ---- | --------
-1	| sp | Stack pointer
-2 | cst | Call stack top
-3 | csp | Call stack pointer
-4 | carry | Carry bit
-5 | except	| Exception state/mask
-6 | iodat	| I/O data
-7 | iostat	| I/O device status
-8 | iosel | Select I/O device


## Instruction Encoding

Instructions are encoded as four bits (nybbles), packed into instruction word. When an instruction word is executed, all instructions in the word are executed in sequence. There is an exception to this rule: if the instruction word contains a **tsz** instruction, instructions following the **tsz** will be conditionally skipped.

*Long* instructions take the remaining nybbles of the instruction word as an operand. If the long instruction is in the last nybble of an instruction word, it takes the entire following word as its operand.
 
## Opcodes
Hex | ASM | LSE | S/L | Summary
-------- | ----- | ---- | ------ | ----
0 | nop	| {} | S | No operation
1 | return | ] | S | Return from function
2 | snz | (ifz) | S | Skip if nonzero
3 | half | 2/ | S | Divide TOS by two
4 | add	| + | S | Add TOS to NOS
5 | neg	| neg | S | Negate TOS
6 | and	| & | S | Bitwise and
7 | not	| ~ | S | Bitwise not
8 | fetch | @ | S | Replace TOS with its target in memory
9 | store | ! | S | NOS to TOS target, drop both
A | swap | swap | S | Swap NOS with TOS
B | dup | dup | S | Duplicate TOS
C | call | call | L | Call function
D | jump | jump | L | Relative jump to code
E | literal | literal | L | Put literal value on stack
F | extend | extend | L | Undefined: for future extensions

## Operation details
### nop {}
This does nothing. Its principal use is to fill out unused nybbles in instruction words.
### return ]
Return from function. Pops the return address from the return stack into the PC.
### if
If TOS is zero, skip the next instruction. TOS is dropped. 
### half 2/
Shift the TOS right by one. The most significant bit is unchanged. This is thus a signed divide by 2. The least significant bit shifts into the **carry** register.
### add +
Add TOS to NOS, dropping TOS. This also modifies the **carry** register.
### neg
Negate the TOS (twos complement). Modifies the **carry** register (0 unless resulting TOS is 0).
### and &
Logical bitwise and of TOS with NOS. TOS is dropped, with the modified NOS becoming the TOS.
### not ~
Complement bits in the TOS.
### fetch @
TOS holds an address in data memory. Replace TOS with the contents of the addressed memory word.
### store !
TOS holds an address in data memory. Store NOS at that memory location, drop both TOS ans NOS.
### swap
Swap TOS and NOS.
### dup
Duplicate TOS, push duplicate on stack.
### call
Push PC on return stack, set PC to long operand.
### jump
Add long operand to PC.
### literal
Push long operand on stack.
### extend
Reserved for future extensions.

## Flow Control
Instructions **call**, **return**, and **jump**, control the processor's execution trajectory by modifying the PC. Only **tsz** can control flow within instruction words. Thus, if **return** appears within an instruction word (not at the end), subsequent instructions in that word will use the modified PC.

## Examples

```
drop
	if nop return
```
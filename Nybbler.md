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

Memory is addressed as words of the implementation's fixed size. Minimal implementations share memory between instructions and data, although an enhanced implementation may separate them.

## Instruction Encoding

Instructions are encoded as four bits (nybbles), packed into instruction word. When an instruction word is executed, all instructions in the word are executed in sequence.

*Long* instructions take the remaining nybbles of the instruction word as an operand. If the long instruction is in the last nybble of an instruction word, the word at the location the PC points to is taken as its operand. This is commonly the word following the instruction word. However, if the instruction word contains instruction(s) that modify the PC (**return** or **tsz**), that modified PC will supply the address of the operand.
 
## Opcodes
Hex | ASM | LSE | S/L | Summary
-------- | ----- | ---- | ------ | ----
0 | nop	| {} | S | No operation
1 | half | 2/ | S | Divide TOS by two
2 | neg	| neg | S | Negate TOS
3 | not	| ~ | S | Bitwise not
4 | return | ] | S | Return from function
5 | tsz | (if) | S | Test, skip if zero
6 | add	| + | S | Add TOS to NOS
7 | and	| & | S | Bitwise and
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
### tsz (if)
If TOS is zero, skip the next instruction. TOS is dropped. 
### half 2/
Shift the TOS right by one. The most significant bit is unchanged. This is thus a signed divide by 2. The least significant bit shifts into the **carry** register.
### add +
Add TOS to NOS, dropping TOS. This also modifies the **carry** register.
### neg
Negate the TOS (twos complement).
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
Instructions **call**, **return**, **jump**, and **tsz** control the processor's execution trajectory by modifying the PC. There is no flow control within instruction words: if an instruction word is fetched for execution, every instruction in that word will be executed.

## Examples

```
drop		# functional version
	tsz
	return
	return

# Inline version of drop
	tsz
	nop

# Three way conditional jump
	dup literal 
	0x8000	# assume 16 bit version
	and tsz tsz jump
	neg_target
	pos_target
	zero_target
```

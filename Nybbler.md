## Features
* Simple, minimalist instruction set.
* Word-oriented: data, address, and instruction words are all the same size.
* Scalable: word size may be any multiple of 4 bits.
* Stack-oriented, natural for FORTH and similar low-level languages.
* Simple, efficient function linkage encourages factored code.

## Data model

## Instruction Encoding


 
## Opcodes
Hex | ASM | LSE | S/L | Summary
-------- | ----- | ---- | ------ | ----
0 | nop	| {} | S | No operation
1 | return | ] | S | Return from function
2 | tsz | (if) | S | Test, skip if zero
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
### tsz (if)
If TOS is zero, skip the remaining instructions in the instruction word. TOS is dropped. If the last nybble of the word holds a long instruction, also increment the PC to skip over its operand. If *tsz* is the last instruction in a word, it drops the TOS with no other effect.
 
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
2way
	return tsz jump
```
# Nybbler Assembly Language

Fields are separated by whitespace.

**#** introduces comment text

```
# This is a comment
	neg add	# A comment on subtraction instructions
```

Blank lines are ignored.

A non-comment field that starts at the beginning of a line represents a symbol. Symbols should not start with **+**, **-**, **@**, or a decimal digit. 

```
ten	=	10	# Defines the symbol ten as 10
top	snz		# top is the snz instruction address
```

**.** is a special symbol, representing the location the next instruction will occupy.

**..** is a special symbol, represent the location the next data object will occupy.

Constants may be either decimal integers or hexadecimal integers with the usual **0x** prefix.

### Assembler Operations

**=** defines a symbol without other effect. See example above.

**data** reserves a word in data memory, initializing it to the given value, either a constant or a symbol.

```
answer	data	42
```

**string** creates a "counted" string im data memory. The first word of the string is the count of characters it contains. The string itself consists of all characters following the first whitespace character after **string**.

```
message	string Hello World!
```

For **data** and **string**, any label refers to the data memory address.

```
foo	= ..
bar data	0xbad	# foo and bar will be equal
```

### Program Lines

A program line is an optional label followed by a list of operation codes and may end with a symbol or constant. Each program line corresponds to one word of program memory. The following examples are for a 3 nybble (12 bit) implementation.

You may have up to three instructions per line for a 3 nybble processor.

```
	neg add neg	# reverse subtract
```

If you have fewer than three, and no symbol or constant, the assembler will insert **nop** as needed to fill the word.

```
	swap			# a single instruction
	nop nop swap	# this is equivalent
```

If you finish a line with a symbol, the numeric value of the symbol will occupy the available nybbles in the word. If the numeric value does not fit in the available space, the assembler will print a message and exit.

```
	drop push 13	# replace TOS with 13
	drop push 17	# error, 17 doesn't fit in a nybble
	push 42		# OK, two nybbles available, 42 fits
```

A symbol by itself on a line will occupy a whole word.

```
	push
	1951	# wouldn't fit in two nybbles
```

The **jump** instruction works relative to the address of the word following the word containing its operand.

```
	jump -1	# jumps to itself
	jump
	-2			# jumps to itself
	jump 0		# equivalent to nop
	jump 1		# skips the next instruction word
```

Preceding a symbol or constant with **@** converts an absolute address to a relative offset for **jump**.

```
looptop		# some
			# loop
			# code
	jump @looptop
```

### Opcodes
#### Short (one nybble)

**nop**,
**half**,
**neg**,
**not**,
**return**,
**snz**,
**add**,
**and**,
**fetch**,
**store**,
**swap**,
**drop**

#### Long (need operand)

**call**,
**push**,
**extend**,
**jump**

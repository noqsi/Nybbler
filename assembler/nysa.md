# Nybbler Structured Assembly Language

### Basic Conditionals

*  **if** or **ifnot**
*  **else**
*  **endif**

Typical usage:

```
	<put value on stack>
	if
	<something>
	else
	<something else>
	endif
```

### Loops

* **do** or **times**
* **repeat** or **done**

#### Basic loop

```
	do
		<something>
	continue		# optional: jumps back to the top
		<more>
	break			# optional: jumps out of the loop
		<still more>
	repeat			# jumps back to the top
```

#### Counted loop

```
	<put count on stack>
	times
		<something>
	continue		# optional: jumps back to the top
		<more>
	break			# optional: jumps out of the loop
		<still more>
	repeat			# jumps back to the top
```

**times** checks if the TOS is zero, breaking the loop if it is. Otherwise, it subtracts 1 from the TOS and continues into the loop.

#### Variations

Ending the loop with **done** instead of **repeat** breaks out of the loop when the end is reached. In this case, if there is no **continue**, the loop will not repeat. This is useful for "short-circuit" **do** blocks, where conditional **break** operations skip to the end.

### Stack Management
In most cases the block structure commands do not affect the processor's data stack, but there are exceptions.

* **if** and **ifnot** drop the value from the stack top after testing it.
* When **repeat** closes a **times** loop, it drops the stack top (normally the loop counter) upon loop exit (including exits via **break**).

Since the stack holds the loop counter in a **times** loop, code between **times** and any following **continue** or loop-closing **repeat** should not leave extra data on the stack, nor should it drop the loop counter.

If you wish for the loop count to survive exit from a **times** loop, you may close it with **done**. Of course, then it won't loop unless you use **continue** within the loop.

### Using the structure expander

**nyasm** *file.nysa* ... >output.nyasm

This creates a regular assembly language file from a list of structured assembly language source files. The source files are assembled in order, so (barring explict setting of the location counters), code that needs to be in low addresses should be in earlier files in the list. For a given program, all of the structured assembly files need to be processed by a single **nysa** run: if you attempt to combine files created by **nysa** using **nyasm** you will have label conflicts.

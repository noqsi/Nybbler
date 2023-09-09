## Compiler intermediate code

The compiler intermediate code is the way a compiler front end communicates with the common compiler back end. The compiler back end resolves labels and packs instructions into machine words. It may also perform additional optimization.

The compiler intermediate code is executable by the hardware if it uses no labels. It is, however, unpacked, so it doesn't use memory efficiently.

### 0-F Machine instructions
These have the numeric value of individual machine instructions, one instruction per word of intermediate code. Long instructions **C-F** are followed by a literal one word operand.

### 800-FFF Labels
These force word alignment and label the new current location.

### 10 Force alignment
Forces alignment without labeling the current location.

### 1C-1E Operand is label
The same as **C-E** except the following word is interpreted as a label rather than a literal constant.
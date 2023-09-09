#define NYBBLES 4		// 16 bit implementation
typedef nybble uint8_t;		// since there isn't a uint4_t
typedef word uint16_t;
typedef extword int32_t;	// extended word
#define CARRY_BIT( xw ) ( (xw) & 0x10000 )
#define WORD( xw ) ( (xw) & 0xffff )

// processor state

word pc;		// program counter
unsigned nybcount;	// unexecuted nybbles remaining in iword
word iword;	// instruction word
word sp;	// number stack pointer
word csp;	// call stack pointer
word carry;	// carry bit
word except_state;	// exception state
word except_mask;	// exception mask


// Fetch long instruction's operand

word fetch( void )
	
	switch( nybcount ) {
		
	case 0:
		return pmem[pc++];

	case 1:
		temp = iword & 0xf;
		if( temp & 0x8 ) temp |= 0xfff0;
		nybcount = 0;		// this will provake an instruction fetch
		return temp;

	case 2:
		temp = iword & 0xff;
		if( temp & 0x80 ) temp |= 0xff00;
		nybcount = 0;		// this will provake an instruction fetch
		return temp;

	case 3:
		temp = iword & 0xfff;
		if( temp & 0x800 ) temp |= 0xf000;
		nybcount = 0;		// this will provake an instruction fetch
		return temp;
	}
}

// Processor and I/O register support

word load_reg( word addr ){
	
}

void store_reg( word addr, word data ) {
	
}
	
// Execute an instruction

void execute( nybble opcode )		

	switch( opcode ) {
	
	case 0:		// nop
		break;
	
	case 1:		// exit
		pc = rs[ rsp-- ];
		break;
		
	case 2:		// tsz
		if( ns[ nsp-- ] == 0 ) {
		    if((iword & 0x8888 ) == 0x8 )   // long instruction in last slot
		        pc += 1;
		    nybcount = 0;   // skip remaining instructions in word
		break;
	
	case 3: 	// rs
		carry = ns[ nsp ] & 1;
		ns[ nsp ] = ns[ nsp ] >> 1
		break;
		
	case 4:		// add
		temp = ns[ nsp-- ];
		temp += ns[ nsp ];
		if( CARRY_BIT( temp )) carry = 1;
		else carry = 0;
		ns[ nsp ] = WORD( temp );
		break;
		
	case 5:		// neg
		temp = -ns[ nsp ];
		if( CARRY_BIT( temp )) carry = 1;
		else carry = 0;
		ns[ nsp ] = WORD( temp );
		break;
	
	case 6:		// and
		temp = ns[ nsp-- ];
		ns[ nsp ] &= temp;
		break;
		
	case 7:		// not
		ns[ nsp ] = WORD( ~ns[ nsp ] );
		break;
	
	case 8:		// load
		if( ns[ nsp ] < REGMEM )
			ns[ nsp ] = datamem[ ns[ nsp ]];
		else
			ns[ nsp ] = load_reg( ns[ nsp ] );
		break;
	
	case 9:		// store
		temp = ns[ nsp-- ];
		if( temp < REGMEM )
			datamem[ temp ] = ns[ nsp-- ];
		else
			store_reg( temp, ns[ nsp-- ]);
		break;
	
	case 10:	// swap
		temp = ns[ nsp ];
		ns[ nsp ] = ns[ nsp - 1];
		ns[ nsp - 1 ] = temp;
		break;
	
	case 11:	// dup
		temp = ns[ nsp++ ];
		ns[ nsp ] = temp;
		break;
	
	case 12:	// call
		temp = fetch();
		rs[++rsp] = pc;
		pc = temp;
		break;
	
	case 13:	// jump
		pc += fetch();
		break;
	
	case 14:	// lit
		ns[ ++nsp ] = fetch();
		break;
	
	case 15:	// ext
		(void) fetch();		// long nop for now
		break;
	
	default:
		fprintf( stderr, "Impossible instruction %d\n", nybble );
		exit( 1 );
	}
}


void icycle( void ) {
	
	iword = pmem[pc++];
	nybcount = 4;
	
	for( ;; ) {
		if( nybcount == 0 ) return;
		nybble opcode = 0xf & ( iword >> ( 4 * --nybcount ));
		execute( opcode );
	}
}	
	

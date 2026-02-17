#include "nyif.h"
#include <stdio.h>
#include <sysexits.h>
#include <stdlib.h>
#include <string.h>

#define MAXSTRING 1000

int main( int argc, char **argv ) {
	
	char ibuf[ MAXSTRING ], symbol[MAXSTRING];
	unsigned int address, data;
	char segment;
	int value;
	
	// Addresses of host calls
	
	unsigned int host_putc = -1;	// never matches 12 bits
	unsigned int host_getc = -1;
	unsigned int host_putx = -1;
	unsigned int host_exit = -1;
	unsigned int start_addr = 0;	// default to start at 0

	
	if( argc != 2 || strcmp( argv[1], "--help" ) == 0 ) {
		fprintf( stderr, "usage: nyrun file.nyobj [<data]\n" );
		exit( 1 );
	}
	
	FILE *obj = fopen( argv[1], "r" );
	if( obj == NULL ) {
		perror( argv[1] );
		exit( 1 );
	}

	ny_init();
	
	// There's no segment zero. Interface returns 0xbad for nonexistent
	// memory. So, this tests for a nybbler interface.
	
	if( ny_peek( 0, 0 ) != 0xbad ) {
		fprintf( stderr, "Can't talk to nybbler.\n" );
		exit( EX_UNAVAILABLE );
	}
	
	ny_put( 1, NYHALT );	// can't load memory if running
	
	while( fgets( ibuf, MAXSTRING, obj )) {
	
		if( ibuf[0] == '#' ) continue;
		
		// load program and initial data
		
		if( sscanf( ibuf, "%c %x %x", &segment, &address, &data  ) 
		== 3 ) {
			if( segment == 'I' )
				ny_poke( NYCODE, address, data );
			else if( segment == 'D' )
				ny_poke( NYDATA, address, data );
			continue;
		}
		
		// capture addresses of host calls
		
		if( sscanf( ibuf, "%999s = %d", symbol, &value ) == 2 ) {
		
			if( strcmp( symbol, "putc" ) == 0 )
				host_putc = value;
			else if( strcmp( symbol, "getc" ) == 0 )
				host_getc = value + 1;	// the halt is next
			else if( strcmp( symbol, "exit" ) == 0 )
				host_exit = value;
			else if( strcmp( symbol, "putx" ) == 0 )
				host_putx = value;
				
		// and the place to start
			else if( strcmp( symbol, "$start" ) == 0 )
				start_addr = value;

		}		
	}
	
	// Setup to run
	
	ny_poke( NYREGS, PC, start_addr );
	
	// Do it!
	
	ny_put( 1, NYSTART );
	
	for(;;) {	// poll for host requests
	
		if( ny_poll( 0 ) & RUNNING ) continue;
		
		address = ny_peek( NYREGS, PC );
		
		if( address == host_putc ) {
			ny_put( 1, NYHALT );
			putchar( ny_peek( NYREGS, TOS ));
			ny_poke( NYREGS, PC, address + 1 ); // past the halt
			ny_put( 1, NYSTART );
		}
		if( address == host_getc ) {
			ny_put( 1, NYHALT );
			int c = getchar();
			if( c == EOF ) c = 0xfff;	// EOF for nybbler
			ny_poke( NYREGS, TOS, c );
			ny_poke( NYREGS, PC, address + 1 ); // past the halt
			ny_put( 1, NYSTART );
		}
		else if( address == host_putx ) {
			ny_put( 1, NYHALT );
			printf( "%03hX", ny_peek( NYREGS, TOS ));
			ny_poke( NYREGS, PC, address + 1 ); // past the halt
			ny_put( 1, NYSTART );
		}
		else if( address == host_exit ) {
			ny_put( 1, NYHALT );
			exit( ny_peek( NYREGS, TOS ));
		}

// This doesn't work: the RUNNING bit is a bit glitchy.

//		else if( ( ny_poll( 0 ) & RUNNING ) == 0 ) {
//			fprintf( stderr, "Halted at %03X", address );
//			exit( 1 );
//		}
	}
}

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
	
	unsigned int host_putc, host_getc, host_putx, host_exit, start_addr;
	
	
	ny_init();
	
	// There's no segment zero. Interface returns 0xbad for nonexistent
	// memory. So, this tests for a nybbler interface.
	
	if( ny_peek( 0, 0 ) != 0xbad ) {
		fprintf( stderr, "Can't talk to nybbler.\n" );
		exit( EX_UNAVAILABLE );
	}
	
	ny_put( 1, NYHALT );	// can't load memory if running
	
	while( fgets( ibuf, MAXSTRING, stdin )) {
	
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
				host_getc = value;
			else if( strcmp( symbol, "exit" ) == 0 )
				host_exit = value;
			else if( strcmp( symbol, "start" ) == 0 )
				start_addr = value;
			else if( strcmp( symbol, "putx" ) == 0 )
				host_putx = value;
		}		
	}
	
	// Setup to run
	
	ny_poke( NYREGS, PC, start_addr );
	
	// Do it!
	
	ny_put( 1, NYSTART );
	
	for(;;) {	// poll for host requests
		address = ny_peek( NYREGS, PC );
		
		if( address == host_putc ) {
			ny_put( 1, NYHALT );
			putchar( ny_peek( NYREGS, TOS ));
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
	}
}

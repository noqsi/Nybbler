#include "nyif.h"
#include <stdio.h>
#include <sysexits.h>

#define MAXSTRING 1000

typedef struct {
	sym *link;
	char name[ MAXSTRING];
	int value;
	} sym;

int main( int argc, char **argv ) {
	
	char ibuf[ MAXSTRING ];
	int address, data;
	char segment;
	sym *newsym = NULL;
	
	ny_init();
	
	// There's no segment zero. Interface returns 0xbad for nonexistent
	// memory. So, this tests for a nybbler interface.
	
	if( ny_peek( 0, 0 ) != 0xbad ) {
		fprintf( stderr, "Can't talk to nybbler.\n" );
		exit( EX_UNAVAILABLE );
	}
	
	while( fgets( ibuf, MAXSTRING, stdin ) {
	
		if( ibuf[0] == # ) continue;
		
		if( sscanf( ibuf, "%c %x %x" ) == 3 ) {
		
		
		}
		
		
	
}

// #include "config.h"
#include <nyif.h>
#include <pigpio.h>
#include <sysexits.h>
#include <stdlib.h>

// Right shift for positive n, left for negative

#define SHIFT(x,n) (((n)>0)?(x)>>(n):(x)<<(-(n)))

#define MOVE_BIT(x,s,d) SHIFT(((x)&(1<<(s))),((s)-(d)))

// Bit	GPIO
// P7	18
// P6	22
// P5	23
// P4	10
// P3	9
// P2	7
// P1	19
// P0	16

static unsigned bits2gp( unsigned x ) {

	return
	MOVE_BIT( x, 7, 18 ) |
	MOVE_BIT( x, 6, 22 ) |
	MOVE_BIT( x, 5, 23 ) |
	MOVE_BIT( x, 4, 10 ) |
	MOVE_BIT( x, 3, 9 ) |
	MOVE_BIT( x, 2, 7 ) |
	MOVE_BIT( x, 1, 19 ) |
	MOVE_BIT( x, 0, 16 );

}

static unsigned gp2bits( unsigned x ) {

	return
	MOVE_BIT( x, 18, 7 ) |
	MOVE_BIT( x, 22, 6 ) |
	MOVE_BIT( x, 23, 5 ) |
	MOVE_BIT( x, 10, 4 ) |
	MOVE_BIT( x, 9, 3 ) |
	MOVE_BIT( x, 7, 2 ) |
	MOVE_BIT( x, 19, 1 ) |
	MOVE_BIT( x, 16, 0 );

}

#define PPDIR 20	// direction bit. 0 = read, 1 = write
#define PPCLK 21	// Pulse high for transfer
#define PPRSEL 17	// Register select bit

static void set_port_mode( unsigned mode ) {
	static unsigned current_mode = 9999;	// force init first time
	
	if( mode == current_mode ) return;
	
	if( mode == PI_OUTPUT ) gpioWrite( PPDIR, 1 );
	
	gpioSetMode( 18, mode );
	gpioSetMode( 22, mode );
	gpioSetMode( 23, mode );
	gpioSetMode( 10, mode );
	gpioSetMode( 9, mode );
	gpioSetMode( 7, mode );
	gpioSetMode( 19, mode );
	gpioSetMode( 16, mode );
	
	if( mode == PI_INPUT ) gpioWrite( PPDIR, 0);
	
	current_mode = mode;
}

// Byte level interface
// rs is register select (0 or 1), d is 8 bit contents

uint8_t ny_get( uint8_t rs ) {
	
	set_port_mode( PI_INPUT );
	
	gpioWrite( PPRSEL, rs );
	gpioWrite( PPCLK, 1 );
	gpioDelay( 1 );				// Give the port time to select
	uint8_t d = gp2bits( gpioRead_Bits_0_31() );
	gpioWrite( PPCLK, 0 );
	return d;
}

void ny_put( uint8_t rs, uint8_t d ) {
	
	set_port_mode( PI_OUTPUT );
	
	gpioWrite( PPRSEL, rs );
	gpioWrite_Bits_0_31_Clear( bits2gp( ~d ));
	gpioWrite_Bits_0_31_Set( bits2gp( d ));
	gpioWrite( PPCLK, 1 );
	gpioWrite( PPCLK, 0 );
}


// Read data passively without a clock

uint8_t ny_poll( uint8_t rs ) {

	set_port_mode( PI_INPUT );
	
	gpioWrite( PPRSEL, rs );
	return gp2bits( gpioRead_Bits_0_31() );
}

// 12 bit higher level

// set address

void ny_addr( uint16_t seg, uint16_t addr ) {
	uint16_t ua = seg | addr;
	ny_put( 0, ua>>8 );	// high byte to DR
	ny_put( 1, DR2ARX );	// move to AR high byte
	ny_put( 0, ua );	// low byte
	ny_put( 1, DR2AR );	// to AR low
}
	

uint16_t ny_peek( uint16_t seg, uint16_t addr ) {
	ny_addr( seg, addr );
	ny_put( 1, NYREAD );				// data to UDR
	return ( ny_get( 1 ) << 8 ) | ny_get( 0 );	// read UDR
}


void ny_poke( uint16_t seg, uint16_t addr, uint16_t data ) {
	ny_addr( seg, addr );
	data &= 0xfff;			// be careful
	ny_put( 0, data>>8 );		// high nybble
	ny_put( 1, DR2DRX );		// put it in the right place
	ny_put( 0, data );		// low byte
	ny_put( 1, NYWRITE );
}

uint16_t ny_status( void ) {
	return ( ny_poll( 1 ) << 8 ) | ny_poll( 0 );
}


void ny_init(void) {
	if (gpioInitialise() < 0) exit( EX_NOPERM );
	gpioWrite( PPCLK, 0 );		// inactive
	gpioWrite( PPDIR, 1 );		// tell FPGA not to drive
        gpioSetMode( PPCLK, PI_OUTPUT );	// Make sure
	gpioWrite( PPCLK, 0 );
        gpioSetMode( PPDIR, PI_OUTPUT );
	gpioWrite( PPDIR, 1 );
	gpioSetMode( PPRSEL, PI_OUTPUT);

}



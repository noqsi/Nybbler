#include "lse64.h"
#include "config.h"
#include <pigpio.h>

#define MOVE_BIT(x,s,d) (((x)&(1<<(s)))>>((s)-(d)))

// Bit	GPIO
// P8	17
// P7	18
// P6	22
// P5	23
// P4	10
// P3	9
// P2	7
// P1	19
// P0	16

static unsigned bits2gp( unsigned x ) {

	MOVE_BIT( x, 8, 17 ) |
	MOVE_BIT( x, 7, 18 ) |
	MOVE_BIT( x, 6, 22 ) |
	MOVE_BIT( x, 5, 23 ) |
	MOVE_BIT( x, 4, 10 ) |
	MOVE_BIT( x, 3, 9 ) |
	MOVE_BIT( x, 2, 7 ) |
	MOVE_BIT( x, 1, 19 ) |
	MOVE_BIT( x, 0, 16 )

}

static unsigned gp2bits( unsigned x ) {

	MOVE_BIT( x, 17, 8 ) |
	MOVE_BIT( x, 18, 7 ) |
	MOVE_BIT( x, 22, 6 ) |
	MOVE_BIT( x, 23, 5 ) |
	MOVE_BIT( x, 10, 4 ) |
	MOVE_BIT( x, 9, 3 ) |
	MOVE_BIT( x, 7, 2 ) |
	MOVE_BIT( x, 19, 1 ) |
	MOVE_BIT( x, 16, 0 )

}

#define PPDIR 20	// direction bit. 1 = read, 0 = write
#define PPCLK 21	// Pulse high for transfer

static int set_port_mode( unsigned mode ) {
	static unsigned current_mode = 9999;	// force init first time
	
	if( mode == current_mode ) return;
	
	if( mode == PI_OUTPUT ) gpioWrite( PPDIR, 0 );
	
	gpioSetMode( 17, mode );
	gpioSetMode( 18, mode );
	gpioSetMode( 22, mode );
	gpioSetMode( 23, mode );
	gpioSetMode( 10, mode );
	gpioSetMode( 9, mode );
	gpioSetMode( 7, mode );
	gpioSetMode( 19, mode );
	gpioSetMode( 16, mode );
	
	if( mode == PI_INPUT ) gpioWrite( PPDIR, 1);
	
	current_mode = mode;
}


static void read_ico( void ) {
	
	set_port_mode( PI_INPUT );
	
	gpio_write( PPCLK, 1 );
	*--sp = gp2bits( gpioRead_Bits_0_31() );
	gpio_write( PPCLK, 0 );
}

static void write_ico( void ) {
	
	set_port_mode( PI_OUTPUT );
	
	gpioWrite_Bits_32_53_Clear( bits2gp( ~*sp ));
	gpioWrite_Bits_32_53_Set( bits2gp( *sp++ ));
	gpio_write( PPCLK, 1 );
	gpio_write( PPCLK, 0 );
}

// Read data passively without a clock

static void poll_ico( void ) {
	set_port_mode( PI_INPUT );
	*--sp = gp2bits( gpioRead_Bits_0_31() );
}

static int pigpio_ok;

void __attribute__((constructor)) mod_init(void) {
	
	if (gpioInitialise() < 0)
	{
		pigpio_ok = 0;
	}
	else
	{
		pigpio_ok = 1;
	}
	
        build_primitive( read_ico, "ico-get" );
        build_primitive( write_ico, "ico-put" );
        build_primitive( poll_ico, "ico-poll" );

	gpio_write( PPCLK, 0 );		// inactive
	gpio_write( PPDIR, 0 );		// tell FPGA not to drive
        gpioSetMode( PPCLK, PI_OUTPUT );	// Make sure
	gpio_write( PPCLK, 0 );
        gpioSetMode( PPDIR, PI_OUTPUT );
	gpio_write( PPDIR, 0 );

}
	
/* Test function for LSE Module */
int lse_mod_test(void) { return pigpio_ok; }

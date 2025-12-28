#ifndef NYIF_H

#include <stdint.h>

// Command bits

#define DR2DRX   1 
#define DR2AR    2
#define DR2ARX   4
#define INCAR    8
#define NYREAD  16
#define NYWRITE 32
#define NYSTART 64
#define NYHALT  128

// Memory segments

#define NYDATA 0x1000
#define NYCODE 0x2000
#define NYSTACK 0x3000
#define NYRETURN 0x4000
#define NYREGS 0x5000

// Register addresses within the NYREGS segment

#define PC 0	// program counter
#define RSP 1	// return stack pointer
#define TOS 2	// top of stack
#define SP 3	// stack pointer

uint8_t ny_get( uint8_t rs );
void ny_put( uint8_t rs, uint8_t d );
uint8_t ny_poll( uint8_t rs );
void ny_addr( uint16_t seg, uint16_t addr );
uint16_t ny_peek( uint16_t seg, uint16_t addr );
void ny_poke( uint16_t seg, uint16_t addr, uint16_t data );
uint16_t ny_status( void );
void ny_init(void);

#endif // ndef NYIF_H

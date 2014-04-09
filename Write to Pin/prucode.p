// Original Source from Shabaz (www.element14.com/community)
.origin 0
.entrypoint START

#include "prucode.hp"

#define GPIO1 0x4804c000
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT 0x194
#define P8_11 0x0D



START:
    // Initialize
    LBCO       r0, CONST_PRUCFG, 4, 4
    CLR        r0, r0, 4
    SBCO       r0, CONST_PRUCFG, 4, 4
    MOV        r0, 0x00000120
    MOV        r1, CTPPR_0
    ST32       r0, r1
    MOV        r0, 0x00100000
    MOV        r1, CTPPR_1
    ST32       r0, r1
    LBCO       r0, CONST_DDR, 0, 12
    SBCO       r0, CONST_PRUSHAREDRAM, 0, 12



    // Act
    MOV  r1,   10 // loop 10 times
STEP:
    // set bits
    MOV  r2,   1<<P8_11
    MOV  r3,   GPIO1 | GPIO_SETDATAOUT
    SBBO r2,   r3, 0, 4

    MOV  r0,   0x00f00000
DEL1:
    // wait here until 0
    SUB  r0,   r0, 1
    QBNE DEL1, r0, 0

    // clear bits
    MOV  R2,   1<<P8_11
    MOV  r3,   GPIO1 | GPIO_CLEARDATAOUT
    SBBO r2,   r3, 0, 4

    MOV  r0,   0x00f00000
DEL2:
    // wait here until 0
    SUB  r0,   r0, 1
    QBNE DEL2, r0, 0

    // repeat
    SUB  r1,   r1, 1
    QBNE STEP, r1, 0

    // Send notification to Host for program completion
    MOV  r31.b0, PRU0_ARM_INTERRUPT+16

    // Finish
    HALT


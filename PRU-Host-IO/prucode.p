// ============================================================================
// Copyright (c) Texas Instruments Inc 2010-12
// Modified by TekuConcept 2014-6-16
//
// Use of this software is controlled by the terms and conditions found in the
// license agreement under which this software has been supplied or provided.
// ============================================================================

.origin 0
.entrypoint START

#include "prucode.hp"

#define GPIO1 0x4804c000
#define GPIO_CLEARDATAOUT 0x190
#define GPIO_SETDATAOUT 0x194


START:

    // Enable OCP master port
    LBCO      r0, CONST_PRUCFG, 4, 4
    CLR       r0, r0, 4         // Clear SYSCFG[STANDBY_INIT] to enable OCP master port
    SBCO      r0, CONST_PRUCFG, 4, 4

    // This will make C28 point to 0x00012000 (PRU shared RAM).
    MOV       r0, 0x00000120
    MOV       r1, CTPPR_0
    ST32      r0, r1
    // This will make C31 point to 0x80001000 (DDR memory).
    MOV       r0, 0x00100000
    MOV       r1, CTPPR_1
    ST32      r0, r1


    //Load values from external DDR Memory into Registers R0/R1/R2
    LBCO      r0, CONST_DDR, 0, 12
    //Store values from read from the DDR memory into PRU shared RAM
    SBCO      r0, CONST_PRUSHAREDRAM, 0, 12


    QBBC TURNOFF, r0.t0 // if 1 then turn on, else turn off
    SET  r30.t5         // turn on pin P9.27
    QBBS ENDLINE, r0.t0 // skip 'else' block

TRUNOFF:
    CLR r30.t5          // turn off pin P9.27

ENDLINE:

    // Send notification to Host for program completion
    MOV r31.b0, PRU0_ARM_INTERRUPT+16

    HALT

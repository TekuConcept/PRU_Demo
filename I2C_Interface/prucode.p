// ============================================================================
// Copyright (c) TekuConcept 2014-7
//
// Use of this software is controlled by the terms and conditions found in the
// license agreement under which this software has been supplied or provided.
//
// NOTE: There is no error handling in this demo including but not limited to:
// Access Errors (I2C_IRQSTATUS_RAW.AERR: 0x80), Invalid Slave Address(es),
// Invalid Data, or checking of alternate I2C_IRQSTATUS_RAW flags.
// ============================================================================

.origin 0
.entrypoint START

#include "prucode.hp"

#define I2C 0x4819C000
// I2C-1 = C2
// I2C-2 = C17

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


    // Enable ICLK & FCLK for I2C-2
    MOV       r0, 0x44E00000 // CM_PER_L4LS_CLOCKSTCTRL
    MOV       r1, 0x00000000
    SBBO      r1, r0, 0, 4
    MOV       r0, 0x44E00044 // CM_PER_I2C2_CLKCTRL
    MOV       r1, 0x00000002
    SBBO      r1, r0, 0, 4

    // Reset I2C Subsystem
    MOV       r1, 0x00000002
    SBCO      r1, C17, 0x10, 4 // I2C_SYSC

    // Wait for reset to complete
WAIT0:
    LBCO      r1, C17, 0x90, 4 // I2C_SYSS
    QBBC      WAIT0, r1.t0



    // [-- Set system settings --]
    // (Reset and Set procedures are needed to prevent fatal operating system crashes
    // or even worse, system corruption requiring a fresh OS reinstallation - use at
    // your own risk & backup any and all files as necessary)

    MOV       r1, 0x00000001  // (send address + 1 byte)
    SBCO      r1, C17, 0x98, 4 // I2C_CNT

    MOV       r1, 0x00000077  // (slave address for BMP180 sensor)
    SBCO      r1, C17, 0xAC, 4 // I2C_SA

    MOV       r1, 0x0000000B
    SBCO      r1, C17, 0xB0, 4 // I2C_PSC

    MOV       r1, 0x0000000D
    SBCO      r1, C17, 0xB4, 4 // I2C_SCLL

    MOV       r1, 0x0000000F
    SBCO      r1, C17, 0xB8, 4 // I2C_SCLH

    MOV       r1, 0x0000636F
    SBCO      r1, C17, 0x34, 4 // I2C_WE

    MOV       r1, 0x0000001D  // (re-enable internal clock)
    SBCO      r1, C17, 0x10, 4 // I2C_SYSC



    // [-- Begin write sequence --]

    MOV       r1, 0x00008601  // Enable I2C, set as Master/TX, and send Start command
    SBCO      r1, C17, 0xA4, 4 // I2C_CON

WAIT1:
    LBCO      r1, C17, 0x24, 4
    QBBC      WAIT1, r1.t4    // Wait for XRDY command
    SBCO      r1, C17, 0x28, 4 // CLEAR

    MOV       r1, 0x000000AA  // (send first address of slave register in BMP180)
    SBCO      r1, C17, 0x9C, 4 // I2C_DATA

WAIT2:
    LBCO      r1, C17, 0x24, 4
    QBBC      WAIT2, r1.t2    // Wait for ARDY command
    SBCO      r1, C17, 0x28, 4 // CLEAR

    MOV       r1, 0x00008602  // Send Stop command
    SBCO      r1, C17, 0xA4, 4 // I2C_CON

    // reset interrupts for read sequence testing
    LBCO      r1, C17, 0x24, 4
    SBCO      r1, C17, 0x28, 4



    // [-- Begin read sequence --]

    MOV       r1, 0x00008403  // Set as Master/RX, and send Start & Stop commands
    SBCO      r1, C17, 0xA4, 4 // I2C_CON

WAIT3:
    LBCO      r1, C17, 0x24, 4
    QBBC      WAIT3, r1.t3    // Wait for RRDY command
    SBCO      r1, C17, 0x28, 4 // CLEAR

    LBCO      r2, C17, 0x9C, 4 // I2C_DATA - read byte from RX queue (should be 0x1F)

WAIT4:
    LBCO      r1, C17, 0x24, 4
    QBBC      WAIT4, r1.t2    // Wait for ARDY command
    SBCO      r1, C17, 0x28, 4 // CLEAR



    // Store final value in RAM so user can view it
    SBCO      r2, CONST_PRUSHAREDRAM, 0, 4

    // Send notification to Host for program completion
    MOV r31.b0, PRU0_ARM_INTERRUPT+16

    HALT

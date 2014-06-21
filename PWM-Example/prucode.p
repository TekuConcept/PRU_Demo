.origin 0
.entrypoint START

#include "prucode.hp"

#define EPWMSS0 0x48300200
#define EPWMSS1 0x48302200
#define EPWMSS2 0x48304200

// Values aquired from AM335x_Technical Reference Manual Section 15.2.4
// Time-Base Submodule Registers (Section 15.2.4.1)
#define TBCTL   0x00 // Control (0xC000; count-up, free-run)
#define TBSTS   0x02 // Status  (0x0001; currently counting up)
#define TBPHSHR 0x04 // Extension for High-Res PWM Phase
#define TBPHS   0x06 // Phase
#define TBCNT   0x08 // Counter
#define TBPRD   0x0A // Period  (0xC350; 50000)

// Counter-Compare Submodule Registers (Section 15.2.4.2)
#define CMPCTL  0x0E // Control
#define CMPAHR  0x10 // Extension for High-Res PWM Counter-Compare A
#define CMPA    0x12 // A Channel (0x0000;     0 duty)
#define CMPB    0x14 // B Channel (0x61A8; 25000 duty)

// Action-Qualifier Submodule Registers (Section 15.2.4.3)
#define AQCTLA  0x16 // Control for Output A (EPWMxA)
#define AQCTLB  0x18 // Control for Output B (EPWMxB)
#define AQSFRC  0x1A // Software Force
#define AQCSFRC 0x1C // Continuous Software Force Set

// Dead-Band Generator Submodule Registers (Section 15.2.4.4)
#define DBCTL   0x1E // Control
#define DBRED   0x20 // Rising  Edge Delay Count
#define DBFED   0x22 // Falling Edge Delay Count

// Trip-Zone Submodule Registers (Section 15.2.4.5)
#define TZSEL   0x24 // Select
#define TZCTL   0x28 // Control
#define TZEINT  0x2A // Enable Interrupt
#define TZFLG   0x2C // Flag
#define TZCLR   0x2E // Clear
#define TZFRC   0x30 // Force

// Event-Trigger Submodule Registers (Section 15.2.4.6)
#define ETSEL   0x32 // Selection
#define ETPS    0x34 // Pre-Scale
#define ETFLG   0x36 // Flag
#define ETCLR   0x38 // Clear
#define ETFRC   0x3A // Force

// PWM-Chopper Submodule Registers (Section 15.2.4.7)
#define PCCTL   0x3C // Control

// High-Resolution PWM (HRPWM) Submodule Registers (Section 15.2.4.8)
#define HRCTL   0x40 // Control


START:
    LBCO       r0, CONST_PRUCFG, 4, 4
    CLR        r0, r0, 4
    SBCO       r0, CONST_PRUCFG, 4, 4

    // set pointer to read from host
    MOV        r0, 0x00000120
    MOV        r1, CTPPR_0
    ST32       r0, r1
    
    // set pointer to write back to host
    MOV        r0, 0x00100000
    MOV        r1, CTPPR_1
    ST32       r0, r1

    // set duty cycle for P8_13
    MOV  r0, EPWMSS2 | CMPB
    MOV  r1, 0x61A8 // 50% Duty (25000)
    SBBO r1, r0, 0, 2

    // set duty cycle for P8_19
    MOV  r0, EPWMSS2 | CMPA
    MOV  r1, 0xC350 //  0% Duty (50000)
    SBBO r1, r0, 0, 2

    // Send notification to Host for program completion
    MOV  r31.b0, PRU0_ARM_INTERRUPT+16

    // Finish
    HALT


/*
 * ============================================================================
 * Copyright (c) Texas Instruments Inc 2010-12
 * Modified by TekuConcept 2014-6-16
 *
 * Use of this software is controlled by the terms and conditions found in the
 * license agreement under which this software has been supplied or provided.
 * ============================================================================
 *
 *
 *
 * This  program  demonstraits  how   one   can   use   the   i2c   subsystems:
 * i2c-0,  i2c-1,  i2c-2.  The  fundimental   practice   involves   using   and
 * manipulating specific registers to the device(s).
 *
 * This demo. also  includes  how  one  can  even  access  the  i2c  interface.
 * (See Pgs 499 - 745 for Power, Reset, and  Clock  Management  (PRCM)  in  the 
 * Technical Reference Manual for details about Interfaces  and  clock  gating)
 * (See Pgs 3698 - 3767 for the I2C subsystem and interface  in  the  Technical
 * Reference Manual)
 *
 */

/******************************************************************************
* Include Files                                                               *
******************************************************************************/

// Standard header files
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

// Driver header file
#include "prussdrv.h"
#include <pruss_intc_mapping.h>

/******************************************************************************
* Local Macro Declarations                                                    *
******************************************************************************/

#define PRU_NUM 	 0

#define DDR_BASEADDR 0x80000000
#define OFFSET_DDR	 0x00001000 
#define OFFSET_SHAREDRAM 2048		//equivalent with 0x00002000

#define PRUSS0_SHARED_DATARAM    4

/******************************************************************************
* Local Function Declarations                                                 *
******************************************************************************/

static unsigned short LOCAL_examplePassed ( unsigned short pruNum );

static void *sharedMem;

static unsigned int *sharedMem_int;

/******************************************************************************
* Global Function Definitions                                                 *
******************************************************************************/

int main (void)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
    
    /* Initialize the PRU */
    prussdrv_init ();		
    
    /* Open PRU Interrupt */
    ret = prussdrv_open(PRU_EVTOUT_0);
    if (ret)
    {
        printf("prussdrv_open open failed\n");
        return (ret);
    }
    
    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);
    
    /* Execute example on PRU */
    prussdrv_exec_program (PRU_NUM, "./prucode.bin");

    /* Wait until PRU0 has finished execution */
    printf("\tINFO: Waiting for HALT command.\r\n");
    prussdrv_pru_wait_event (PRU_EVTOUT_0);
    prussdrv_pru_clear_event (PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);

    LOCAL_examplePassed(PRU_NUM) );
    prussdrv_pru_disable(PRU_NUM); 
    prussdrv_exit ();

    return(0);
}

/*****************************************************************************
* Local Function Definitions                                                 *
*****************************************************************************/

// called after PRU is finished
static int LOCAL_examplePassed ( unsigned short pruNum )
{
    unsigned int result_0, result_1, result_2;

     /* Allocate Shared PRU memory. */
    prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, &sharedMem);
    sharedMem_int = (unsigned int*) sharedMem;

    result_0 = sharedMem_int[OFFSET_SHAREDRAM];

    printf("INFO: %u\n", result_0);
    return(0);
}

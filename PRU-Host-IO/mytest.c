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
 * This program demonstraits how one can write a byte to the PRU and then read
 * a byte from the PRU. If a 1 is sent, the PRU will turn on the pin P9.27 and
 * visa-versa.
 *
 * This example only sends 1 byte during initialization and reads 1 byte when
 * finished, however to send or recieve a byte during runtime, use the
 * ARM-to-PRU and PRU-to-ARM interrupts.
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
#define USR_VALUE 	 0x00000001u

#define DDR_BASEADDR 0x80000000
#define OFFSET_DDR	 0x00001000 
#define OFFSET_SHAREDRAM 2048		//equivalent with 0x00002000

#define PRUSS0_SHARED_DATARAM    4

/******************************************************************************
* Local Function Declarations                                                 *
******************************************************************************/

static int LOCAL_exampleInit ( );
static unsigned short LOCAL_examplePassed ( unsigned short pruNum );

static int mem_fd;
static void *ddrMem, *sharedMem;

static unsigned int *sharedMem_int;

/******************************************************************************
* Global Function Definitions                                                 *
******************************************************************************/

int main (void)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;
    
    printf("\nINFO: Starting %s example.\r\n", "PRU_memAccess_DDR_PRUsharedRAM");
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

    /* Initialize example */
    printf("\tINFO: Initializing example.\r\n");
    LOCAL_exampleInit(PRU_NUM);
    
    /* Execute example on PRU */
    printf("\tINFO: Executing example.\r\n");
    prussdrv_exec_program (PRU_NUM, "./prucode.bin");

    /* Wait until PRU0 has finished execution */
    printf("\tINFO: Waiting for HALT command.\r\n");
    prussdrv_pru_wait_event (PRU_EVTOUT_0);
    printf("\tINFO: PRU completed transfer.\r\n");
    prussdrv_pru_clear_event (PRU_EVTOUT_0, PRU0_ARM_INTERRUPT);

    /* Check if example passed */
    if ( LOCAL_examplePassed(PRU_NUM) )
    {
        printf("Example executed succesfully.\r\n");
    }
    else
    {
        printf("Example failed.\r\n");
    }
    
    /* Disable PRU and close memory mapping*/
    prussdrv_pru_disable(PRU_NUM); 
    prussdrv_exit ();
    munmap(ddrMem, 0x0FFFFFFF);
    close(mem_fd);

    return(0);
}

/*****************************************************************************
* Local Function Definitions                                                 *
*****************************************************************************/

// called during initialization
static int LOCAL_exampleInit (  )
{
    void *DDR_regaddr1;	

    /* open the device */
    mem_fd = open("/dev/mem", O_RDWR);
    if (mem_fd < 0) {
        printf("Failed to open /dev/mem (%s)\n", strerror(errno));
        return -1;
    }	

    /* map the DDR memory */
    ddrMem = mmap(0, 0x0FFFFFFF, PROT_WRITE | PROT_READ, MAP_SHARED, mem_fd, DDR_BASEADDR);
    if (ddrMem == NULL) {
        printf("Failed to map the device (%s)\n", strerror(errno));
        close(mem_fd);
        return -1;
    }
    
    /* Store Addends in DDR memory location */
    DDR_regaddr1 = ddrMem + OFFSET_DDR;
    // To write additional data, create a new pointer and add sizeof(obj) to the end
    // For example: DDR_regaddr2 = ddrMEM + OFFSET_DDR + sizeof(unsigned int)

    *(unsigned long*) DDR_regaddr1 = USR_VALUE;
    // Then assign the value: *(unsigned long*) DDR_regaddr2 = USR_VALUE_2;

    return(0);
}

// called after PRU is finished
static unsigned short LOCAL_examplePassed ( unsigned short pruNum )
{
    unsigned int result_0, result_1, result_2;

     /* Allocate Shared PRU memory. */
    prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, &sharedMem);
    sharedMem_int = (unsigned int*) sharedMem;

    // read value from PRU and compare with orriginal value
    result_0 = sharedMem_int[OFFSET_SHAREDRAM];
    // To read additional values from the PRU, increment by 1
    // For example: result_1 = sharedMem_int[OFFSET_SHAREDRAM + 1];

    printf("INFO: %u : %u\n", result_0, USR_VALUE);

    return (result_0 == USR_VALUE);
}

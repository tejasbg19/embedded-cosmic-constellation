/***************************************************************************//**
* Linker file for the GNU C compiler.
********************************************************************************
/*--------------------- Flash Configuration ---------------------------------*/
__FLASH_START = 0x00000000;
__FLASH_SIZE =  0x00003000;
__TEJAS_START = 0x00003000;
__TEJAS_SIZE = 0x00020000 - 0x00003000;

/*--------------------- Embedded RAM Configuration ----------------------------*/
__RAM_START = 0x20000000;
__RAM_SIZE =  0x00004000; /* 16KB */

/*--------------------- Stack Configuration ---------------------------------*/
__STACK_SIZE = 0x00001000; /* 4KB */
__HEAP_SIZE = 0x00000200; /* 512B */

ENTRY(Reset_handler)

/* The MEMORY section below describes the location and size of blocks of memory in the target.
 * Use this section to specify the memory regions available for allocation.
 */
MEMORY
{
  FLASH (rx)  : ORIGIN = __FLASH_START, LENGTH = __FLASH_SIZE
  RAM   (rwx) : ORIGIN = __RAM_START,   LENGTH = __RAM_SIZE
  TEJAS(rx) : ORIGIN = __TEJAS_START, LENGTH = __TEJAS_SIZE    /* My own custom flash region with required start Address */
}

__STACK_START = __RAM_START + __RAM_SIZE;
__STACK_END = __STACK_START - __STACK_SIZE;

__HEAP_START = __STACK_END - __HEAP_SIZE;
__HEAP_END = __STACK_END;

SECTIONS
{
    .text :
    {
        KEEP(*(.isr_vector))
        *(.text*)
        *(.init*)
        *(.fini*)
		. = ALIGN(4);
		*(.rodata .rodata.*)  
        . = ALIGN(4);
        __etext = .;
    } > FLASH 

    _la_data = LOADADDR(.data);
	.data :
    {
        __data_start = .;
        *(.data*)
        . = ALIGN(4);
        __data_end = .;

    } > RAM AT> FLASH

    .bss :
    {
        __bss_start__ = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
        . = ALIGN(4);
        end = .;
        __end__ = .;
    } > RAM
	
/*================================Custom Section Memory Allotment=============== */

    __la_custom__ = LOADADDR(.custom_constellation);     /*load address (LMA) */
    .custom_constellation :
    {
        __custom_start__ = .;
        KEEP(*(.cosmic_constellation))
        . = ALIGN(4);
        __custom_end__ = .;
    } > RAM AT> TEJAS
	
/*===============================================================================*/    
    
    /* Dummy section for stack */
   
    Heap (NOLOAD) :
    {
        . = ABSOLUTE (__HEAP_START);
		*(.heap)
		. = ALIGN(4);

    } > RAM 
	
	/* Dummy section for stack */
    Stack (NOLOAD) :
    {
        . = ABSOLUTE (__STACK_END);
		*(.stack)
    } > RAM   
}

/* EOF */
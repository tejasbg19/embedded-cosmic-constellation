==============================
README – Cosmic Constellation Section Relocation
==============================

Author: Tejas B G
Course: Embedded Systems Design – Cohort 3
Assignment: 2 (Assignment on Startup & Linker)

--------------------------------------------------
1. Objective
--------------------------------------------------
To create a custom section named `.cosmic_constellation`, place it at a specific Flash
address (LMA = 0x00003000), and relocate it into SRAM at runtime (VMA = after .bss)
during system startup.

--------------------------------------------------
2. Dual-Placement (LMA vs VMA) Mechanism
--------------------------------------------------
- The section `.cosmic_constellation` was defined in the linker script as follows:

    __la_custom__ = LOADADDR(.custom_constellation);
    .custom_constellation :
    {
        __custom_start__ = .;
        KEEP(*(.cosmic_constellation))
        . = ALIGN(4);
        __custom_end__ = .;
    } > RAM AT> TEJAS

  → `AT> TEJAS` specifies that the section is stored in Flash (LMA).
  → The section itself is allocated in RAM (VMA).
  → Thus, the data is initially in Flash and copied to RAM during Reset.

--------------------------------------------------
3. Relocation in Reset_Handler
--------------------------------------------------
The `Reset_Handler` copies contents from Flash (LMA) to RAM (VMA) using the linker-defined
symbols. The copy occurs immediately after `.bss` is zeroed.

Code snippet:

    size = &__custom_end__ - &__custom_start__;
    pDst = (uint32_t *)&__custom_start__;
    pSrc = (uint32_t *)&__la_custom__;

    for(uint32_t i = 0; i < size; i++)
        *pDst++ = *pSrc++;

This ensures all initialized data in `.cosmic_constellation` is available in RAM before `main()` executes.

--------------------------------------------------
4. Linker Symbols Used
--------------------------------------------------
| Symbol            | Purpose / Role                          | Defined In |
|-------------------|------------------------------------------|-------------|
| __la_custom__     | Load address (Flash @ 0x00003000)        | Linker script |
| __custom_start__  | Start address of section in SRAM (VMA)   | Linker script |
| __custom_end__    | End address of section in SRAM (VMA)     | Linker script |

All these symbols are declared as `extern` in the startup file and used to locate and copy the section.

--------------------------------------------------
5. Verification in MAP File
--------------------------------------------------
Highlighted excerpt from `BareMetal.map`:

====================================================
>>> CUSTOM SECTION VERIFICATION START <<<



               0x00003000                        __la_custom__ = LOADADDR (.custom_constellation)

.custom_constellation
                0x20000014       0x14 load address 0x00003000
                0x20000014                        __custom_start__ = .
 *(.cosmic_constellation)
 .cosmic_constellation
                0x20000014       0x14 ./Application_Source/main.o
                0x20000014                custom_array
                0x20000028                        . = ALIGN (0x4)
                0x20000028                        __custom_end__ = .



>>> CUSTOM SECTION VERIFICATION END <<<
====================================================

This confirms that `.cosmic_constellation` has its
Load Memory Address (LMA) in Flash at `0x00003000`
and its Virtual Memory Address (VMA) in SRAM after `.bss`. @ 0x20000014

--------------------------------------------------
6. Caveats / Notes
--------------------------------------------------
- `ALIGN(4)` ensures proper 32-bit alignment.
- `KEEP()` prevents section removal during optimization.
- No overlap occurs between Flash and SRAM sections.
- Flash region (`TEJAS`) begins at 0x00003000.
- Verified via debugger: data successfully relocated
  from Flash to SRAM (values 0xA, 0xB, 0xC, 0xD, 0xE visible in RAM).

--------------------------------------------------
7. Runtime Verification
--------------------------------------------------
- `custom_array[5]` defined in `.cosmic_constellation`.
- Runtime variable `verify_custom` confirms access to relocated data.
- Debugger shows copied values in SRAM immediately after Reset.
-Relevant Images placed in same folder with appropriate names.

--------------------------------------------------
End of README
--------------------------------------------------

\# 🛰️ Cosmic Constellation Section Relocation



\*\*Author:\*\* Tejas B G  

\*\*Course:\*\* Embedded Systems Design – Cohort 3  

\*\*Organization:\*\* Infineon Technologies  

\*\*Target MCU:\*\* PSoC4000S Plus  

\*\*Toolchain:\*\* arm-none-eabi-gcc  



---



\## 🚀 Overview



This project demonstrates the \*\*creation and relocation of a custom data section\*\*  

named `.cosmic\_constellation`. The section is:



\- \*\*Stored in Flash\*\* initially (Load Memory Address, LMA = `0x00003000`)  

\- \*\*Relocated to SRAM\*\* during system startup (Virtual Memory Address, VMA = after `.bss`)  



At runtime, the relocated data is accessed and verified via a global variable inside `main()`.



---



\## 🧩 Project Structure



| File | Description | Links |

|------|--------------|

| `main.c` | Defines `custom\_array\[5]` in `.cosmic\_constellation` and uses it at runtime |\[main.c](./main.c) |

| `startup.c` | Contains `Reset\_Handler()` which copies `.cosmic\_constellation` from Flash → RAM | \[startup.c](./startup.c) |

| `linker\_script.ld` | Defines custom section placement and linker symbols | \[linker\_scripts.ld](./linker\_scripts.ld) |

| `BareMetal.map` | Shows proof of LMA (Flash) and VMA (RAM) | \[BareMetal.map](./BareMetal.map) |



---



\## 🧠 Concept Summary



Embedded systems with Harvard architectures store \*\*code \& constants in Flash\*\*  

and \*\*mutable data in RAM\*\*.  



This project implements:

\- Dual-placement of a section using the `AT>` directive in the linker script.

\- Explicit runtime relocation inside `Reset\_Handler`.

\- Verification of correct data transfer using debugger memory inspection.



---



\## ⚙️ Memory Placement Summary



| Section | Type | Storage | Runtime Location | Description |

|----------|------|----------|------------------|-------------|

| `.text` | Code | Flash | Flash | Executable instructions |

| `.data` | Initialized global data | Flash | SRAM | Copied by startup |

| `.bss` | Uninitialized data | N/A | SRAM | Zeroed at startup |

| `.rodata` | Constants | Flash | Flash | Read-only data |

| `.cosmic\_constellation` | Custom | Flash (0x00003000) | SRAM (after `.bss` @0x200000014) | Relocated custom array |



---



\## 🔭 Linker Symbol Roles



| Symbol | Description | Defined In |

|---------|--------------|-------------|

| `\_\_la\_custom\_\_` | Load address (Flash @ 0x00003000) | Linker script |

| `\_\_custom\_start\_\_` | Start of section in SRAM (VMA) | Linker script |

| `\_\_custom\_end\_\_` | End of section in SRAM | Linker script |



These symbols are declared `extern` in `startup.c` and used for relocation during system startup.



---



\## 🧮 Relocation Mechanism (in `Reset\_Handler`)



```c

extern uint32\_t \_\_custom\_start\_\_; //custom start address

extern uint32\_t \_\_custom\_end\_\_;   //custom section end in vma

extern uint32\_t \_\_la\_custom\_\_;   // custom sec addr in flash



&nbsp;size = \&\_\_custom\_end\_\_ - \&\_\_custom\_start\_\_;

&nbsp;    pDst = (uint32\_t\*)\&\_\_custom\_start\_\_;     

&nbsp;    pSrc = (uint32\_t\*)\&\_\_la\_custom\_\_;



&nbsp;   for(uint32\_t i = 0; i< size; i++)

&nbsp;   {

&nbsp;       \*pDst++ = \*pSrc++;

&nbsp;   }



```



---



\## 🧾 Dual-Placement in Linker Script



```ld

\_\_FLASH\_START = 0x00000000;

\_\_FLASH\_SIZE =  0x00003000;

\_\_TEJAS\_START = 0x00003000;

\_\_TEJAS\_SIZE = 0x00020000 - 0x00003000;  

&nbsp;\_\_la\_custom\_\_ = LOADADDR(.custom\_constellation);     /\*load address (LMA) \*/

MEMORY

{

&nbsp; FLASH (rx)  : ORIGIN = \_\_FLASH\_START, LENGTH = \_\_FLASH\_SIZE

&nbsp; RAM   (rwx) : ORIGIN = \_\_RAM\_START,   LENGTH = \_\_RAM\_SIZE

&nbsp; TEJAS(rx) : ORIGIN = \_\_TEJAS\_START, LENGTH = \_\_TEJAS\_SIZE    /\* My own custom flash region with required start Address \*/

}



SECTIONS

{

&nbsp;   .custom\_constellation :

&nbsp;   {

&nbsp;       \_\_custom\_start\_\_ = .;

&nbsp;       KEEP(\*(.cosmic\_constellation))

&nbsp;       . = ALIGN(4);

&nbsp;       \_\_custom\_end\_\_ = .;

&nbsp;   } > RAM AT> TEJAS

}

```



---



\## 🧠 Variable Analysis \& Runtime Behavior



| Variable | Memory Section | Type | Description / Expected Behavior |

|-----------|----------------|------|--------------------------------|

| `custom\_array\[5]` | `.cosmic\_constellation` | Initialized global | Stored in Flash (LMA), copied to RAM (VMA). Values: `{0xA, 0xB, 0xC, 0xD, 0xE}` |

| `var1` | `.data` | Initialized RW | Stored in Flash, copied to SRAM at startup |

| `var2` | `.bss` | Uninitialized RW | Defaulted to 0 by startup |

| `var3` | `.rodata` | Constant | Remains in Flash |

| `var6` | `.bss` | Volatile global | Used to observe live updates during runtime |

| `verify\_custom` | `.bss` | Volatile global | Used to confirm that relocated data in RAM is readable |

| `x` | Register/local | Computed | Sum of all elements in `custom\_array` |



---



\## 🧪 Expected Runtime Output (in Debugger)



| Memory | Address Range | Expected Content | Notes |

|---------|----------------|------------------|-------|

| \*\*Flash (LMA)\*\* | `0x00003000` – `0x00003014` | `0x0A 0x0B 0x0C 0x0D 0x0E` | Original `.cosmic\_constellation` data stored in Flash |

| \*\*RAM (VMA)\*\* | `0x20000014` – `0x20000028` | Same sequence copied by startup | Confirms relocation from Flash to RAM |

| \*\*Variable `verify\_custom`\*\* | Watch Window | `0x0000000A` | Confirms relocated data in `.cosmic\_constellation` is accessible at runtime |



At runtime, `verify\_custom` continually reads the first element of `custom\_array`,  

confirming successful relocation of `.cosmic\_constellation` from Flash (LMA) to RAM (VMA).



---



\## 🧾 Verification in MAP File



```map

&nbsp;               0x00003000                        \_\_la\_custom\_\_ = LOADADDR (.custom\_constellation)



.custom\_constellation

&nbsp;               0x20000014       0x14 load address 0x00003000

&nbsp;               0x20000014                        \_\_custom\_start\_\_ = .

&nbsp;\*(.cosmic\_constellation)

&nbsp;.cosmic\_constellation

&nbsp;               0x20000014       0x14 ./Application\_Source/main.o

&nbsp;               0x20000014                custom\_array

&nbsp;               0x20000028                        . = ALIGN (0x4)

&nbsp;               0x20000028                        \_\_custom\_end\_\_ = .

```





---



\## 🧰 Visual Proof (Screenshots)



<div align="center">

&nbsp; <img src="./Images/flash\_memory.png" alt="Flash content at 0x00003000" width="600" />

&nbsp; <p><b>Flash Memory (Before Relocation)</b></p>

</div>

<br>



<div align="center">

&nbsp; <img src="./Images/ram\_memory.png" alt="RAM content after relocation" width="600" />

&nbsp; <p><b>RAM Memory (After Relocation)</b></p>

</div>

<br>



<div align="center">

&nbsp; <img src="./Images/map\_highlight.png" alt="Map file showing LMA and VMA" width="600" />

&nbsp; <p><b>Map File Highlight (LMA/VMA Proof)</b></p>

</div>

<br>



<div align="center">

&nbsp; <img src="./Images/debug\_watch.png" alt="Watch window showing relocated variable values" width="600" />

&nbsp; <p><b>Watch Window – verify\_custom \& custom\_array Values</b></p>

</div>

<br>



---



\## ⚠️ Implementation Notes \& Caveats



\- `ALIGN(4)` ensures 32-bit alignment for proper access.  

\- `KEEP()` directive prevents linker from optimizing away `.cosmic\_constellation`.  

\- Custom Flash region `TEJAS` begins at `0x00003000`.  

\- Verified in debugger: Flash-to-RAM copy successful and accessible in runtime.  

\- No overlap or conflict between memory regions.  

\- `volatile` ensures live variable visibility during debugging.  



---



\## ✅ Summary



This implementation successfully:

\- Defines and places a custom section in Flash.

\- Relocates it to RAM during startup using linker symbols.

\- Verifies relocation via debugger and variable inspection.



\*\*Result:\*\* `.cosmic\_constellation` section correctly relocates from Flash → RAM  

and is accessible during program execution.



---



🧠 \*Developed \& verified by:\*  

\*\*Tejas B G\*\*  

Electronics \& Communication Engineering – DSATM  

Cohort 3 | Infineon Embedded Systems Design Course




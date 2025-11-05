#include <stdint.h>
//#include "./../Special_Libraries/reset.h"
//#include "../Add_Source/add.h"

uint8_t app_heap[512] __attribute__((section (".heap")));
uint8_t app_stack[1024] __attribute__((section (".stack")));


//========================Custom Section====================//

uint32_t custom_array[5] __attribute__((section (".cosmic_constellation"))) = {0xAu, 0xB, 0xC, 0xD, 0xE};

//==========================================================//

int x;

void Delay(uint32_t);
uint32_t var1 = 50u; 
uint32_t var2; 
const uint32_t var3 = 50u; 
volatile uint32_t var6; 
volatile uint32_t verify_custom = 0;

int main()
{
    uint32_t var4 = 0; 
    uint32_t var5; 
    for(;;)
    {

        Delay(15492);

 //===============================Custom Array Elements used=========================// 
        x = 0;
        verify_custom = custom_array[0];
        for(int i=0; i<5; i++)  x = x + custom_array[i];
        var5 = var1 + var2 + var3+ var4+ custom_array[4];
        var6 = var5 + 50u + custom_array[2]+ custom_array[0];
       

//====================================================================================//       
    }

    return 0;
}

void Delay(uint32_t delayNumber)
{
    for(uint32_t i=0; i<delayNumber; i++);
    for(uint32_t i=0; i<delayNumber; i++);
}



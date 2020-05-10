//-----------------------------------------------------------------------------
#include <stdlib.h>
#include "lib/avr-misc/avr-misc.h"
#include "lib/avr-debug/debug.h"
//-----------------------------------------------------------------------------
int main()
{
    DEBUG_INIT();

    // add initializations here
    // ...

    enable_interrupts();

    while(1)
    {
        // add routings here
        // ...
    }

    return 0;
}
//-----------------------------------------------------------------------------

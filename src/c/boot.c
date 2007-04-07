#include "stdlib.h"

void C_entry();
int boot_addr;
extern void* __end__;
//extern void* __ewram_end

extern void *textstart;//points to first GB rom (initialized by boot.s)
extern void *ewram_textstart;

int main(int argc, char**argv)
{
//	if (boot_addr>=0x08000000)
//	{
		ewram_textstart=__end__;
		textstart= (void*)  (((int)__end__&0x00FFFFFF)+boot_addr);
//	}
	C_entry();
}
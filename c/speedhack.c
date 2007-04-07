#include "gba.h"
#include <string.h>

extern u32 num_speedhacks;
extern u16 speedhacks[256];
extern u8 g_hackflags;

const u8 instructions_with_size_2[]={
0x06,0x0E,0x16,0x18,0x1E,0x20,0x26,0x28,0x2E,0x30,0x36,0x38,0x3E,0xC6,0xCB,0xCE,
0xD6,0xDE,0xE0,0xE6,0xE8,0xEE,0xF0,0xF6,0xF8,0xFE
};
const u8 instructions_with_size_3[]={
0x01,0x08,0x11,0x21,0x31,0xC2,0xC3,0xC4,0xCA,0xCC,0xCD,0xD2,0xD4,0xDA,0xDC,0xEA,0xFA
};

const u8 whitelist[]={
5,4,
0xF0,0x41,0xE6,0x02, //lcd status polling
0xF0,0x41,0xE6,0x03,
0xF0,0x41,0xE6,0x04,
0xF0,0x41,0xCB,0x4F,
0xF0,0x41,0xCB,0x57,
1,2,
0xF0,0x44, //scanline polling
0
};

const u8 graylist[]={
18,1,
0xDC, //call
0xD4,
0xC4,
0xCC,
0xCD,
0xC7, //rst
0xCF,
0xD7,
0xDF,
0xE7,
0xEF,
0xF7,
0xFF,
0x23, //inc hl
0x09, //add hl,*
0x19,
0x29,
0x39,
0
};


const u8 blacklist[]={
14,1,
0xE8, //anything that affects SP
0x3B,
0x33,
0xF9,
0x31,
0xF8,
0xC3, //unconditional jr,jp,ret
0x18,
0xC9,
0x76, //halt
0x2A, //ldi, ldd
0x22,
0x3A,
0x32,
6,3,
0x0B,0x78,0xB1, //dec rr, ld a,r, or r
0x0B,0x79,0xB0,
0x1B,0x7A,0xB3,
0x1B,0x7B,0xB2,
0x2B,0x7C,0xB5,
0x2B,0x7D,0xB4,
29,2,
0xF0,0x4D, //double speed polling
0x3D,0xC2, //dec r, jr *,*
0x3D,0xCA,
0x3D,0x20,
0x3D,0x28,
0x05,0xC2,
0x05,0xCA,
0x05,0x20,
0x05,0x28,
0x0D,0xC2,
0x0D,0xCA,
0x0D,0x20,
0x0D,0x28,
0x15,0xC2,
0x15,0xCA,
0x15,0x20,
0x15,0x28,
0x1D,0xC2,
0x1D,0xCA,
0x1D,0x20,
0x1D,0x28,
0x25,0xC2,
0x25,0xCA,
0x25,0x20,
0x25,0x28,
0x2D,0xC2,
0x2D,0xCA,
0x2D,0x20,
0x2D,0x28,
0
};

//jp
const u8 jplist[]= {
0xC2,
//0xC3,
0xCA,
0xD2,
0xDA
//0xE9
};
//jr
const u8 jrlist[]= {
//0x18
0x20,
0x28,
0x30,
0x38
};

extern u8* romstart;

#define binsearch(xxxx,yyyy) binsearch_(xxxx,yyyy,sizeof(xxxx)/sizeof(u8))
     
int binsearch_(const u8* list, u8 lookfor, size_t listsize)
{
	int i,l=0,r=listsize;
	do
	{
		i=(l+r)/2;
		if (list[i]==lookfor) return i;
		else if (list[i]>lookfor)
		{
			r=i-1;
		}
		else
		{
			l=i+1;
		}
	} while (l<=r);
	return -1;
}

int instruction_size(u8 instruction)
{
	int i=binsearch(instructions_with_size_2,instruction);
	if (i>-1) return 2;
	i=binsearch(instructions_with_size_3,instruction);
	if (i>-1) return 3;
	return 1;
}


//returns 1 or 0
int match(const u8 *mem, const u8* patterns, int startaddr, int length)
{
	int addrbase;
	int addrend;
	int addr;
	const u8 *pattern;
	int p;
	int numpatterns;
	int onpattern;
	int patternstart=0;
	int patternlength;
	
	numpatterns=patterns[patternstart];
	patternstart++;
	while (numpatterns!=0)
	{
		patternlength=patterns[patternstart];
		patternstart++;
		for (onpattern=0; onpattern<numpatterns; onpattern++)
		{
			pattern=&(patterns[patternstart]);
			addrend=startaddr+length-patternlength;
			for (addrbase=startaddr; addrbase<addrend; addrbase+=instruction_size(mem[addrbase]))
			{
				addr=addrbase;
				p=0;
				while (mem[addr]==pattern[p] && p<patternlength)
				{
					p++;
					addr++;
				}
				if (p==patternlength)
				{
					return 1;
				}
			}
			patternstart+=patternlength;
		}
		numpatterns=patterns[patternstart];
		patternstart++;
	}
	return 0;
}

//returns 0-7, bit 0 = wl, bit 1 = gl, bit 2 = bl
int hacktest(const u8 *mem, int startaddr, int length)
{
	int wl,gl,bl;
	//verify if even adds up to the branch again...
	int i,addthis;
	i=startaddr;
	while (i<startaddr+length-1)
	{
		addthis=instruction_size(mem[i]);
		i+=addthis;
	}
	if (i!=startaddr+length || addthis!=2)
	{
		return 6;
	}
	wl=match(mem,whitelist,startaddr,length);
	gl=match(mem,graylist,startaddr,length);
	bl=match(mem,blacklist,startaddr,length);
	return (wl+bl*2+gl*4);
}

void cpuhack_reset();

void find_speedhacks()
{
	const u8* mem=romstart;
	u8 i1;
	s8 rel;
	int h;
	int matched;
	int addr;
	num_speedhacks=0;
	if (g_hackflags&2)
	{
		g_hackflags=g_hackflags&~2;
		cpuhack_reset();
		return;
	}
	
	//just JR hacks for now, ignore JP
	for (addr=0x0;addr<16383;addr++)
	{
		i1 = mem[addr];
		if (binsearch(jrlist,i1)!=-1)
		{
			rel= ((s8*)mem)[addr+1];
			if (-rel <= 11 && -rel > 2)
			{
				h=hacktest(mem,addr+2+rel,-rel);
				matched=1;
				if (h&4) matched=0;
				if (h&2) matched=0;
				if (h&1) matched=0;
				if (matched && num_speedhacks<256)
				{
					speedhacks[num_speedhacks]=addr+2+rel;
					num_speedhacks++;
				}
				
			}
		}
	}
	
	if (num_speedhacks) g_hackflags|=2;
	cpuhack_reset();

}


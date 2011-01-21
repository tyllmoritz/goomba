#include <string.h>
#include "gba.h"
#include "minilzo.107/minilzo.h"
#include "stateheader.h"

#define STATEID 0x57a731d8

#define STATESIZE 0xc24c //from equates.h
#define STATEPTR ((u8*)(0x2040000-STATESIZE)) // from equates.h

#define STATESAVE 0
#define SRAMSAVE 1
#define CONFIGSAVE 2
#define MBC_SAV 2
#define PALETTE 5

#define GLOBAL_CHECKSUM 0x14E

#define TITLE 0x134
#define CHECKSUMS 0x4f
#define NORMAL_CHECKSUMS 0x41
#define SPECIAL_TABLE 29
#define FINAL_TABLE 94
#define PALETTE_INDEX (29*3)
#define PALETTE_DICTIONARY (30*8)

u8 checksum_table[] = {
	// normal
	0x00, 0x88, 0x16, 0x36, 0xD1, 0xDB, 0xF2, 0x3C, 0x8C, 0x92, 0x3D, 0x5C, 0x58, 0xC9,
	0x3E, 0x70, 0x1D, 0x59, 0x69, 0x19, 0x35, 0xA8, 0x14, 0xAA, 0x75, 0x95, 0x99, 0x34,
	0x6F, 0x15, 0xFF, 0x97, 0x4B, 0x90, 0x17, 0x10, 0x39, 0xF7, 0xF6, 0xA2, 0x49, 0x4E,
	0x43, 0x68, 0xE0, 0x8B, 0xF0, 0xCE, 0x0C, 0x29, 0xE8, 0xB7, 0x86, 0x9A, 0x52, 0x01,
	0x9D, 0x71, 0x9C, 0xBD, 0x5D, 0x6D, 0x67, 0x3F, 0x6B,
	// special
	0xB3, 0x46, 0x28, 0xA5, 0xC6, 0xD3, 0x27, 0x61, 0x18, 0x66, 0x6A, 0xBF, 0x0D, 0xF4
};

u8 special_table[] = {
	0x42, 0x45, 0x46, 0x41, 0x41, 0x52, 0x42, 0x45, 0x4B, 0x45, 0x4B, 0x20, 0x52, 0x2D,
	0x55, 0x52, 0x41, 0x52, 0x20, 0x49, 0x4E, 0x41, 0x49, 0x4C, 0x49, 0x43, 0x45, 0x20,
	0x52
};

u8 final_table[] = {
	0x7C, 0x08, 0x12, 0xA3, 0xA2, 0x07, 0x87, 0x4B, 0x20, 0x12, 0x65, 0xA8, 0x16, 0xA9,
	0x86, 0xB1, 0x68, 0xA0, 0x87, 0x66, 0x12, 0xA1, 0x30, 0x3C, 0x12, 0x85, 0x12, 0x64,
	0x1B, 0x07, 0x06, 0x6F, 0x6E, 0x6E, 0xAE, 0xAF, 0x6F, 0xB2, 0xAF, 0xB2, 0xA8, 0xAB,
	0x6F, 0xAF, 0x86, 0xAE, 0xA2, 0xA2, 0x12, 0xAF, 0x13, 0x12, 0xA1, 0x6E, 0xAF, 0xAF,
	0xAD, 0x06, 0x4C, 0x6E, 0xAF, 0xAF, 0x12, 0x7C, 0xAC, 0xA8, 0x6A, 0x6E, 0x13, 0xA0,
	0x2D, 0xA8, 0x2B, 0xAC, 0x64, 0xAC, 0x6D, 0x87, 0xBC, 0x60, 0xB4, 0x13, 0x72, 0x7C,
	0xB5, 0xAE, 0xAE, 0x7C, 0x7C, 0x65, 0xA2, 0x6C, 0x64, 0x85
};

u8 palette_indexes[] = {
	0x80, 0xB0, 0x40, 0x88, 0x20, 0x68, 0xDE, 0x00, 0x70, 0xDE, 0x20, 0x78, 0x20,
	0x20, 0x38, 0x20, 0xB0, 0x90, 0x20, 0xB0, 0xA0, 0xE0, 0xB0, 0xC0, 0x98, 0xB6,
	0x48, 0x80, 0xE0, 0x50, 0x1E, 0x1E, 0x58, 0x20, 0xB8, 0xE0, 0x88, 0xB0, 0x10,
	0x20, 0x00, 0x10, 0x20, 0xE0, 0x18, 0xE0, 0x18, 0x00, 0x18, 0xE0, 0x20, 0xA8,
	0xE0, 0x20, 0x18, 0xE0, 0x00, 0x20, 0x18, 0xD8, 0xC8, 0x18, 0xE0, 0x00, 0xE0,
	0x40, 0x28, 0x28, 0x28, 0x18, 0xE0, 0x60, 0x20, 0x18, 0xE0, 0x00, 0x00, 0x08,
	0xE0, 0x18, 0x30, 0xD0, 0xD0, 0xD0, 0x20, 0xE0, 0xE8
};

u8 palette_dictionary[] = {
	0xFF, 0x7F, 0xBF, 0x32, 0xD0, 0x00, 0x00, 0x00,
	0x9F, 0x63, 0x79, 0x42, 0xB0, 0x15, 0xCB, 0x04,
	0xFF, 0x7F, 0x31, 0x6E, 0x4A, 0x45, 0x00, 0x00,
	0xFF, 0x7F, 0xEF, 0x1B, 0x00, 0x02, 0x00, 0x00,
	0xFF, 0x7F, 0x1F, 0x42, 0xF2, 0x1C, 0x00, 0x00,
	0xFF, 0x7F, 0x94, 0x52, 0x4A, 0x29, 0x00, 0x00,
	0xFF, 0x7F, 0xFF, 0x03, 0x2F, 0x01, 0x00, 0x00,
	0xFF, 0x7F, 0xEF, 0x03, 0xD6, 0x01, 0x00, 0x00,
	0xFF, 0x7F, 0xB5, 0x42, 0xC8, 0x3D, 0x00, 0x00,
	0x74, 0x7E, 0xFF, 0x03, 0x80, 0x01, 0x00, 0x00,
	0xFF, 0x67, 0xAC, 0x77, 0x13, 0x1A, 0x6B, 0x2D,
	0xD6, 0x7E, 0xFF, 0x4B, 0x75, 0x21, 0x00, 0x00,
	0xFF, 0x53, 0x5F, 0x4A, 0x52, 0x7E, 0x00, 0x00,
	0xFF, 0x4F, 0xD2, 0x7E, 0x4C, 0x3A, 0xE0, 0x1C,
	0xED, 0x03, 0xFF, 0x7F, 0x5F, 0x25, 0x00, 0x00,
	0x6A, 0x03, 0x1F, 0x02, 0xFF, 0x03, 0xFF, 0x7F,
	0xFF, 0x7F, 0xDF, 0x01, 0x12, 0x01, 0x00, 0x00,
	0x1F, 0x23, 0x5F, 0x03, 0xF2, 0x00, 0x09, 0x00,
	0xFF, 0x7F, 0xEA, 0x03, 0x1F, 0x01, 0x00, 0x00,
	0x9F, 0x29, 0x1A, 0x00, 0x0C, 0x00, 0x00, 0x00,
	0xFF, 0x7F, 0x7F, 0x02, 0x1F, 0x00, 0x00, 0x00,
	0xFF, 0x7F, 0xE0, 0x03, 0x06, 0x02, 0x20, 0x01,
	0xFF, 0x7F, 0xEB, 0x7E, 0x1F, 0x00, 0x00, 0x7C,
	0xFF, 0x7F, 0xFF, 0x3F, 0x00, 0x7E, 0x1F, 0x00,
	0xFF, 0x7F, 0xFF, 0x03, 0x1F, 0x00, 0x00, 0x00,
	0xFF, 0x03, 0x1F, 0x00, 0x0C, 0x00, 0x00, 0x00,
	0xFF, 0x7F, 0x3F, 0x03, 0x93, 0x01, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x42, 0x7F, 0x03, 0xFF, 0x7F,
	0xFF, 0x7F, 0x8C, 0x7E, 0x00, 0x7C, 0x00, 0x00,
	0xFF, 0x7F, 0xEF, 0x1B, 0x80, 0x61, 0x00, 0x00
};

extern u8 g_cartflags;	//(from GB header)
extern int bcolor;		//Border Color
extern int palettebank;	//Palette for DMG games
extern u8 *dgbmaxpalettes;
extern u8 **gbpalettes;
extern u8 gammavalue;	//from lcd.s
extern u8 custompal;	//from lcd.s
extern u8 presetpal;	//from lcd.s
extern u8 dgbmaxpal;	//from lcd.s
extern u8 gbadetect;	//from gb-z80.s
extern u8 stime;		//from ui.c
extern u8 autostate;	//from ui.c
extern u8 *textstart;	//from main.c

extern char pogoshell;	//main.c
extern u32 borders;
extern u32 palettes;
extern u32 dgbpalettes;

int totalstatesize;		//how much SRAM is used

//-------------------
u8 *findrom(int);
void cls(int);		//main.c
void drawtext(int,char*,int);
void setdarknessgs(int dark);
void scrolll(int f);
void scrollr(void);
void waitframe(void);
u32 getmenuinput(int);
void writeconfig(void);
void setup_sram_after_loadstate(void);

extern int roms;		//main.c
extern int selected;	//ui.c
extern char pogoshell_romname[32];	//main.c
//----asm stuff------
int savestate(void);		//cart.s
void loadstate(int);		//cart.s
void paletteinit(void);		//lcd.s
void PaletteTxAll(void);	//lcd.s

extern u8 *romstart;	//from cart.s
extern u32 romnum;	//from cart.s
extern u32 frametotal;	//from gb-z80.s
//-------------------

typedef struct {		//(modified stateheader)
	u16 size;
	u16 type;	//=CONFIGSAVE
	char bordercolor;
	char palettebank;
	char misc;
	char reserved3;
	u32 sram_checksum;	//checksum of rom using SRAM e000-ffff	
	u32 zero;	//=0
	char reserved4[32];  //="CFG"
} configdata;

//we have a big chunk of memory starting after Image$$RO$$Limit free to use
u8 *buffer1;
u8 *buffer2;

void bytecopy(u8 *dst,u8 *src,int count) {
	int i=0;
	do {
		dst[i]=src[i];
		i++;
	} while(--count);
}

/*
void debug_(u32 n,int line);
void errmsg(char *s) {
	int i;

	drawtext(32+9,s,0);
	for(i=30;i;--i)
		waitframe();
	drawtext(32+9,"                     ",0);
}*/

void getsram() {		//copy GBA sram to buffer1
	u8 *sram=MEM_SRAM;
	u8 *buff1=buffer1;
	u32 *p;

	p=(u32*)buff1;
	if(*p!=STATEID) {	//if sram hasn't been copied already
		bytecopy(buff1,sram,0xe000);	//copy everything to buffer1
		if(*p!=STATEID) {	//valid savestate data?
			*p=STATEID;	//nope.  initialize
			*(p+1)=0;
		}
	}
}

//quick & dirty rom checksum
u32 checksum(u8 *p) {
	u32 sum=0;
	int i;
	for(i=0;i<128;i++) {
		sum+=*p|(*(p+1)<<8)|(*(p+2)<<16)|(*(p+3)<<24);
		p+=128;
	}
	return sum;
}

void writeerror() {
	int i;
	cls(2);
	drawtext(32+9,"  Write error! Memory full.",0);
	drawtext(32+10,"     Delete some games.",0);
	for(i=90;i;--i)
		waitframe();
}

/* (buffer1=copy of GBA SRAM, buffer2=new data)
   overwrite:  index=state#, erase=0
   new:  index=big number (anything >=total saves), erase=0
   erase:  index=state#, erase=1
   returns TRUE if successful
   IMPORTANT!!! totalstatesize is assumed to be current
   */
/* Update: inplace alteration through append */
int updatestates(int index,int erase,int type) {
	int i;
	int srcsize;
	int total=totalstatesize;
	u8 *src=buffer1;
	u8 *dst;
	stateheader *newdata=(stateheader*)buffer2;

	src+=4;//skip STATEID

	//skip ahead to where we want to write

	srcsize=((stateheader*)src)->size;
	i=(type==((stateheader*)src)->type)?0:-1;
	while(i<index && srcsize) {	//while (looking for state) && (not out of data)
		src+=srcsize;
		srcsize=((stateheader*)src)->size;
		if(((stateheader*)src)->type==type)
			i++;
	}

	dst=src;
	src+=srcsize;
	total-=srcsize;
	
	srcsize=((stateheader*)src)->size;
	
	//copy everything past i to buffer1
	while(srcsize) {
		memcpy(dst,src,srcsize);
		dst+=srcsize;
		src+=srcsize;
		srcsize=((stateheader*)src)->size;
	}
	
	// Append, if appropriate
	if(!erase) {
		srcsize = newdata->size;
		total += srcsize;
		if(total > 0xe000) //**OUT OF MEMORY**
			return 0;
		memcpy(dst, newdata, srcsize);
		dst += srcsize;
	}

	*(u32*)dst=0;	//terminate
	dst+=4;

	//copy everything to GBA sram

	totalstatesize=total;
	while(total<0xe000)
	{
		*dst++=0;
		total++;
	}
	bytecopy(MEM_SRAM,buffer1,total);	//copy to sram
	return 1;
}

//more dumb stuff so we don't waste space by using sprintf
int twodigits(int n,char *s) {
	int mod=n%10;
	n=n/10;
	*(s++)=(n+'0');
	*s=(mod+'0');
	return n;
}

void getstatetimeandsize(char *s,int time,u32 size,u32 totalsize) {
	strcpy(s,"00:00:00 - 00/00k");
	twodigits(time/216000,s);
	s+=3;
	twodigits((time/3600)%60,s);
	s+=3;
	twodigits((time/60)%60,s);
	s+=5;
	twodigits(size/1024,s);
	s+=3;
	twodigits(totalsize/1024,s);
}

#define LOADMENU 0
#define SAVEMENU 1
#define SRAMMENU 2
#define FIRSTLINE 2
#define LASTLINE 16

//buffer1 holds copy of SRAM
//draw save/loadstate menu and update global totalstatesize
//returns a pointer to current selected state
//update *states on exit
stateheader* drawstates(int menutype,int *menuitems,int *menuoffset) {
	int type;
	int offset=*menuoffset;
	int sel=selected;
	int startline;
	int size;
	int statecount;
	int total;
	char s[30];
	stateheader *selectedstate;
	int time;
	int selectedstatesize;
	stateheader *sh=(stateheader*)(buffer1+4);

	type=(menutype==SRAMMENU)?SRAMSAVE:STATESAVE;

	statecount=*menuitems;
	if(sel-offset>LASTLINE-FIRSTLINE-3 && statecount>LASTLINE-FIRSTLINE+1) {		//scroll down
		offset=sel-(LASTLINE-FIRSTLINE-3);
		if(offset>statecount-(LASTLINE-FIRSTLINE+1))	//hit bottom
			offset=statecount-(LASTLINE-FIRSTLINE+1);
	}
	if(sel-offset<3) {				//scroll up
		offset=sel-3;
		if(offset<0)					//hit top
			offset=0;
	}
	*menuoffset=offset;
	
	startline=FIRSTLINE-offset;
	cls(2);
	statecount=0;
	total=8;	//header+null terminator
	while(sh->size) {
		size=sh->size;
		if(sh->type==type) {
			if(startline+statecount>=FIRSTLINE && startline+statecount<=LASTLINE) {
				drawtext(32+startline+statecount,sh->title,sel==statecount);
			}
			if(sel==statecount) {		//keep info for selected state
				time=sh->framecount;
				selectedstatesize=size;
				selectedstate=sh;
			}
			statecount++;
		}
		total+=size;
		sh=(stateheader*)((u8*)sh+size);
	}

	if(sel!=statecount) {//not <NEW>
		getstatetimeandsize(s,time,selectedstatesize,total);
		drawtext(32+18,s,0);
	}
	if(statecount)
		drawtext(32+19,"Push SELECT to delete",0);
	if(menutype==SAVEMENU) {
		if(startline+statecount<=LASTLINE)
			drawtext(32+startline+statecount,"<NEW>",sel==statecount);
		drawtext(32,"Save state:",0);
		statecount++;	//include <NEW> as a menuitem
	} else if(menutype==LOADMENU) {
		drawtext(32,"Load state:",0);
	} else {
		drawtext(32,"Erase SRAM:",0);
	}
	*menuitems=statecount;
	totalstatesize=total;
	return selectedstate;
}

//compress src into buffer2 (adding header), using 64k of workspace
void compressstate(lzo_uint size,u16 type,u8 *src,void *workspace) {
	lzo_uint compressedsize;
	stateheader *sh;

	if (workspace == NULL) {
		memcpy(buffer2+sizeof(stateheader),src,size);
		compressedsize=size;
	} else {
		lzo1x_1_compress(src,size,buffer2+sizeof(stateheader),&compressedsize,workspace);	//workspace needs to be 64k
	}

	//setup header:
	sh=(stateheader*)buffer2;
	sh->size=(compressedsize+sizeof(stateheader)+3)&~3;	//size of compressed state+header, word aligned
	sh->type=type;
	sh->compressedsize=compressedsize;	//size of compressed state
	sh->framecount=frametotal;
	sh->checksum=checksum((u8*)romstart);	//checksum
    if(pogoshell)
    {
		strcpy(sh->title,pogoshell_romname);
    }
    else
    {
		strncpy(sh->title,(char*)findrom(romnum)+0x134,15);
    }
}

void managesram() {
	int i;
	int menuitems;
	int offset=0;

	getsram();

	selected=0;
	drawstates(SRAMMENU,&menuitems,&offset);
	if(!menuitems)
		return;		//nothing to do!

	scrolll(0);
	do {
		i=getmenuinput(menuitems);
		if(i&SELECT) {
			updatestates(selected,1,SRAMSAVE);
			if(selected==menuitems-1) selected--;	//deleted last entry.. move up one
		}
		if(i&(SELECT+UP+DOWN+LEFT+RIGHT))
			drawstates(SRAMMENU,&menuitems,&offset);
	} while(menuitems && !(i&(L_BTN+R_BTN+B_BTN)));
	scrollr();
}

void savestatemenu() {
	int i;
	int menuitems;
	int offset=0;

	i=savestate();
	compressstate(i,STATESAVE,STATEPTR,buffer1);

	getsram();

	selected=0;
	drawstates(SAVEMENU,&menuitems,&offset);
	scrolll(0);
	do {
		i=getmenuinput(menuitems);
		if(i&(A_BTN)) {
			if(!updatestates(selected,0,STATESAVE))
				writeerror();
		}
		if(i&SELECT)
			updatestates(selected,1,STATESAVE);
		if(i&(SELECT+UP+DOWN+LEFT+RIGHT))
			drawstates(SAVEMENU,&menuitems,&offset);
	} while(!(i&(L_BTN+R_BTN+A_BTN+B_BTN)));
	scrollr();
}

//locate last save by checksum
//returns save index (-1 if not found) and updates stateptr
//updates totalstatesize (so quicksave can use updatestates)
int findstate(u32 checksum,int type,stateheader **stateptr) {
	int state,size,foundstate,total;
	stateheader *sh;

	getsram();
	sh=(stateheader*)(buffer1+4);

	state=-1;
	foundstate=-1;
	total=8;
	size=sh->size;
	while(size) {
		if(sh->type==type) {
			state++;
			if(sh->checksum==checksum) {
				foundstate=state;
				*stateptr=sh;
			}
		}
		total+=size;
		sh=(stateheader*)(((u8*)sh)+size);
		size=sh->size;
	}
	totalstatesize=total;
	return foundstate;
}

void uncompressstate(int rom,stateheader *sh) {
	lzo_uint statesize=sh->compressedsize;
	lzo1x_decompress((u8*)(sh+1),statesize,STATEPTR,&statesize,NULL);
	loadstate(rom);
	frametotal=sh->framecount;		//restore global frame counter
	setup_sram_after_loadstate();		//handle sram packing
}

int using_flashcart() {
	return (u32)textstart&0x8000000;
}

void quickload() {
	stateheader *sh;
	int i;

	if(!using_flashcart())
		return;

	i=findstate(checksum((u8*)romstart),STATESAVE,&sh);
	if(i>=0)
		uncompressstate(romnum,sh);
}

void quicksave() {
	stateheader *sh;
	int i;

	if(!using_flashcart())
		return;

	setdarknessgs(7);	//darken
	drawtext(32+9,"           Saving.",0);

	i=savestate();
	compressstate(i,STATESAVE,STATEPTR,buffer1);
	i=findstate(checksum((u8*)romstart),STATESAVE,&sh);
	if(i<0) i=65536;	//make new save if one doesn't exist
	if(!updatestates(i,0,STATESAVE))
		writeerror();
	cls(2);
}

void colorcpy(u8 *ptr, u8 *palette)
{
	int i;
	u8 r, g, b;

	for (i = 0; i < 4; i++)
	{
		r = (*palette&31)<<3;
		g = ((*palette>>5)<<3) | ((*(palette+1)&3)<<(3+3));
		b = ((*(palette+1)>>2)&31)<<3;

		if (r != 0)
			r += 7;
		if (g != 0)
			g += 7;
		if (b != 0)
			b += 7;
		*(ptr++) = r;
		*(ptr++) = g;
		*(ptr++) = b;

		palette += 2;
	}
}

void compute_preset_palette(void)
{
	int checksum, c, i, f, lower, upper;
	u8 *palette_ptrs[3], *ptr;

	// Compute checksum from first 16 bytes of title
	checksum = 0;
	for (i = 0; i < 16; i++)
		checksum += romstart[TITLE+i];

	checksum &= 255;

	// Then find that checksum in the checksum table
	c = 0;
	for (i = 0; i < CHECKSUMS; i++)
	{
		if (checksum_table[i] == checksum)
		{
			c = i;
			break;
		}
	}

	// But for special (ie, duplicates), use a character in the title to
	// differentiate games
	if (c >= NORMAL_CHECKSUMS) {
		i = c - NORMAL_CHECKSUMS;

		while (i < SPECIAL_TABLE)
		{
			if (romstart[TITLE+3] == special_table[i]) {
				c = NORMAL_CHECKSUMS + i;
				break;
			}
			i += 14;
		}
	}

	if (c > FINAL_TABLE)
		c = 0;

	// Then obtain the palette to use
	f = final_table[c];

	// Use the lower bits to choose the palette combo
	lower = (f & 31)*3;
	// And the upper bits to choose the arrangement for the different layers
	upper = f >> 5;

	if (lower >= PALETTE_INDEX)
		lower = 0;

	palette_ptrs[0] = &palette_dictionary[palette_indexes[lower]];
	palette_ptrs[1] = &palette_dictionary[palette_indexes[lower+1]];
	palette_ptrs[2] = &palette_dictionary[palette_indexes[lower+2]];

	ptr = &presetpal;

	//bg0
	colorcpy(ptr, palette_ptrs[2]);
	ptr += 12;
	//win0
	colorcpy(ptr, palette_ptrs[2]);
	ptr += 12;

	//obj0
	if ((upper&1) == 1)
		colorcpy(ptr, palette_ptrs[0]);
	else
		colorcpy(ptr, palette_ptrs[2]);
	ptr += 12;

	//obj1
	switch (upper>>1)
	{
		case 0:
			colorcpy(ptr, palette_ptrs[2]);
			break;
		case 1:
			colorcpy(ptr, palette_ptrs[0]);
			break;
		default:
			colorcpy(ptr, palette_ptrs[1]);
			break;
	}
}

int find_dgbmax_palette() {
	int i, count;
	u8 *ptr, *srcptr;
	u16 checksum = (romstart[GLOBAL_CHECKSUM]<<8) + romstart[GLOBAL_CHECKSUM+1];

	srcptr = dgbmaxpalettes;
	ptr = &dgbmaxpal;

	count = *(u16*)srcptr;

	srcptr += 2;

	for (i = 0; i < count; i++)
	{
		if (*(u16*)srcptr == checksum)
		{
			srcptr += 2;
			//bg0, win0, obj0
			memcpy(ptr, srcptr, 36);
			ptr += 36;
			srcptr += 24;
			//obj1 - same as obj0
			memcpy(ptr, srcptr, 12);
/*
			memcpy(ptr, srcptr+6, 3);
			ptr += 3;
			memcpy(ptr, srcptr+3, 3);
			ptr += 3;
			memcpy(ptr, srcptr+0, 3);
			ptr += 3;
			memcpy(ptr, srcptr+9, 3);
*/
			return 1;
		}
		srcptr += (36+2);
	}

	memcpy(&dgbmaxpal,gbpalettes[1],48);
	return 0;
}

void paletteload() {
	stateheader *sh;
	int i;

	if(!using_flashcart()) {
		memcpy(&custompal,gbpalettes[1],48);
		//paletteinit();
		//PaletteTxAll();
		//palettereload();
		return;
	}

	find_dgbmax_palette();
	compute_preset_palette();

	i=findstate(checksum((u8*)romstart),PALETTE,&sh);
	if (i>=0) {
		memcpy(&custompal,(u8*)(sh+1),48);
	} else {
		//Clean grey palette.
		memcpy(&custompal,gbpalettes[1],48);
	}
	//paletteinit();
	//PaletteTxAll();
	//palettereload();
}

void palettesave() {
	stateheader *sh;
	int i;

	if(!using_flashcart())
		return;

	setdarknessgs(7);	//darken
	drawtext(32+9,"           Saving.",0);

	compressstate(48,PALETTE,&custompal,NULL);
	i=findstate(checksum((u8*)romstart),PALETTE,&sh);
	if(i<0) i=65536;	//make new save if one doesn't exist
	if(!updatestates(i,0,PALETTE))
		writeerror();
	cls(2);
}

void paletteclear() {
	stateheader *sh;
	int i;

	if(!using_flashcart())
		return;

	i=findstate(checksum((u8*)romstart),PALETTE,&sh);
	if (i>=0)
		updatestates(i,1,PALETTE);
	memset(&custompal,0,48);
}

void backup_gb_sram() {
	int i;
	configdata *cfg;
	stateheader *sh;
	lzo_uint compressedsize;

	if(!using_flashcart())
		return;

	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
	if(i>=0 && cfg->sram_checksum) {	//SRAM is occupied?
		i=findstate(cfg->sram_checksum,SRAMSAVE,&sh);//find out where to save
		if(i>=0) {
			memcpy(buffer2,sh,sizeof(stateheader));//use old info, in case the rom for this sram is gone and we can't look up its name.
			lzo1x_1_compress(MEM_SRAM+0xe000,0x2000,buffer2+sizeof(stateheader),&compressedsize,buffer1);	//workspace needs to be 64k
			getsram();
			sh=(stateheader*)buffer2;
			sh->size=(compressedsize+sizeof(stateheader)+3)&~3;	//size of compressed state+header, word aligned
			sh->compressedsize=compressedsize;	//size of compressed state
			updatestates(i,0,SRAMSAVE);
		}
	}
}

//make new saved sram (using XGB_SRAM contents)
//this is to ensure that we have all info for this rom and can save it even after this rom is removed
void save_new_sram() {
	compressstate(0x2000,SRAMSAVE,XGB_SRAM,buffer1);
	getsram();
	updatestates(65536,0,SRAMSAVE);
}

void get_saved_sram() {
	int i,j;
	u32 chk;
	configdata *cfg;
	stateheader *sh;
	lzo_uint statesize;

	if(!using_flashcart())
		return;

	if(g_cartflags&MBC_SAV) {	//if rom uses SRAM
		chk=checksum(romstart);
		i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
		j=findstate(chk,SRAMSAVE,&sh);	//see if packed SRAM exists
		if(i>=0) if(chk==cfg->sram_checksum) {	//SRAM is already ours
			bytecopy(XGB_SRAM,MEM_SRAM+0xe000,0x2000);
			if(j<0) save_new_sram();	//save it if we need to
			return;
		}
		if(j>=0) {//packed SRAM exists: unpack into XGB_SRAM
			statesize=sh->compressedsize;
			lzo1x_decompress((u8*)(sh+1),statesize,XGB_SRAM,&statesize,NULL);
		} else { //pack new sram and save it.
			save_new_sram();
		}
		bytecopy(MEM_SRAM+0xe000,XGB_SRAM,0x2000);
		writeconfig();//register new sram owner
	}
}

void setup_sram_after_loadstate() {
	int i;
	u32 chk;
	configdata *cfg;

	if(g_cartflags&MBC_SAV) {	//if rom uses SRAM
		chk=checksum(romstart);
		i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
		if(i>=0) if(chk!=cfg->sram_checksum) {//if someone else was using sram, save it
			backup_gb_sram();
		}
		bytecopy(MEM_SRAM+0xe000,XGB_SRAM,0x2000);		//copy gb sram to real sram
		i=findstate(chk,SRAMSAVE,(stateheader**)&cfg);	//does packed SRAM for this rom exist?
		if(i<0)						//if not, create it
			save_new_sram();
		writeconfig();//register new sram owner
	}
}

void loadstatemenu() {
	stateheader *sh;
	u32 key;
	int i;
	int offset=0;
	int menuitems;
	u32 sum;

	getsram();

	selected=0;
	sh=drawstates(LOADMENU,&menuitems,&offset);
	if(!menuitems)
		return;		//nothing to load!

	scrolll(0);
	do {
		key=getmenuinput(menuitems);
		if(key&(A_BTN)) {
			sum=sh->checksum;
			i=0;
			do {
				if(sum==checksum(findrom(i))) {	//find rom with matching checksum
					uncompressstate(i,sh);
					i=8192;
				}
				i++;
			} while(i<roms);
			if(i<8192) {
				cls(2);
				drawtext(32+9,"       ROM not found.",0);
				for(i=0;i<60;i++)	//(1 second wait)
					waitframe();
			}
		} else if(key&SELECT) {
			updatestates(selected,1,STATESAVE);
			if(selected==menuitems-1) selected--;	//deleted last entry? move up one
		}
		if(key&(SELECT+UP+DOWN+LEFT+RIGHT))
			sh=drawstates(LOADMENU,&menuitems,&offset);
	} while(menuitems && !(key&(L_BTN+R_BTN+A_BTN+B_BTN)));
	scrollr();
}

const configdata configtemplate={
	sizeof(configdata),
	CONFIGSAVE,
	0,0,0,0,0,0,
	"CFG"
};

void writeconfig() {
	configdata *cfg;
	int i,j;

	if(!using_flashcart())
		return;

	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);
	if(i<0) {//make new config
		memcpy(buffer2,&configtemplate,sizeof(configdata));
		cfg=(configdata*)buffer2;
	}
	cfg->bordercolor=bcolor;					//store current border type
	cfg->palettebank=palettebank;				//store current DMG palette
	j = stime & 0x3;							//store current autosleep time
	j |= (gbadetect & 0x1)<<3;					//store current gbadetect setting
	j |= (autostate & 0x1)<<4;					//store current autostate setting
	j |= (gammavalue & 0x7)<<5;					//store current gamma setting
	cfg->misc = j;
	if(g_cartflags&MBC_SAV) {					//update sram owner
			cfg->sram_checksum=checksum(romstart);
	}
	if(i<0) {	//create new config
		updatestates(0,0,CONFIGSAVE);
	} else {		//config already exists, update sram directly (faster)
		bytecopy((u8*)cfg-buffer1+MEM_SRAM,(u8*)cfg,sizeof(configdata));
	}
}

void readconfig() {
	int i;
	configdata *cfg;
	if(!using_flashcart())
		return;

	palettebank = palettes - 1;
	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);
	if(i>=0) {
		bcolor=cfg->bordercolor;
		if (bcolor > borders)
			bcolor = 0;
		palettebank=cfg->palettebank;
		if (palettebank >= palettes)
			palettebank = palettes - 1;
		i = cfg->misc;
		stime = i & 0x3;						//restore current autosleep time
		gbadetect = (i & 0x08)>>3;				//restore current gbadetect setting
		autostate = (i & 0x10)>>4;				//restore current autostate setting
		gammavalue = (i & 0xE0)>>5;				//restore current gamma setting
	}
}

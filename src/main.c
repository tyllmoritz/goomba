#include <stdio.h>
#include <string.h>
#include "gba.h"
#include "minilzo.107/minilzo.h"

extern u8 Image$$RO$$Limit;
extern u32 g_emuflags;			//from cart.s
extern u32 joycfg;				//from io.s
extern u32 font;				//from boot.s
extern u32 fontpal;				//from boot.s
extern u32 bfont;				//from boot.s
extern u32 bfontpal;				//from boot.s
extern u32 *vblankfptr;			//from lcd.s
extern u32 vbldummy;			//from lcd.s
extern u32 vblankinterrupt;		//from lcd.s
extern u32 AGBinput;			//from lcd.s
extern u32 EMUinput;
       u32 oldinput;
extern u8 autostate;			//from ui.c
extern u32 SerialIn;			//from rumble.c

//asm calls
void loadcart(int,int);			//from cart.s
void run(int);
void GFX_init(void);			//lcd.s
void resetSIO(u32);				//io.s
void vbaprint(char *text);		//io.s
void LZ77UnCompVram(u32 *source,u16 *destination);		//io.s
void LZ77UnCompWram(u32 *source,u8 *destination);		//io.s
void waitframe(void);			//io.s
int CheckGBAVersion(void);		//io.s

void cls(int);
void rommenu(void);
int drawmenu(int);
int getinput(void);
void splash(void);
void drawtext(int,char*,int);
void drawtextl(int,char*,int,int);
void setdarknessgs(int dark);
void setbrightnessall(int light);
void readconfig(void);			//sram.c
void quickload(void);
void backup_gb_sram(void);
void get_saved_sram(void);		//sram.c
void write_byte(u8 *address, u8 data);

const unsigned __fp_status_arm=0x40070000;
u8 *textstart;//points to first GB rom (initialized by boot.s)
int roms;//total number of roms

char pogoshell_romname[32];	//keep track of rom name (for state saving, etc)
char rtc=0;
char pogoshell=0;
char gameboyplayer=0;
char gbaversion;

void C_entry() {
	int i;
	vu16 *timeregs=(u16*)0x080000c8;
	u32 temp=(u32)(*(u8**)0x0203FBFC);
	pogoshell=((temp & 0xFE000000) == 0x08000000)?1:0;
	*timeregs=1;
	if(*timeregs & 1) rtc=1;
	gbaversion=CheckGBAVersion();
	vblankfptr=&vbldummy;
	SerialIn = 0;
	GFX_init();

	if(pogoshell){
		char *d=(char*)0x203fc08;
		do d++; while(*d);
		do d++; while(*d);
		do d--; while(*d!='/');
		d++;			//d=GB rom name

		roms=1;
		textstart=(*(u8**)0x0203FBFC);
		memcpy(pogoshell_romname,d,32);
	}
	else
	{
		int gbx_id=0x6666edce;
		u8 *p;

		//splash screen present?
		if(*(u32*)(textstart+0x104)!=gbx_id) {
			splash();
			textstart+=76800;
		}

		i=0;
		p=textstart;
		while(*(u32*)(p+0x104)==gbx_id) {	//count roms
			p+=(0x8000<<(*(p+0x148)));
			i++;
		}
		if(!i)i=1;					//Stop Goomba from crashing if there are no ROMs
		roms=i;
	}
	if(REG_DISPCNT==FORCE_BLANK)	//is screen OFF?
		REG_DISPCNT=0;				//screen ON
	*MEM_PALETTE=0x7FFF;			//white background
	REG_BLDCNT=0x00ff;				//brightness decrease all
	for(i=0;i<17;i++) {
		REG_BLDY=i;					//fade to black
		waitframe();
	}
	*MEM_PALETTE=0;					//black background (avoids blue flash when doing multiboot)
	REG_DISPCNT=0;					//screen ON, MODE0
	vblankfptr=&vblankinterrupt;
	lzo_init();	//init compression lib for savestates

	//load font+palette
	LZ77UnCompVram(&font,(u16*)0x6002400);
	memcpy((void*)0x5000080,&fontpal,64);
	// Load new border 
	LZ77UnCompWram(&bfont,&Image$$RO$$Limit);
        for (i=0; i<2720; i++)
	{
	  write_byte((u8 *) (0x6000800+i),*((&Image$$RO$$Limit)+i));
	}
	memcpy((void*)0x50001C0,&bfontpal,32);
	readconfig();
	rommenu();
}

//show splash screen
void splash() {
	int i;

	REG_DISPCNT=FORCE_BLANK;	//screen OFF
	memcpy((u16*)MEM_VRAM,(u16*)textstart,240*160*2);
	waitframe();
	REG_BG2CNT=0x0000;
	REG_DISPCNT=BG2_EN|MODE3;
	for(i=16;i>=0;i--) {	//fade from white
		setbrightnessall(i);
		waitframe();
	}
	for(i=0;i<150;i++) {	//wait 2.5 seconds
		waitframe();
		if (REG_P1==0x030f){
			gameboyplayer=1;
			gbaversion=3;
		}
	}
}

void rommenu(void) {
	cls(3);
	REG_BG2HOFS=0x0100;		//Screen left
	REG_BG2CNT=0x4600;	//16color 512x256 CHRbase0 SCRbase6 Priority0
	setdarknessgs(16);
	backup_gb_sram();
	resetSIO((joycfg&~0xff000000) + 0x40000000);//back to 1P

	if(pogoshell)
	{
		loadcart(0,g_emuflags&0x300);
		get_saved_sram();
	}
	else
	{
		static int selectedrom=0;
		int i,lastselected=-1;
		int key;

		int romz=roms;	//globals=bigger code :P
		int sel=selectedrom;

		oldinput=AGBinput=~REG_P1;

		if(romz>1){
			i=drawmenu(sel);
			loadcart(sel,i|(g_emuflags&0x300));  //(keep old gfxmode)
			get_saved_sram();
			lastselected=sel;
			for(i=0;i<8;i++)
			{
				waitframe();
				REG_BG2HOFS=224-i*32;	//Move screen right
			}
			setdarknessgs(7);			//Lighten screen
		}
		do {
			key=getinput();
			if(key&RIGHT) {
				sel+=10;
				if(sel>romz-1) sel=romz-1;
			}
			if(key&LEFT) {
				sel-=10;
				if(sel<0) sel=0;
			}
			if(key&UP)
				sel=sel+romz-1;
			if(key&DOWN)
				sel++;
			selectedrom=sel%=romz;
			if(lastselected!=sel) {
				i=drawmenu(sel);
				loadcart(sel,i|(g_emuflags&0x300));  //(keep old gfxmode)
				get_saved_sram();
				lastselected=sel;
			}
			run(0);
		} while(romz>1 && !(key&(A_BTN+B_BTN+START)));
		for(i=1;i<9;i++)
		{
			waitframe();
			setdarknessgs(8-i);		//Lighten screen
			REG_BG2HOFS=i*32;		//Move screen left
			run(0);
		}
		cls(3);	//leave BG2 on for debug output
		while(AGBinput&(A_BTN+B_BTN+START)) {
			AGBinput=0;
			run(0);
		}
	}
	if(autostate)quickload();
	run(1);
}

//return ptr to Nth ROM (including rominfo struct)
u8 *findrom(int n) {
	u8 *p=textstart;
	while(!pogoshell && n--)
		p+=(0x8000<<(*(p+0x148)));
	return p;
}

//returns options for selected rom
int drawmenu(int sel) {
	int i,j,topline,toprow,romflags=0;
	u8 *p;
//	romheader *ri;

	if(roms>20) {
		topline=8*(roms-20)*sel/(roms-1);
		toprow=topline/8;
		j=(toprow<roms-20)?21:20;
	} else {
		toprow=0;
		j=roms;
	}
	p=findrom(toprow);
	for(i=0;i<j;i++) {
		if(roms>1)drawtextl(i,(char*)p+0x134,i==(sel-toprow)?1:0,15);
		if(i==sel-toprow) {
			//ri=(romheader*)p;
			//romflags=(*ri).flags|(*ri).spritefollow<<16;
		}
		p+=(0x8000<<(*(p+0x148)));
	}
	if(roms>20)
		REG_BG2VOFS=topline%8;
	else
		REG_BG2VOFS=176+roms*4;
	return romflags;
}

int getinput() {
	static int lastdpad,repeatcount=0;
	int dpad;
	int keyhit=(oldinput^AGBinput)&AGBinput;
	oldinput=AGBinput;

	dpad=AGBinput&(UP+DOWN+LEFT+RIGHT);
	if(lastdpad==dpad) {
		repeatcount++;
		if(repeatcount<25 || repeatcount&3)	//delay/repeat
			dpad=0;
	} else {
		repeatcount=0;
		lastdpad=dpad;
	}
	EMUinput=0;	//disable game input
	return dpad|(keyhit&(A_BTN+B_BTN+START));
}


void cls(int chrmap) {
	int i=0,len=0x200;
	u32 *scr=(u32*)SCREENBASE;
	if(chrmap>=2)
		len=0x400;
	if(chrmap==2)
		i=0x200;
	for(;i<len;i++)				//512x256
		scr[i]=0x01200120;
	REG_BG2VOFS=0;
}

void drawtext(int row,char *str,int hilite) {
	drawtextl(row,str,hilite,29);
}
void drawtextl(int row,char *str,int hilite,int len) {
	u16 *here=SCREENBASE+row*32;
	int i=0;

	*here=hilite?0x412a:0x4120;
	hilite=(hilite<<12)+0x4100;
	here++;
	while(str[i]>=' ' && i<len) {
		here[i]=str[i]|hilite;
		i++;
	}
	for(;i<31;i++)
		here[i]=0x0120;
}

void setdarknessgs(int dark) {
	REG_BLDCNT=0x01fb;				//darken game screens
	REG_BLDY=dark;					//Darken screen
	REG_BLDALPHA=(0x10-dark)<<8;	//set blending for OBJ affected BG0
}

void setbrightnessall(int light) {
	REG_BLDCNT=0x00bf;				//brightness increase all
	REG_BLDY=light;
}

void write_byte(u8 *address, u8 data)
{

        u16 *addr2;
        //if not hw aligned
        if ( (int)address & 1)
        {
                addr2=(u16*)((int)address-1);
                *addr2 &= 0xFF;
                *addr2 |= (data << 8);
        }
        else
        {
                addr2=(u16*)address;
                *addr2 &= 0xFF00;
                *addr2 |= data;
        }
}


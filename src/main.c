#include "includes.h"

u32 oldinput;
u8 *textstart;//points to first GB rom (initialized by boot.s)
int roms;//total number of roms
int selectedrom=0;
int ui_visible=0;
int ui_x=0;
int ui_y=0;
char pogoshell_romname[32];	//keep track of rom name (for state saving, etc)
char rtc=0;
char pogoshell=0;
char gameboyplayer=0;
char gbaversion;

//82048 is an upper bound on the save state size
//The formula is an upper bound LZO estimate on worst case compression
//#define WORSTCASE ((82048)+(82048)/64+16+4+64)

void C_entry()
{
	int i,j;
	vu16 *timeregs=(u16*)0x080000c8;
	u32 temp=(u32)(*(u8**)0x0203FBFC);
	pogoshell=((temp & 0xFE000000) == 0x08000000)?1:0;
	*timeregs=1;
	if(*timeregs & 1) rtc=1;
	gbaversion=CheckGBAVersion();
	vblankfptr=&vbldummy;
//	vcountfptr=&vbldummy;
	SerialIn = 0;

	//clear VRAM
	memset((void*)0x06000000,0,0x18000);
	

	GFX_init();

	// The maximal space
	buffer1=(&Image$$RO$$Limit);
	buffer2=(&Image$$RO$$Limit+0x10000);
	buffer3=(&Image$$RO$$Limit+0x20000);

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
	//make 16 solid tiles
	{
		u32*  p=(u32*)0x06000000;
		for (i=0;i<16;i++)
		{
			u32 val=i*0x11111111;
			for (j=0;j<8;j++)
			{
				*p=val;
				p++;
			}
		}
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
//	vcountfptr=&vcountinterrupt;
	lzo_init();	//init compression lib for savestates

	//load font+palette
	LZ77UnCompVram(&font,(u16*)0x6000400);
	memcpy((void*)0x5000080,&fontpal,64);
	readconfig();
	rommenu();
}

//show splash screen
void splash()
{
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

void rommenu(void)
{
	cls(3);
	ui_x=0x100;
	move_ui();
	setdarknessgs(16);
	resetSIO((joycfg&~0xff000000) + 0x40000000);//back to 1P
	
	make_ui_visible();
	if (!backup_gb_sram(0))
	{
		ui();
		make_ui_visible();
		backup_gb_sram(0);
	}

	if(pogoshell)
	{
		loadcart(0,g_emuflags&0x300);
		get_saved_sram();
	}
	else
	{
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
				ui_x=224-i*32;
				move_ui();
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
			setdarknessgs(8-i);		//Lighten screen
			ui_x=i*32;
			move_ui();
			run(0);
		}
		cls(3);	//leave BG2 on for debug output
		while(AGBinput&(A_BTN+B_BTN+START)) {
			AGBinput=0;
			run(0);
		}
	}
	if(autostate)quickload();
	make_ui_invisible();
	run(1);
}

//return ptr to Nth ROM (including rominfo struct)
u8 *findrom(int n)
{
	u8 *p=textstart;
	while(!pogoshell && n--)
		p+=(0x8000<<(*(p+0x148)));
	return p;
}

//returns options for selected rom
int drawmenu(int sel)
{
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
	{
		ui_y=topline%8;
		move_ui();
	}
	else
	{
		ui_y=176+roms*4;
		move_ui();
	}
	return romflags;
}

int getinput()
{
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


void cls(int chrmap)
{
	int i=0,len=0x200;
	u32 *scr=(u32*)SCREENBASE;
	if(chrmap>=2)
		len=0x400;
	if(chrmap==2)
		i=0x200;
	for(;i<len;i++)				//512x256
		scr[i]=0x00200020;
	ui_y=0;
	move_ui();
}

void drawtext(int row,char *str,int hilite)
{
	drawtextl(row,str,hilite,29);
}
void drawtextl(int row,char *str,int hilite,int len)
{
	u16 *here=SCREENBASE+row*32;
	int i=0;

	*here=hilite?0x402a:0x4020;
	hilite=(hilite<<12)+0x4000;
	here++;
	while(str[i]>=' ' && i<len) {
		here[i]=str[i]|hilite;
		i++;
	}
	for(;i<31;i++)
		here[i]=0x0020;
}

void setdarknessgs(int dark)
{
	REG_BLDCNT=0x01f7;				//darken game screens
	REG_BLDY=dark;					//Darken screen
	REG_BLDALPHA=(0x10-dark)<<8;	//set blending for OBJ affected BG0
}

void setbrightnessall(int light)
{
	REG_BLDCNT=0x00bf;				//brightness increase all
	REG_BLDY=light;
}

void make_ui_visible()
{
	ui_visible=1;
	REG_WININ=0x3D3A;  //BG3 visible regardless of window
	REG_WINOUT=0x3F28; //BG3 visible outside of window
	move_ui();
}
void make_ui_invisible()
{
	ui_visible=0;
	REG_WININ=0x353A;  //settings back to normal
	REG_WINOUT=0x3F20; 
}

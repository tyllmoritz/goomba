#include "includes.h"

#if MOVIEPLAYER
int usinggbamp;
int usingcache;
File rom_file=NO_FILE;
char save_slot;
#endif

u32 oldinput;
u8 *textstart;//points to first GB rom (initialized by boot.s)
int roms;//total number of roms
int selectedrom=0;
int ui_visible=0;
int ui_x=0;
int ui_y=0;
#if POGOSHELL
char pogoshell_romname[32];	//keep track of rom name (for state saving, etc)
char pogoshell=0;
#endif
char rtc=0;
char gameboyplayer=0;
char gbaversion;
u32 max_multiboot_size;		//largest possible multiboot transfer (init'd by boot.s)

#define TRIM 0x4D495254

//82048 is an upper bound on the save state size
//The formula is an upper bound LZO estimate on worst case compression
//#define WORSTCASE ((82048)+(82048)/64+16+4+64)

void loadfont()
{
	LZ77UnCompVram(&font,(u16*)0x600C400);
	
	
}


void C_entry()
{
	int i,j;
	vu16 *timeregs=(u16*)0x080000c8;
#if POGOSHELL
	u32 temp=(u32)(*(u8**)0x0203FBFC);
	pogoshell=((temp & 0xFE000000) == 0x08000000)?1:0;
#endif
	*timeregs=1;
	if(*timeregs & 1) rtc=1;
	gbaversion=CheckGBAVersion();
	vblankfptr=&vbldummy;
//	vcountfptr=&vbldummy;
#if RUMBLE
	SerialIn = 0;
#endif

	//clear VRAM
	memset((void*)0x06000000,0,0x18000);
	

	GFX_init();

	// The maximal space
#if CARTSRAM
	buffer1=(&Image$$RO$$Limit);
	buffer2=(&Image$$RO$$Limit+0x10000);
	buffer3=(&Image$$RO$$Limit+0x20000);
#endif

#if POGOSHELL
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
#endif
	{
		int gbx_id=0x6666edce;
		u8 *p;
		u8 *q;

#if MOVIEPLAYER
		if (!disc_IsInserted())
		{
#endif
#ifdef SPLASH
		//splash screen present?
		p=textstart;
#if USETRIM
		if(*((u32*)p)==TRIM) p+=((u32*)p)[2];
#endif
		if(*(u32*)(p+0x104)!=gbx_id) {
			splash();
			textstart+=76800;
		}
#endif	

		i=-1;
		p=textstart;
		do
		{
#if USETRIM
			if(*((u32*)p)==TRIM)
			{
				q=p+((u32*)p)[2];
				p=p+((u32*)p)[1];
			}
			else
#endif
			{
				q=p;
				p+=(0x8000<<(*(p+0x148)));
			}
			i++;
		} while (*(u32*)(q+0x104)==gbx_id);
		if(!i)i=1;					//Stop Goomba from crashing if there are no ROMs
		roms=i;
#if MOVIEPLAYER
		}
#endif
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
#if CARTSRAM
	lzo_init();	//init compression lib for savestates
#endif

	//load font+palette
	loadfont();
	memcpy((void*)0x5000080,&fontpal,64);
#if CARTSRAM
	readconfig();
#endif
	rommenu();
}

#if SPLASH
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
		if (REG_P1==0x030f)
		{
			gameboyplayer=1;
			gbaversion=3;
		}
	}
}
#endif

#if MOVIEPLAYER
int get_saved_sram_CF(char* sramname)
{
	if(g_cartflags&2 && g_rammask!=0)
	{	//if rom uses SRAM
		File file;
		file=FAT_fopen(sramname,"r");
		if (file!=NO_FILE)
		{
			FAT_fread(XGB_sram,1,g_rammask+1,file);
			FAT_fclose(file);
		}
		return 1;
	}
	return 0;
}
int save_sram_CF(char* sramname)
{
	if(g_cartflags&2 && g_rammask!=0)
	{	//if rom uses SRAM
		File file;
		file=FAT_fopen(sramname,"r+");
		if (file==NO_FILE)
			file=FAT_fopen(sramname,"w");
		if (file!=NO_FILE)
		{
			FAT_fwrite(XGB_sram,1,g_rammask+1,file);
			FAT_fclose(file);
		}
		return 1;
	}
	return 0;
}
#endif

void rommenu(void)
{
	cls(3);
	ui_x=0x100;

	setdarknessgs(16);
	resetSIO((joycfg&~0xff000000) + 0x40000000);//back to 1P
	
#if MOVIEPLAYER
	usingcache=MOVIEPLAYERDEBUG;
	usinggbamp=0;
#endif
	
	make_ui_visible();
#if CARTSRAM
	if (!backup_gb_sram(0))
	{
		ui();
		make_ui_visible();
		backup_gb_sram(0);
	}
#endif

#if MOVIEPLAYER
	if (disc_IsInserted())
	{
		File file;
		usinggbamp=1;
		if (rom_file!=NO_FILE)
		{
			FAT_fclose(rom_file);
		}
		file=cfmenu();
		rom_file=file;
		cls(3);
		
		loadcart(0,g_emuflags&0x300);
		get_saved_sram_CF(SramName);
	}
	else
#endif

#if POGOSHELL
	if(pogoshell)
	{
		loadcart(0,g_emuflags&0x300);
#if CARTSRAM
		get_saved_sram();
#endif
	}
	else
#endif
	{
		int i,lastselected=-1;
		int key;

		int romz=roms;	//globals=bigger code :P
		int sel=selectedrom;

		oldinput=AGBinput=~REG_P1;

		if(romz>1){
			i=drawmenu(sel);
			loadcart(sel,i|(g_emuflags&0x300));  //(keep old gfxmode)
#if CARTSRAM
			get_saved_sram();
#endif
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
#if CARTSRAM
				get_saved_sram();
#endif
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
#if CARTSRAM
	if(autostate)quickload();
#endif
	make_ui_invisible();
	run(1);
}

u8 *findrom2(int n)
{
	u8 *p=textstart;
#if POGOSHELL
	while(!pogoshell && n--)
#else
	while(n--)
#endif
	{
#if USETRIM
		if (*((u32*)p)==TRIM) //trimmed
		{
			p+=((u32*)p)[1];
		}
		else
		{
			p+=(0x8000<<(*(p+0x148)));
		}
#else
		p+=(0x8000<<(*(p+0x148)));
#endif
	}
	return p;
}
u8 *findrom(int n)
{
	u8 *p=findrom2(n);
#if USETRIM
	if (*((u32*)p)==TRIM) //trimmed
	{
		p+=((u32*)p)[2];
	}
#endif
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

	for(i=0;i<j;i++)
	{
		p=findrom(toprow+i);
		if(roms>1)drawtextl(i,(char*)p+0x134,i==(sel-toprow)?1:0,15);
		if(i==sel-toprow) {
			//ri=(romheader*)p;
			//romflags=(*ri).flags|(*ri).spritefollow<<16;
		}
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
	loadfont();
	cls(3);
	REG_WININ=0x3D3A;  //BG3 visible regardless of window
	REG_WINOUT=0x3F28; //BG3 visible outside of window
	move_ui();
}

void make_ui_invisible()
{
	ui_visible=0;
	REG_WININ=0x353A;  //settings back to normal
	REG_WINOUT=0x3F20; 
#if MOVIEPLAYER
	reload_vram_page1();
#endif
}

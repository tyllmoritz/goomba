#include "includes.h"

u8 autoA,autoB;				//0=off, 1=on, 2=R
u8 stime=0;
u8 autostate=0;
int selected;//selected menuitem.  used by all menus.
int mainmenuitems;//? or CARTMENUITEMS, depending on whether saving is allowed
u32 oldkey;//init this before using getmenuinput

int savestate(void* dest){return 0;}
void loadstate(int foo, void* dest){}

#if !CARTSRAM
//void savestatemenu(){} void loadstatemenu(){} void managesram(){}
void quicksave(){} void quickload(){}
#endif
#if !MULTIBOOT
//void multiboot(){}
#endif


#define MENU2ITEMS 8+SPEEDHACKS			//othermenu items
#define MENU3ITEMS 2			//displaymenu items

//mainmenuitems when running from cart (not multiboot)
#define CARTMENUITEMS 7+MULTIBOOT+GOMULTIBOOT+(CARTSRAM*3)
#define MULTIBOOTMENUITEMS 7+MULTIBOOT	//"" when running from multiboot

const char MENUXITEMS[]={CARTMENUITEMS,MULTIBOOTMENUITEMS,MENU2ITEMS,MENU3ITEMS};

const fptr multifnlist[]={autoBset,autoAset,ui3,ui2,
#if MULTIBOOT
multiboot,
#endif
sleep,restart,exit};

const fptr fnlist1[]={autoBset,autoAset,ui3,ui2,
#if MULTIBOOT
multiboot,
#endif
#if CARTSRAM
savestatemenu,loadstatemenu,managesram,
#endif
sleep,
#if GOMULTIBOOT
go_multiboot,
#endif
restart,exit};

const fptr fnlist2[]={vblset,fpsset,sleepset,swapAB,autostateset,
#if SPEEDHACKS
find_speedhacks,
#endif
timermode,gbtype,gbatype};
const fptr fnlist3[]={chpalette,brightset};

const fptr* fnlistX[]={fnlist1,multifnlist,fnlist2,fnlist3};
const fptr drawuiX[]={drawui1,drawui1,drawui2,drawui3};


u32 getmenuinput(int menuitems)
{
	u32 keyhit;
	u32 tmp;
	int sel=selected;

	waitframe();		//(polling REG_P1 too fast seems to cause problems)
	tmp=~REG_P1;
	keyhit=(oldkey^tmp)&tmp;
	oldkey=tmp;
	if(keyhit&UP)
		sel=(sel+menuitems-1)%menuitems;
	if(keyhit&DOWN)
		sel=(sel+1)%menuitems;
	if(keyhit&RIGHT) {
		sel+=10;
		if(sel>menuitems-1) sel=menuitems-1;
	}
	if(keyhit&LEFT) {
		sel-=10;
		if(sel<0) sel=0;
	}
	if((oldkey&(L_BTN+R_BTN))!=L_BTN+R_BTN)
		keyhit&=~(L_BTN+R_BTN);
	selected=sel;
	return keyhit;
}

void ui()
{
	int key,soundvol,oldsel,tm0cnt,i;
	int mb=(u32)textstart<0x8000000;
	int savesuccess=1;
	int usefade=1;

	make_ui_visible();

	autoA=joycfg&A_BTN?0:1;
	autoA|=joycfg&(A_BTN<<16)?0:2;
	autoB=joycfg&B_BTN?0:1;
	autoB|=joycfg&(B_BTN<<16)?0:2;

	mainmenuitems=MENUXITEMS[mb];//running from rom or multiboot?
	FPSValue=0;					//Stop FPS meter

	soundvol=REG_SGCNT0_L;
	REG_SGCNT0_L=0;				//stop sound (GB)
	tm0cnt=REG_TM0CNT;
	REG_TM0CNT=0;				//stop sound (directsound)

#if MOVIEPLAYER
	if (usinggbamp)
	{
		if(g_cartflags&2 && g_rammask!=0)
		{
			ui_x=0;
			move_ui();
			cls(3);
			drawtext(9,"         Saving...",0);
			usefade=0;
			setdarknessgs(7);
			save_sram_CF(SramName);	
		}
	}
#endif
	selected=0;
	drawui1();
	if (usefade)
	{
		for(i=0;i<8;i++)
		{
			waitframe();
			setdarknessgs(i);		//Darken game screen
			ui_x=224-i*32; move_ui();
		}
	}
#if CARTSRAM
	savesuccess=backup_gb_sram(1);
#endif
	if (!savesuccess)
	{
		drawui1();
		ui_x=0;
		move_ui();
	}
	

	oldkey=~REG_P1;			//reset key input
	do {
		drawclock();
		key=getmenuinput(mainmenuitems);
		if(key&(A_BTN)) {
			oldsel=selected;
			fnlistX[mb][selected]();
			selected=oldsel;
			if (mb != (u32)textstart<0x8000000)
			{
				mb=1;
				selected=0;
			}
		}
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT))
			drawui1();
	} while(!(key&(B_BTN+R_BTN+L_BTN)));
#if CARTSRAM
	if (savesuccess)
	{
		get_saved_sram();
	}
	writeconfig();			//save any changes
#endif
	for(i=1;i<9;i++)
	{
		waitframe();
		setdarknessgs(8-i);	//Lighten screen
		ui_x=i*32; move_ui();
	}
	while(key&(B_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
	REG_SGCNT0_L=soundvol;	//resume sound (GB)
	REG_TM0CNT=tm0cnt;		//resume sound (directsound)
	cls(3);
	make_ui_invisible();
}

void subui(int menunr)
{
	int key,oldsel;

	selected=0;
	drawuiX[menunr]();
	scrolll(0);
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(MENUXITEMS[menunr]);
		if(key&(A_BTN)) {
			oldsel=selected;
			fnlistX[menunr][selected]();
			selected=oldsel;
		}
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT+L_BTN+R_BTN)) {
			drawuiX[menunr]();
		}
	} while(!(key&(B_BTN+R_BTN+L_BTN)));
	scrollr();
	while(key&(B_BTN+L_BTN+R_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}

void ui2()
{
	subui(2);
}
void ui3()
{
	setdarknessgs(0);
	subui(3);
	setdarknessgs(8);
}

void text(int row,char *str)
{
	drawtext(row+10-mainmenuitems/2,str,selected==row);
}
void text2(int row,char *str)
{
	drawtext(35+row+2,str,selected==row);
}


//trying to avoid using sprintf...  (takes up almost 3k!)
void strmerge(char *dst,char *src1,char *src2)
{
	if(dst!=src1)
		strcpy(dst,src1);
	strcat(dst,src2);
}

char *const autotxt[]={"OFF","ON","with R"};
char *const vsynctxt[]={"ON","OFF","SLOWMO"};
char *const sleeptxt[]={"5min","10min","30min","OFF"};
char *const brightxt[]={"I","II","III","IIII","IIIII"};
char *const hostname[]={"Crap","Prot","GBA","GBP","NDS"};
char *const ctrltxt[]={"1P","2P","Link2P","Link3P","Link4P"};
char *const bordtxt[]={"Black","Grey","Blue","None"};
char *const paltxt[16]={"Yellow","Grey","Multi1","Multi2","Zelda","Metroid",
				"AdvIsland","AdvIsland2","BaloonKid","Batman","BatmanROTJ",
				"BionicCom","CV Adv","Dr.Mario","Kirby","DK Land"};
char *const gbtxt[]={"GB","Perfer SGB over GBC","Perfer GBC over SGB","GBC+SGB"};
char *const clocktxt[]={"None","Timers","Full"};
char *const emuname = "Goomba Color ";

void drawui1()
{
	int row=0;
	char str[30];

	cls(1);
	drawtext(19,"by Flubba and Dwedit",0);
	strmerge(str,emuname, VERSION " on ");
	strmerge(str,str,hostname[gbaversion]);
	drawtext(18,str,0);

	strmerge(str,"B autofire: ",autotxt[autoB]);
	text(row++,str);
	strmerge(str,"A autofire: ",autotxt[autoA]);
	text(row++,str);
	text(row++,"Display->");
	text(row++,"Other Settings->");
#if MULTIBOOT
	text(row++,"Link Transfer");
#endif
	if(mainmenuitems==MULTIBOOTMENUITEMS) {
		text(row++,"Sleep");
	} else {
#if CARTSRAM
		text(row++,"Save State->");
		text(row++,"Load State->");
		text(row++,"Manage SRAM->");
#endif
		text(row++,"Sleep");
#if GOMULTIBOOT
		text(row++,"Go Multiboot");
#endif
	}
	text(row++,"Restart");
	text(row++,"Exit");
}

void drawui2()
{
	char str[30];
	int row=0;

	cls(2);
	drawtext(32,"       Other Settings",0);
	strmerge(str,"VSync: ",vsynctxt[novblankwait]);
	text2(row++,str);
	strmerge(str,"FPS-Meter: ",autotxt[fpsenabled]);
	text2(row++,str);
	strmerge(str,"Autosleep: ",sleeptxt[stime]);
	text2(row++,str);
	strmerge(str,"Swap A-B: ",autotxt[(joycfg>>10)&1]);
	text2(row++,str);
	strmerge(str,"Autoload state: ",autotxt[autostate&1]);
	text2(row++,str);
#if SPEEDHACKS
	strmerge(str,"Speed Hacks: ",autotxt[2==(g_hackflags&2)]);
	text2(row++,str);
#endif
	strmerge(str,"Double Speed: ",clocktxt[doubletimer]);
	text2(row++,str);
	strmerge(str,"Game Boy: ",gbtxt[request_gb_type]);
	text2(row++,str);
	strmerge(str,"GBC game sees GBA: ",autotxt[request_gba_mode]);
	text2(row++,str);
}

void drawui3()
{
	char str[30];
	int row=0;
	
	cls(2);
	drawtext(32,"      Display Settings",0);
	strmerge(str,"Palette: ",paltxt[palettebank]);
	text2(row++,str);
	strmerge(str,"Gamma: ",brightxt[gammavalue]);
	text2(row++,str);
}

void drawclock()
{

    char str[30];
    char *s=str+20;
    int timer,mod;

    if(rtc)
    {
	strcpy(str,"                    00:00:00");
	timer=gettime();
	mod=(timer>>4)&3;				//Hours.
	*(s++)=(mod+'0');
	mod=(timer&15);
	*(s++)=(mod+'0');
	s++;
	mod=(timer>>12)&15;				//Minutes.
	*(s++)=(mod+'0');
	mod=(timer>>8)&15;
	*(s++)=(mod+'0');
	s++;
	mod=(timer>>20)&15;				//Seconds.
	*(s++)=(mod+'0');
	mod=(timer>>16)&15;
	*(s++)=(mod+'0');

	drawtext(0,str,0);
    }
}

void autoAset()
{
	autoA++;
	joycfg|=A_BTN+(A_BTN<<16);
	if(autoA==1)
		joycfg&=~A_BTN;
	else if(autoA==2)
		joycfg&=~(A_BTN<<16);
	else
		autoA=0;
}

void autoBset()
{
	autoB++;
	joycfg|=B_BTN+(B_BTN<<16);
	if(autoB==1)
		joycfg&=~B_BTN;
	else if(autoB==2)
		joycfg&=~(B_BTN<<16);
	else
		autoB=0;
}

void sleepset()
{
	stime++;
	if(stime==1)
		sleeptime=60*60*10;			// 10min
	else if(stime==2)
		sleeptime=60*60*30;			// 30min
	else if(stime==3)
		sleeptime=0x7F000000;		// 360days...
	else if(stime>=4){
		sleeptime=60*60*5;			// 5min
		stime=0;
	}
}

void vblset()
{
	novblankwait++;
	if(novblankwait>=3)
		novblankwait=0;
}

void fpsset()
{
	fpsenabled = (fpsenabled^1)&1;
}

void brightset()
{
	gammavalue++;
	if (gammavalue>4) gammavalue=0;
	g_update_border_palette=1;
	transfer_palette();				//make new palette visible
}

#if MULTIBOOT
void multiboot()
{
	int i;
	cls(1);
	drawtext(9,"          Sending...",0);
	i=SendMBImageToClient();
	if(i) {
		if(i<3)
			drawtext(9,"         Link error.",0);
		else
			drawtext(9,"  Game is too big to send.",0);
		if(i==2) drawtext(10,"       (Check cable?)",0);
		for(i=0;i<90;i++)			//wait a while
			waitframe();
	}
}
#endif

void restart()
{
#if CARTSRAM
	writeconfig();					//save any changes
#endif
	scrolll(1);
	__asm {mov r0,#0x3007f00}		//stack reset
	__asm {mov sp,r0}
	rommenu();
}

void exit()
{
#if CARTSRAM
	writeconfig();					//save any changes
#endif
	fadetowhite();
	REG_DISPCNT=FORCE_BLANK;		//screen OFF
	REG_BG0HOFS=0;
	REG_BG0VOFS=0;
	REG_BLDMOD=0;					//no blending
	doReset();
}

void sleep()
{
	fadetowhite();
	suspend();
	setdarknessgs(7);				//restore screen
	while((~REG_P1)&0x3ff) {
		waitframe();				//(polling REG_P1 too fast seems to cause problems)
	}
}
void fadetowhite()
{
	int i;
	for(i=7;i>=0;i--) {
		setdarknessgs(i);			//go from dark to normal
		waitframe();
	}
	for(i=0;i<17;i++) {				//fade to white
		setbrightnessall(i);		//go from normal to white
		waitframe();
	}
}

void scrolll(int f)
{
	int i;
	for(i=0;i<9;i++)
	{
		if(f) setdarknessgs(8+i);	//Darken screen
		ui_x=i*32; move_ui();
		waitframe();
	}
}
void scrollr()
{
	int i;
	for(i=8;i>=0;i--)
	{
		waitframe();
		ui_x=i*32; move_ui();
	}
	cls(2);							//Clear BG2
}

void swapAB()
{
	joycfg^=0x400;
}

void autostateset()
{
	autostate = (autostate^1)&1;
}

void chpalette()
{
	palettebank++;
	palettebank&=15;
	paletteinit();
	PaletteTxAll();
	transfer_palette();
}

/*void border() {
	bcolor++;
	if(bcolor>=4)
		bcolor=0;
	makeborder();
}
*/

//void detect(void) {
//	gbadetect^=1;
//}
void gbtype()
{
	request_gb_type=(request_gb_type+1) % 4;
}
void gbatype()
{
	request_gba_mode=!request_gba_mode;
}
void timermode()
{
	doubletimer=(doubletimer+1) % 3;
	if (doubletimer==0) doubletimer=1;
	update_doublespeed_ui();
}

#if GOMULTIBOOT
void go_multiboot()
{
	char *src, *dest;
	int size;
	int key;
	int romsize;

	src=(char*)findrom(selectedrom);
	dest=(char *)&Image$$RO$$Limit;
	romsize = (0x8000 << (*(src+0x148)));
	
	size=max_multiboot_size-((int) dest-0x02000000);
	if (romsize>size)
	{
		cls(1);
		drawtext(8, "Game is too big to multiboot",0);
		drawtext(9,"      Attempt anyway?",0);
		drawtext(10,"        A=YES, B=NO",0);
		oldkey=~REG_P1;			//reset key input
		do {
			key=getmenuinput(10);
			if(key&(B_BTN + R_BTN + L_BTN ))
				return;
		} while(!(key&(A_BTN)));
		oldkey=~REG_P1;			//reset key input
	}

	memcpy (dest,src,size);
	textstart=(void*)dest;	
	selectedrom=0;
	loadcart(selectedrom,g_emuflags&0x300);
	mainmenuitems=MENUXITEMS[1];
	roms=1;
}
#endif

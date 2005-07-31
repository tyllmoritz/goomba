#include <stdio.h>
#include <string.h>

#include "gba.h"

//header files?  who needs 'em :P

void cls(int);		//from main.c
u8 *findrom(int n); //from main.c
void rommenu(void);
void drawtext(int,char*,int);
void setdarknessgs(int dark);
void setbrightnessall(int light);
extern char *textstart;

int SendMBImageToClient(void);	//mbclient.c
void loadcart(int,int);			//from cart.s

void palettesave(void); //from sram.c
void paletteclear(void); //from sram.c
//----asm calls------
void resetSIO(u32);			//io.s
void doReset(void);			//io.s
void suspend(void);			//io.s
void waitframe(void);		//io.s
int gettime(void);			//io.s
void debug_(int,int);		//lcd.s
void paletteinit(void);		//lcd.s
void palettepreview(void);	//lcd.s
void PaletteTxAll(void);	//lcd.s
void makeborder(void);		//lcd.s
//-------------------

extern u32 joycfg;			//from io.s
extern char novblankwait;	//from gb-z80.s
extern char gbadetect;		//from gb-z80.s
extern u32 sleeptime;		//from gb-z80.s
extern u32 FPSValue;		//from lcd.s
extern char fpsenabled;		//from lcd.s
extern char gammavalue;		//from lcd.s
extern u32 palettebank;		//from lcd.s palette bank
extern u32 bcolor;			//from lcd.s ,border color, black, grey, blue
// custom palette components
extern u8 GBPalettes; 
extern u8 custompal; 

extern u8 Image$$RO$$Limit;
extern u32 max_multiboot_size;

extern u32 g_emuflags;  // from cart.s
extern int roms;        // from main.c
extern int selectedrom; // from main.c
extern char rtc;
extern char pogoshell;
extern char gameboyplayer;
extern char gbaversion;

u8 autoA,autoB;				//0=off, 1=on, 2=R
u8 stime=0;
u8 ewram=0;
u8 autostate=0;

void autoAset(void);
void autoBset(void);
void swapAB(void);
void controller(void);
void vblset(void);
void restart(void);
void exit(void);
void multiboot(void);
void scrolll(int f);
void scrollr(void);
void drawui1(void);
void drawui2(void);
void drawui3(void);
void drawui4(void);
void subui(int menunr);
void ui2(void);
void ui3(void);
void ui4(void);
void drawclock(void);
void sleep(void);
void sleepset(void);
void fpsset(void);
void brightset(void);
void fadetowhite(void);
void ewramset(void);
void loadstatemenu(void);
void savestatemenu(void);
void autostateset(void);
void chpalette(void);
void border(void);
void gbtype(void);
void detect(void);
void copypalette(void);
void go_multiboot(void);
char *hexn(unsigned int n, int digits);
void inputhex(int row, int column, u8 *ptr, u32 digits);
void draw_input_text(int row, int column, char* str, int hilitedigit);

void writeconfig(void);	//sram.c
void managesram(void);	//sram.c

#define MENU2ITEMS 7			//othermenu items
#define MENU3ITEMS 5			//displaymenu items
#define CARTMENUITEMS 13 		//mainmenuitems when running from cart (not multiboot)
#define MULTIBOOTMENUITEMS 9	//"" when running from multiboot

const char MENUXITEMS[]={CARTMENUITEMS,MULTIBOOTMENUITEMS,MENU2ITEMS,MENU3ITEMS};

const fptr multifnlist[]={autoBset,autoAset,controller,ui3,ui2,multiboot,sleep,restart,exit};
const fptr fnlist1[]={autoBset,autoAset,controller,ui3,ui2,multiboot,savestatemenu,loadstatemenu,managesram,sleep,go_multiboot,restart,exit};
const fptr fnlist2[]={vblset,fpsset,sleepset,ewramset,swapAB,autostateset,detect,gbtype};
const fptr fnlist3[]={chpalette,copypalette,ui4,brightset,border};

const fptr* fnlistX[]={fnlist1,multifnlist,fnlist2,fnlist3};
const fptr drawuiX[]={drawui1,drawui1,drawui2,drawui3};

int selected;//selected menuitem.  used by all menus.
int mainmenuitems;//? or CARTMENUITEMS, depending on whether saving is allowed

u32 oldkey;//init this before using getmenuinput
u32 getmenuinput(int menuitems) {
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

void ui() {
	int key,soundvol,oldsel,tm0cnt,i;
	int mb=(u32)textstart<0x8000000;
	ewram=((REG_WRWAITCTL & 0x0F000000) == 0x0E000000)?1:0;

	autoA=joycfg&A_BTN?0:1;
	autoA|=joycfg&(A_BTN<<16)?0:2;
	autoB=joycfg&B_BTN?0:1;
	autoB|=joycfg&(B_BTN<<16)?0:2;

	mb = ((u32)textstart>0x8000000)?0:1;
	mainmenuitems=MENUXITEMS[mb]-(1-pogoshell);//running from rom or multiboot?
	FPSValue=0;					//Stop FPS meter

	soundvol=REG_SGCNT0_L;
	REG_SGCNT0_L=0;				//stop sound (GB)
	tm0cnt=REG_TM0CNT;
	REG_TM0CNT=0;				//stop sound (directsound)

	selected=0;
	drawui1();
	for(i=0;i<8;i++)
	{
		waitframe();
		setdarknessgs(i);		//Darken game screen
		REG_BG2HOFS=224-i*32;	//Move screen right
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
	for(i=1;i<9;i++)
	{
		waitframe();
		setdarknessgs(8-i);	//Lighten screen
		REG_BG2HOFS=i*32;	//Move screen left
	}
	while(key&(B_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
	REG_SGCNT0_L=soundvol;	//resume sound (GB)
	REG_TM0CNT=tm0cnt;		//resume sound (directsound)
	cls(3);
}

void subui(int menunr) {
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
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT)) {
			drawuiX[menunr]();
		}
	} while(!(key&(B_BTN+R_BTN+L_BTN)));
	scrollr();
	while(key&(B_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}

void ui2() {
	subui(2);
}
void ui3() {
	subui(3);
}
void ui4() {
	int key,oldsel;

	selected=0;
	drawui4();
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(17);
		if(key&(A_BTN)) {
			oldsel=selected;
			if (selected == 16) {
				paletteclear();
			} else {
				inputhex(selected,16,(&custompal)+selected*3,2);
				drawui4();
				inputhex(selected,18,(&custompal)+selected*3+1,2);
				drawui4();
				inputhex(selected,20,(&custompal)+selected*3+2,2);
				palettesave();
			}
			if (palettebank == 16)
			{
				paletteinit();
				PaletteTxAll();
			}
			selected=oldsel;
		}
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT)) {
			drawui4();
		}
	} while(!(key&(B_BTN+R_BTN+L_BTN)));
	while(key&(B_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}


char *hexn(unsigned int n, int digits)
{
        int i;

        static char hexbuffer[9];
        char hextable[]="0123456789ABCDEF";
        hexbuffer[8]=0;
        for (i=7;i>=8-digits;--i)
        {
                hexbuffer[i]=hextable[n&15];
                n>>=4;
        }
        return hexbuffer+8-digits;
}

char *threehex(u8 *ptr, int index)
{
        int i,j;
	u8 n;

        static char hexbuffer[7];
        char hextable[]="0123456789ABCDEF";
        hexbuffer[6]=0;
	i = 5;
	for (j = 2; j > -1; j--)
	{
		n = ptr[index+j];	
                hexbuffer[i--] = hextable[n&15];
                n >>= 4;
                hexbuffer[i--] = hextable[n&15];
        }
        return hexbuffer;
}

void draw_input_text(int row, int column, char* str, int hilitedigit)
{
	int i=0;
	const int hilite=(1<<12)+0x4100,nohilite=0x4100;
	u16 *here;
	row+=35;
	here=SCREENBASE+row*32+column+1;
	while(str[i]>=' ') {
		here[i]=str[i]|nohilite;
		if (i==hilitedigit) {
			if (str[i]==' ')
			   here[i]='_'|hilite;
			else
			   here[i]=str[i]|hilite;
		}
		i++;
	}
}

void inputhex(int row, int column, u8 *ptr, u32 digits)
{
	int key,tmp;
	u32 digit,addthis;
	digit=digits-1;
	
	draw_input_text(row,column,hexn(*ptr,digits),digit);
	
	oldkey=~REG_P1;			//reset key input
	do {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		tmp=~REG_P1;
		key=(oldkey^tmp)&tmp;
		oldkey=tmp;
		if (key&(RIGHT)) ++digit;
		if (key&(LEFT)) --digit;
		digit%=digits;
		addthis=1<<((digits-digit-1)<<2);
		if (key&UP) *ptr+=addthis;
		if (key&DOWN) *ptr-=addthis;

		if(key&(UP+DOWN+LEFT+RIGHT))
		{
			draw_input_text(row,column,hexn(*ptr,digits),digit);
			palettepreview();
		}
	} while(!(key&(A_BTN+B_BTN+R_BTN+L_BTN)));
	while(key&(B_BTN|A_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}

void text(int row,char *str) {
	drawtext(row+9-mainmenuitems/2,str,selected==row);
}
void text2(int row,char *str) {
	drawtext(35+row+2,str,selected==row);
}
void text3(int row,char *str) {
	drawtext(35+row,str,selected==row);
}


//trying to avoid using sprintf...  (takes up almost 3k!)
void strmerge(char *dst,char *src1,char *src2) {
	if(dst!=src1)
		strcpy(dst,src1);
	strcat(dst,src2);
}

char *const autotxt[]={"OFF","ON","with R"};
char *const vsynctxt[]={"ON","OFF","SLOWMO"};
char *const sleeptxt[]={"5min","10min","30min","OFF"};
char *const brightxt[]={"I","II","III","IIII","IIIII"};
char *const memtxt[]={"Normal","Turbo"};
char *const hostname[]={"Crap","Prot","GBA","GBP","NDS"};
char *const ctrltxt[]={"1P","2P","Link2P","Link3P","Link4P"};
char *const bordtxt[]={"Goomba","Black","Grey","Blue","None"};
char *const paltxt[17]={"Yellow","Grey","Multi1","Multi2","Zelda","Metroid",
				"AdvIsland","AdvIsland2","BaloonKid","Batman","BatmanROTJ",
				"BionicCom","CV Adv","Dr.Mario","Kirby","DK Land","Custom"};
char *const gbtxt[]={"DMG","MGB","SGB","CGB","AGB","Auto"};
char *const emuname[]={"         Goomba ","       Pogoomba "};
void drawui1() {
	int i=0, row=0;
	char str[30];

	cls(1);
	
	drawtext(18,"Powered by XGFLASH2.com 2005",0);
	if(pogoshell) i=1;
	strmerge(str,emuname[i],"v2.22 on ");
	strmerge(str,str,hostname[gbaversion]);
	drawtext(19,str,0);

	strmerge(str,"B autofire: ",autotxt[autoB]);
	text(row++,str);
	strmerge(str,"A autofire: ",autotxt[autoA]);
	text(row++,str);
	strmerge(str,"Controller: ",ctrltxt[(joycfg>>29)-2]);
	text(row++,str);
	text(row++,"Display->");
	text(row++,"Other Settings->");
	text(row++,"Link Transfer");
	if(mainmenuitems==MULTIBOOTMENUITEMS) {
		text(row++,"Sleep");
	} else {
		text(row++,"Save State->");
		text(row++,"Load State->");
		text(row++,"Manage SRAM->");
		text(row++,"Sleep");
		text(row++,"Go Multiboot");
	}
	text(row++,"Restart");
	if (pogoshell)
		text(row++,"Exit");
}

void drawui2() {
	char str[30];

	cls(2);
	drawtext(32,"       Other Settings",0);
	strmerge(str,"VSync: ",vsynctxt[novblankwait]);
	text2(0,str);
	strmerge(str,"FPS-Meter: ",autotxt[fpsenabled]);
	text2(1,str);
	strmerge(str,"Autosleep: ",sleeptxt[stime]);
	text2(2,str);
	strmerge(str,"EWRAM speed: ",memtxt[ewram]);
	text2(3,str);
	strmerge(str,"Swap A-B: ",autotxt[(joycfg>>10)&1]);
	text2(4,str);
	strmerge(str,"Autoload state: ",autotxt[autostate&1]);
	text2(5,str);
	strmerge(str,"Goomba detection: ",autotxt[gbadetect]);
	text2(6,str);
	strmerge(str,"Game Boy: ",gbtxt[0]);
	text2(7,str);
}

void drawui3() {
	char str[30];

	cls(2);
	drawtext(32,"      Display Settings",0);
	strmerge(str,"Palette: ",paltxt[palettebank]);
	text2(0,str);
	text2(1,"Copy To Custom Palette");
	text2(2,"Custom Palette->");
	strmerge(str,"Gamma: ",brightxt[gammavalue]);
	text2(3,str);
	strmerge(str,"Border: ",bordtxt[bcolor]);
	text2(4,str);
}

void drawui4() {
	char str[30];
	u16 *here;
	u16 value;
	int i,j;

	cls(2);
	drawtext(32,"        Custom Palette",0);
	strmerge(str,"Background #0: #",threehex(&custompal,0));
	text3(0,str);
	strmerge(str,"Background #1: #",threehex(&custompal,3));
	text3(1,str);
	strmerge(str,"Background #2: #",threehex(&custompal,6));
	text3(2,str);
	strmerge(str,"Background #3: #",threehex(&custompal,9));
	text3(3,str);
	strmerge(str,"Window #0:     #",threehex(&custompal,12));
	text3(4,str);
	strmerge(str,"Window #1:     #",threehex(&custompal,15));
	text3(5,str);
	strmerge(str,"Window #2:     #",threehex(&custompal,18));
	text3(6,str);
	strmerge(str,"Window #3:     #",threehex(&custompal,21));
	text3(7,str);
	strmerge(str,"Object 1 #0:   #",threehex(&custompal,24));
	text3(8,str);
	strmerge(str,"Object 1 #1:   #",threehex(&custompal,27));
	text3(9,str);
	strmerge(str,"Object 1 #2:   #",threehex(&custompal,30));
	text3(10,str);
	strmerge(str,"Object 1 #3:   #",threehex(&custompal,33));
	text3(11,str);
	strmerge(str,"Object 2 #0:   #",threehex(&custompal,36));
	text3(12,str);
	strmerge(str,"Object 2 #1:   #",threehex(&custompal,39));
	text3(13,str);
	strmerge(str,"Object 2 #2:   #",threehex(&custompal,42));
	text3(14,str);
	strmerge(str,"Object 2 #3:   #",threehex(&custompal,45));
	text3(15,str);
	text3(16,"Clear Custom Palette");
	
	here = SCREENBASE+35*32+24;
	for (j = 0; j < 2; j++)
	{
		value = 0xC118 + 0x1000*j;
		for (i = 0; i < 8; i++)
		{
			*here = value;
			value += 1;
			here += 32;
		}
	}
	palettepreview();
}

void drawclock() {

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

void autoAset() {
	autoA++;
	joycfg|=A_BTN+(A_BTN<<16);
	if(autoA==1)
		joycfg&=~A_BTN;
	else if(autoA==2)
		joycfg&=~(A_BTN<<16);
	else
		autoA=0;
}

void autoBset() {
	autoB++;
	joycfg|=B_BTN+(B_BTN<<16);
	if(autoB==1)
		joycfg&=~B_BTN;
	else if(autoB==2)
		joycfg&=~(B_BTN<<16);
	else
		autoB=0;
}

void controller() {					//see io.s: refreshGBjoypads
	u32 i=joycfg+0x20000000;
	if(i>=0xe0000000)
		i-=0xa0000000;
	resetSIO(i);					//reset link state
}

void sleepset() {
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

void vblset() {
	novblankwait++;
	if(novblankwait>=3)
		novblankwait=0;
}

void fpsset() {
	fpsenabled = (fpsenabled^1)&1;
}

void brightset() {
	gammavalue++;
	if (gammavalue>4) gammavalue=0;
	paletteinit();
	PaletteTxAll();					//make new palette visible
}

void multiboot() {
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

void restart() {
	writeconfig();					//save any changes
	scrolll(1);
	__asm {mov r0,#0x3007f00}		//stack reset
	__asm {mov sp,r0}
	rommenu();
}
void exit() {
	writeconfig();					//save any changes
	fadetowhite();
	REG_DISPCNT=FORCE_BLANK;		//screen OFF
	REG_BG0HOFS=0;
	REG_BG0VOFS=0;
	REG_BLDCNT=0;					//no blending
	doReset();
}

void sleep() {
	fadetowhite();
	suspend();
	setdarknessgs(7);				//restore screen
	while((~REG_P1)&0x3ff) {
		waitframe();				//(polling REG_P1 too fast seems to cause problems)
	}
}
void fadetowhite() {
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

void scrolll(int f) {
	int i;
	for(i=0;i<9;i++)
	{
		if(f) setdarknessgs(8+i);	//Darken screen
		REG_BG2HOFS=i*32;			//Move screen left
		waitframe();
	}
}
void scrollr() {
	int i;
	for(i=8;i>=0;i--)
	{
		waitframe();
		REG_BG2HOFS=i*32;			//Move screen right
	}
	cls(2);							//Clear BG2
}

void ewramset() {
	ewram^=1;
	if(ewram==1){
		REG_WRWAITCTL = (REG_WRWAITCTL & ~0x0F000000) | 0x0E000000;		//1 waitstate, overclocked
	}else{
		REG_WRWAITCTL = (REG_WRWAITCTL & ~0x0F000000) | 0x0D000000;		//2 waitstates, normal
	}
}

void swapAB() {
	joycfg^=0x400;
}

void autostateset() {
	autostate = (autostate^1)&1;
}

void chpalette() {
	palettebank++;
	palettebank%=17;
	paletteinit();
	PaletteTxAll();
}

void border() {
	bcolor = (bcolor+1)%5;
	makeborder();
}

void detect(void) {
	gbadetect^=1;
}
void gbtype() {
}

void copypalette(void)
{
  if (palettebank != 16)
  {
     memcpy(&custompal,(&GBPalettes)+palettebank*48,48);
     palettesave();
  }
}

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
	textstart=dest;	
	selectedrom=0;
	loadcart(selectedrom,g_emuflags&0x300);
	mainmenuitems=MENUXITEMS[1];
	roms=1;
}


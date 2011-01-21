#include <stdio.h>
#include <string.h>

#include "gba.h"

#define DONOTCLEARVRAM 0
#define CLEARVRAM 1

//header files?  who needs 'em :P

void cls(int);		//from main.c
u8 *findrom(int n); //from main.c
void rommenu(void);
void drawtext(int,char*,int);
void setdarknessgs(int dark);
void setbrightnessall(int light);
extern char *textstart;

int SendMBImageToClient(void);	//mbclient.c
void loadcart(int,int,int);			//from cart.s

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
void palettereload(void);	//lcd.s
void PaletteTxAll(void);	//lcd.s
void makeborder(void);		//lcd.s
//-------------------

extern u32 joycfg;			//from io.s
extern char novblankwait;	//from gb-z80.s
extern char gbadetect;		//from gb-z80.s
extern u32 sleeptime;		//from gb-z80.s
extern u32 FPSValue;		//from lcd.s
extern char fpsenabled;		//from lcd.s
extern unsigned char messageshow;		//from lcd.s
extern char messagetxt;		//from lcd.s
extern char gammavalue;		//from lcd.s
extern u32 palettebank;		//from lcd.s palette bank
extern u32 bcolor;			//from lcd.s ,border color, black, grey, blue
// custom palette components
extern u8 custompal; 

extern u8* go_multiboot_rolimit;
extern u32 max_multiboot_size;

extern u32 g_emuflags;  // from cart.s
extern int roms;        // from main.c
extern int selectedrom; // from main.c
extern char rtc;
extern char pogoshell;
extern char gameboyplayer;
extern char gbaversion;
extern u32 palettes;
extern u32 bpalettes;
extern u32 borders;
extern u32 bborders;
extern char **border_titles;
extern u8 **gbpalettes;

u8 autoA,autoB;				//0=off, 1=on, 2=R
u8 stime=0;
u8 ewram=0;
u8 autostate=0;

char *paltxt(int);
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
void incpalette(void);
void decpalette(void);
void chborder(void);
void decborder(void);
void incborder(void);
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
const fptr fnlist3[]={chpalette,copypalette,ui4,brightset,chborder};

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
	mainmenuitems=MENUXITEMS[mb];//running from rom or multiboot?
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
	} while(!(key&(B_BTN+L_BTN+R_BTN)));
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
	int key,oldsel, special, special2;

	selected=0;
	drawuiX[menunr]();
	scrolll(0);
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(MENUXITEMS[menunr]);
		special=(menunr == 3 && selected == 0);
		special2=(menunr == 3 && selected == 4);
		if (special && key&(L_BTN))
			decpalette();
		if (special && key&(R_BTN))
			incpalette();
		if (special2 && key&(L_BTN))
			decborder();
		if (special2 && key&(R_BTN))
			incborder();
		if(key&(A_BTN)) {
			oldsel=selected;
			fnlistX[menunr][selected]();
			selected=oldsel;
		}
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT+L_BTN+R_BTN)) {
			drawuiX[menunr]();
		}
	} while(!(key&(B_BTN)) && (special || special2 || !(key&(R_BTN+L_BTN))));
	scrollr();
	while(key&(B_BTN+L_BTN+R_BTN)) {
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
	int key,oldsel,modified;

	modified=selected=0;
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
			}
			modified = 1;
			if (gbpalettes[palettebank] == &custompal) {
				paletteinit();
				PaletteTxAll();
				palettereload();
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
	if (modified)
		palettesave();
}

char *paltxt(int palettebank)
{
	return (char *) gbpalettes[palettebank]+48;
}

char hextable[]="0123456789ABCDEF";

char *hexn(unsigned int n, int digits)
{
        int i;

        static char hexbuffer[9];
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
/*char *const bordtxt[]={"Black","Grey","Blue","None"};*/
/*char *const paltxt[50]={
				"Pea Soup",
				"Grayscale",
				"Multi 1",
				"Multi 2",
				"Zelda",
				"Metroid",
				"Adventure Island",
				"Adventure Island 2",
				"Balloon Kid",
				"Batman",
				"Batman - ROTJ",
				"Bionic Commando",
				"Castlevania Adv",
				"Dr. Mario",
				"Kirby",
				"Donkey Kong Land",
				"Yellow",
				// Lord Asaki: new palettes!
				"Super Gameboy 1A",
				"Super Gameboy 1B",
				"Super Gameboy 1C",
				"Super Gameboy 1D",
				"Super Gameboy 1E",
				"Super Gameboy 1F",
				"Super Gameboy 1G",
				"Super Gameboy 1H",
				"Super Gameboy 2A",
				"Super Gameboy 2B",
				"Super Gameboy 2C",
				"Super Gameboy 2D",
				"Super Gameboy 2E",
				"Super Gameboy 2F",
				"Super Gameboy 2G",
				"Super Gameboy 2H",
				"Super Gameboy 3A",
				"Super Gameboy 3B",
				"Super Gameboy 3C",
				"Super Gameboy 3D",
				"Super Gameboy 3E",
				"Super Gameboy 3F",
				"Super Gameboy 3G",
				"Super Gameboy 3H",
				"Super Gameboy 4A",
				"Super Gameboy 4B",
				"Super Gameboy 4C",
				"Super Gameboy 4D",
				"Super Gameboy 4E",
				"Super Gameboy 4F",
				"Super Gameboy 4G",
				"Super Gameboy 4H",
				//Custom palette
				"Custom"};
*/
char *const gbtxt[]={"DMG","MGB","SGB","CGB","AGB","Auto"};
char *const emuname[]={"         Goomba ","       Pogoomba "};
void drawui1() {
	int i=0, row=0;
	char str[30];

	cls(1);
	
	drawtext(18,"Powered by Excelsior",0);
	if(pogoshell) i=1;
	strmerge(str,emuname[i],"v2.40 on ");
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
	strmerge(str,"Palette: ",paltxt(palettebank));
	text2(0,str);
	text2(1,"Copy To Custom Palette");
	text2(2,"Custom Palette->");
	strmerge(str,"Gamma: ",brightxt[gammavalue]);
	text2(3,str);
	strmerge(str,"Border: ",border_titles[bcolor]);
	text2(4,str);
}

void drawui4() {
	char str[30], numstr[2];
	char *title[4] = { "Background #", "Window #", "Object 1 #", "Object 2 #" };
	char *ending[4] = { ": #", ":     #", ":   #", ":   #" };
	u16 *here;
	u16 value;
	int i,j;

	numstr[1] = 0;

	cls(2);
	drawtext(32,"        Custom Palette",0);
	for (i = 0; i < 16; i++)
	{
		numstr[0] = (i&3) + 48;
		strcpy(str, title[i>>2]);
		strcat(str, numstr);
		strcat(str, ending[i>>2]);
		strcat(str, threehex(&custompal,i*3));
		text3(i,str);
	}
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
	palettereload();
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

void paletteloadandshow() {
	paletteinit();
	PaletteTxAll();
	palettereload();
	strmerge(&messagetxt, "Palette: ", paltxt(palettebank));
	messageshow=150;
}

void draw_palette_list()
{
	int scroll_top,scroll_bottom,row,item,offset;
	
	palettebank=selected;
	paletteloadandshow();
	
	cls(2);
	
	scroll_top=selected-9;
	scroll_bottom=palettes-18;
	if (scroll_top > scroll_bottom) scroll_top=scroll_bottom;
	if (scroll_top<0) scroll_top=0;
	
	offset = (palettes < 18) ? (10-(palettes>>1)) : 1;
	
	for (item=scroll_top; item < palettes && item<scroll_top+18; item++)
	{
		row=item-scroll_top+offset;
		drawtext(32+row,paltxt(item),selected==item);
	}
}

void chpalette()
{
	int key;

	selected=palettebank;
	draw_palette_list();
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(palettes);
		if(key&(UP+DOWN+LEFT+RIGHT)) {
			draw_palette_list();
		}
	} while(!(key&(A_BTN+B_BTN+R_BTN+L_BTN)));
	while(key&(B_BTN+L_BTN+R_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}

void incpalette() {
	palettebank++;
	palettebank%=palettes;
	paletteloadandshow();
}

void decpalette() {
	palettebank+=(palettes-1);
	palettebank%=palettes;
	paletteloadandshow();
}

void borderloadandshow() {
	makeborder();
	strmerge(&messagetxt,"Border: ",border_titles[bcolor]);
	messageshow=150;
}

void draw_border_list()
{
	int scroll_top,scroll_bottom,row,item,offset;
	
	bcolor=selected;
	borderloadandshow();
	
	cls(2);
	
	scroll_top=selected-9;
	scroll_bottom=borders-18;
	if (scroll_top > scroll_bottom) scroll_top=scroll_bottom;
	if (scroll_top<0) scroll_top=0;

	offset = (borders < 18) ? (10-(borders>>1)) : 1;
	
	for (item=scroll_top; item < borders && item<scroll_top+18; item++)
	{
		row=item-scroll_top+offset;
		drawtext(32+row,border_titles[item],selected==item);
	}
}

void chborder()
{
	int key;

	selected=bcolor;
	draw_border_list();
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(borders);
		if(key&(UP+DOWN+LEFT+RIGHT)) {
			draw_border_list();
		}
	} while(!(key&(A_BTN+B_BTN+R_BTN+L_BTN)));
	while(key&(B_BTN+L_BTN+R_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}

void decborder() {
	bcolor+=(borders-1);
	bcolor%=borders;
	borderloadandshow();
}

void incborder() {
	bcolor++;
	bcolor%=borders;
	borderloadandshow();
}

void detect(void) {
	gbadetect^=1;
}
void gbtype() {
}

void copypalette(void)
{
  if (gbpalettes[palettebank] != &custompal)
  {
     memcpy(&custompal,gbpalettes[palettebank],48);
     palettesave();
  }
}

void go_multiboot()
{
	char *src, *dest;
	int size, key, romsize;
	int i, j;
	int borderssize, palettesize;
	int borders_to_use;
	int palettes_to_use;
	
	borders_to_use = borders;
	palettes_to_use = palettes - 3;

	borderssize = 0;
	for (i = bborders; i < borders; i++)
		borderssize += *(u32 *)(border_titles[i]-4);

	palettesize = (48+24)*(palettes_to_use - bpalettes);

	src=(char*)findrom(selectedrom);
	dest=(char *)go_multiboot_rolimit;
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
		borders_to_use = bborders;
		palettes_to_use = bpalettes;
	} else if (romsize+borderssize+palettesize>size) {
		cls(1);
		drawtext(7,  "  The size of all borders",0);
		drawtext(8,  " and palettes are too large",0);
		drawtext(9,  "     Truncate and Go",0);
		drawtext(10, "    Multiboot anyway?",0);
		drawtext(11, "        A=YES, B=NO",0);
		oldkey=~REG_P1;			//reset key input
		do {
			key=getmenuinput(10);
			if(key&(B_BTN + R_BTN + L_BTN ))
				return;
		} while(!(key&(A_BTN)));
		oldkey=~REG_P1;			//reset key input
		palettesize = size - romsize;
		palettes_to_use = palettesize/(48+24);
		if (palettes_to_use < bpalettes)
			palettes_to_use = bpalettes;
		if (palettes_to_use > palettes - 3)
			palettes_to_use = palettes - 3;
		borderssize = size - romsize - (palettes_to_use - bpalettes)*(48+24);
		for (borders_to_use = bborders; borderssize >= 0; borders_to_use++)
			borderssize -= *(u32 *)(border_titles[borders_to_use]-4);
		borders_to_use--;
	}

	// Copy palettes over
	for (i = bpalettes; i < palettes_to_use; i++)
	{
		memmove(dest, gbpalettes[i], (48+24));
		gbpalettes[i] = (u8 *) dest;
		dest += (48+24);
	}

	// Rebase custom, preset, and dgbmax palettes
	for (j = 0; j < 3; j++)
		gbpalettes[palettes_to_use+j] = gbpalettes[palettes-3+j];

	for (i = bborders; i < borders_to_use; i++)
	{
		j = *(u32 *)(border_titles[i]-4);
		memmove(dest, border_titles[i]-4, j);
		border_titles[i] = dest+4;
		dest += j;
	}
	memcpy (dest,src,romsize);
	textstart=dest;	
	selectedrom=0;
	roms=1;
	mainmenuitems=MENUXITEMS[1];
	palettes=palettes_to_use + 3;
	borders=borders_to_use;
	if (palettebank>palettes-1)
		palettebank = palettes - 1;
	if (bcolor>borders-1)
		bcolor = borders-1;
	loadcart(selectedrom,g_emuflags&0x300,CLEARVRAM);
}


#include "includes.h"

#define STATEID 0x57a731d8

#define STATESAVE 0
#define SRAMSAVE 1
#define CONFIGSAVE 2
#define MBC_SAV 2

int totalstatesize;		//how much SRAM is used
u32 sram_owner=0;

u8 *buffer1;
u8 *buffer2;
u8 *buffer3;


/*
extern u8 Image$$RO$$Limit;
extern u8 g_cartflags;	//(from GB header)
extern int bcolor;		//Border Color
extern int palettebank;	//Palette for DMG games
extern u8 gammavalue;	//from lcd.s
//extern u8 gbadetect;	//from gb-z80.s
extern u8 stime;		//from ui.c
extern u8 autostate;	//from ui.c
extern u8 *textstart;	//from main.c

extern char pogoshell;	//main.c

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
void no_sram_owner();
void register_sram_owner();

extern int roms;		//main.c
extern int selected;	//ui.c
extern char pogoshell_romname[32];	//main.c
//----asm stuff------
int savestate(void*);		//cart.s
void loadstate(int,void*);		//cart.s

extern u8 *romstart;	//from cart.s
extern u32 romnum;	//from cart.s
extern u32 frametotal;	//from gb-z80.s
//-------------------

typedef struct {
	u16 size;	//header+data
	u16 type;	//=STATESAVE or SRAMSAVE
	u32 uncompressed_size;
	u32 framecount;
	u32 checksum;
	char title[32];
} stateheader;

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
*/


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

void flush_end_sram()
{
	u8* sram=MEM_SRAM;
	int i;
	for (i=0xE000;i<0x10000;i++)
	{
		sram[i]=0;
	}
}
void flush_xgb_sram()
{
	u8* sram=(u8*)XGB_SRAM;
	int i;
	for (i=0x0;i<0x8000;i++)
	{
		sram[i]=0;
	}
}


void getsram() {		//copy GBA sram to BUFFER1
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

#if USETRIM
//quick & dirty rom checksum
u32 checksum(u8 *p) {
	u32 sum=0;
	int i;
	u32 addthis;
	u8* end=(u8*)INSTANT_PAGES[1];
	u8 endchar=end[-1];
	for(i=0;i<128;i++) {
		if (p<end)
		{
			sum+=*p|(*(p+1)<<8)|(*(p+2)<<16)|(*(p+3)<<24);
		}
		else
		{
			sum+=endchar|(endchar<<8)|(endchar<<16)|(endchar<<24);
		}
		p+=128;
	}
	return sum;
}
#else
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
#endif

void writeerror() {
	int i;
	cls(2);
	make_ui_visible();
	ui_x=256;
	ui_y=0;
	move_ui();
	drawtext(32+9,"  Write error! Memory full.",0);
	drawtext(32+10,"     Delete some saves.",0);
	for(i=90;i;--i)
	{
		make_ui_visible();
		waitframe();
	}
}

//(BUFFER1=copy of GBA SRAM, BUFFER3=new data)
//overwrite:  index=state#, erase=0
//new:  index=big number (anything >=total saves), erase=0
//erase:  index=state#, erase=1
//returns TRUE if successful
//IMPORTANT!!! totalstatesize is assumed to be current
int updatestates(int index,int erase,int type) {
//need to check this
	int i;
	int srcsize;
	int total=totalstatesize;
	u8 *src=buffer1;
	u8 *dst;
	u8 *newdst;
//	u8 *mem_end=buffer1+0xE000;
	stateheader *newdata=(stateheader*)buffer3;

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
	if(!erase) {
		i=newdata->size;
		total+=i;
		if(total>0xe000) //**OUT OF MEMORY**
			return 0;
		newdst=(u8*)newdata + i;
		srcsize=((stateheader*)src)->size;
		while(srcsize) {		//copy trailing old data to after new data.
			memcpy(newdst,src,srcsize);
			newdst+=srcsize;
			src+=srcsize;
			srcsize=((stateheader*)src)->size;
		}
		*(u32*)newdst=0;	//terminate
		*(u32*)(newdst+4)=0xffffffff;	//terminate
		src=(u8*)newdata;
	}

	srcsize=((stateheader*)src)->size;

	//copy everything back to BUFFER1
	while(srcsize) {
		memcpy(dst,src,srcsize);
		dst+=srcsize;
		src+=srcsize;
		srcsize=((stateheader*)src)->size;
	}

	*(u32*)dst=0;	//terminate
	*(u32*)(dst+4)=0xffffffff;	//terminate
	dst+=8;
	total+=8;

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

//compress src into buffer3 (adding header), using 64k of workspace
void compressstate(lzo_uint size,u16 type,u8 *src,void *workspace)
{
	lzo_uint compressedsize;
	stateheader *sh;

	if (workspace == NULL) {
		memcpy(buffer3+sizeof(stateheader),src,size);
		compressedsize=size;
	} else {
		lzo1x_1_compress(src,size,buffer3+sizeof(stateheader),&compressedsize,workspace);	//workspace needs to be 64k
	}

	//setup header:
	sh=(stateheader*)buffer3;
	sh->size=(compressedsize+sizeof(stateheader)+3)&~3;	//size of compressed state+header, word aligned
	sh->type=type;
	sh->uncompressed_size=size;	//size of compressed state
	sh->framecount=frametotal;
	sh->checksum=checksum((u8*)romstart);	//checksum
#if POGOSHELL
    if(pogoshell)
    {
		strcpy(sh->title,pogoshell_romname);
    }
    else
#endif
    {
		strncpy(sh->title,(char*)findrom(romnum)+0x134,15);
    }
}

void managesram() {
//need to check this
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
//need to check this
	int i;
	int menuitems;
	int offset=0;
	
	SAVE_FORBIDDEN;

	i=savestate(buffer2);
	compressstate(i,STATESAVE,buffer2,buffer1);

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
//need to check this
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
//need to check this
	lzo_uint statesize=sh->size-sizeof(stateheader);
	lzo1x_decompress((u8*)(sh+1),statesize,buffer2,&statesize,NULL);
	loadstate(rom,buffer2);
	frametotal=sh->framecount;		//restore global frame counter
	setup_sram_after_loadstate();		//handle sram packing
}

int using_flashcart() {
#if MOVIEPLAYER
	if (usingcache)
	{
		return 0;
	}
#endif

	return (u32)textstart&0x8000000;
}

void quickload() {
	stateheader *sh;
	int i;
	
	SAVE_FORBIDDEN;

	if(!using_flashcart())
		return;

	i=findstate(checksum((u8*)romstart),STATESAVE,&sh);
	if(i>=0)
		uncompressstate(romnum,sh);
}

void quicksave() {
	stateheader *sh;
	int i;
	
	SAVE_FORBIDDEN;

	if(!using_flashcart())
		return;

	make_ui_visible();
	ui_y=0;
	ui_x=256;
	move_ui();
	setdarknessgs(7);	//darken
	drawtext(32+9,"           Saving.",0);

	i=savestate(buffer2);
	compressstate(i,STATESAVE,buffer2,buffer1);
	i=findstate(checksum((u8*)romstart),STATESAVE,&sh);
	if(i<0) i=65536;	//make new save if one doesn't exist
	if(!updatestates(i,0,STATESAVE))
		writeerror();
	cls(2);
}

int backup_gb_sram(int called_from)
{
//need to check this
	int i=0;
	configdata *cfg;
	stateheader *sh;
	lzo_uint compressedsize;

	u32 chk = checksum((u8*)romstart);
	
	if(!using_flashcart())
		return 1;
	
	if (called_from==1 && g_sramsize==3) //called from UI and 32K sram size
	{
		i=findstate(chk,SRAMSAVE,&sh);//find out where to save
		if(i>=0)
		{
			memcpy(buffer3,sh,sizeof(stateheader));//use old info, in case the rom for this sram is gone and we can't look up its name.
			lzo1x_1_compress(XGB_SRAM,0x8000,buffer3+sizeof(stateheader),&compressedsize,buffer2);	//workspace needs to be 64k
			sh=(stateheader*)buffer3;
			sh->size=(compressedsize+sizeof(stateheader)+3)&~3;	//size of compressed state+header, word aligned
			sh->uncompressed_size=0x8000;	//size of compressed state
			if (!updatestates(i,0,SRAMSAVE))
			{
				writeerror();
				return 0;
			}
		}
		return 1;
	}
	
	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
	
	
	if (called_from==1 && chk==sram_owner)
	{
		//copy GBX_SRAM to MEM_SRAM, because some instructions don't properly modify GBA SRAM
		bytecopy(MEM_SRAM+0xE000,XGB_SRAM,0x2000);
	}
	
	if(i>=0 && cfg->sram_checksum) {	//SRAM is occupied?
		i=findstate(cfg->sram_checksum,SRAMSAVE,&sh);//find out where to save
		if(i>=0)
		{
			int save_size=0x2000;

			memcpy(buffer3,sh,sizeof(stateheader));//use old info, in case the rom for this sram is gone and we can't look up its name.
			lzo1x_1_compress(MEM_SRAM+0xe000,save_size,buffer3+sizeof(stateheader),&compressedsize,buffer2);	//workspace needs to be 64k
			sh=(stateheader*)buffer3;
			sh->size=(compressedsize+sizeof(stateheader)+3)&~3;	//size of compressed state+header, word aligned
			
			sh->uncompressed_size=save_size;	//size of compressed state
			if (!updatestates(i,0,SRAMSAVE))
			{
				writeerror();
				return 0;
			}
			else
			{
				i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
				no_sram_owner();
			}
		}
	}
	return 1;
	
}

//make new saved sram (using XGB_SRAM contents)
//this is to ensure that we have all info for this rom and can save it even after this rom is removed
void save_new_sram() {
	int sramsize=0;
	if (g_sramsize==1) sramsize=0x2000;
	else if (g_sramsize==2) sramsize=0x2000;
	else if (g_sramsize==3) sramsize=0x8000;
	compressstate(sramsize,SRAMSAVE,XGB_SRAM,buffer2);
	updatestates(65536,0,SRAMSAVE);
}

void get_saved_sram(void)
{
	int i,j;
	u32 chk;
	configdata *cfg;
	stateheader *sh;
	lzo_uint statesize;

	if(!using_flashcart())
		return;

	if(g_cartflags&MBC_SAV)
	{	//if rom uses SRAM
		chk=checksum(romstart);
		i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
		j=findstate(chk,SRAMSAVE,&sh);	//see if packed SRAM exists
		
		//probably shouldn't do this
/*
		if(i>=0) if(chk==cfg->sram_checksum) {	//SRAM is already ours
			bytecopy(XGB_SRAM,MEM_SRAM+0xe000,0x2000);
			if(j<0) save_new_sram();	//save it if we need to
			return;
		}
		*/
//		flush_end_sram();
		
		if(j>=0) {//packed SRAM exists: unpack into XGB_SRAM
			statesize=sh->size-sizeof(stateheader);
			lzo1x_decompress((u8*)(sh+1),statesize,XGB_SRAM,&statesize,NULL);
		} else { //pack new sram and save it.
			save_new_sram();
		}
		
		//For 32k SRAM, don't bother storing anything in real SRAM, in fact, flush it out.
		if (g_sramsize==3)
		{
			no_sram_owner();
		}
		else
		{
			//otherwise, use the sram saving system
			bytecopy(MEM_SRAM+0xe000,XGB_SRAM,0x2000);
			register_sram_owner();//register new sram owner
		}
	}
}

void register_sram_owner()
{
	sram_owner=checksum(romstart);
	writeconfig();
}

void no_sram_owner()
{
	sram_owner=0;
	writeconfig();
	flush_end_sram();
}

void setup_sram_after_loadstate() {
//need to check this
	int i;
	u32 chk;
	configdata *cfg;

	if(g_cartflags&MBC_SAV) {	//if rom uses SRAM
		chk=checksum(romstart);
		i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);	//find config
		if(i>=0) if(chk!=cfg->sram_checksum) {//if someone else was using sram, save it
			backup_gb_sram(0);
		}
		bytecopy(MEM_SRAM+0xe000,XGB_SRAM,0x2000);		//copy gb sram to real sram
		i=findstate(chk,SRAMSAVE,(stateheader**)&cfg);	//does packed SRAM for this rom exist?
		if(i<0)						//if not, create it
			save_new_sram();
		register_sram_owner();//register new sram owner
	}
}

void loadstatemenu() {
	stateheader *sh;
	u32 key;
	int i;
	int offset=0;
	int menuitems;
	u32 sum;
	
	SAVE_FORBIDDEN;

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
		memcpy(buffer3,&configtemplate,sizeof(configdata));
		cfg=(configdata*)buffer3;
	}
	cfg->bordercolor=bcolor;					//store current border type
	cfg->palettebank=palettebank;				//store current DMG palette
	j = stime & 0x3;							//store current autosleep time
//	j |= (gbadetect & 0x1)<<3;					//store current gbadetect setting
	j |= (autostate & 0x1)<<4;					//store current autostate setting
	j |= (gammavalue & 0x7)<<5;					//store current gamma setting
	cfg->misc = j;
	cfg->sram_checksum=sram_owner;
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

	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);
	if(i>=0) {
		bcolor=cfg->bordercolor;
		palettebank=cfg->palettebank;
		i = cfg->misc;
		stime = i & 0x3;						//restore current autosleep time
//		gbadetect = (i & 0x08)>>3;				//restore current gbadetect setting
		autostate = (i & 0x10)>>4;				//restore current autostate setting
		gammavalue = (i & 0xE0)>>5;				//restore current gamma setting
		sram_owner=cfg->sram_checksum;
	}
}
/*
void clean_gb_sram() {
	int i;
	u8 *gb_sram_ptr = MEM_SRAM+0xe000;
	configdata *cfg;

	if(!using_flashcart())
		return;

	for(i=0;i<0x2000;i++) *gb_sram_ptr++ = 0;

	i=findstate(0,CONFIGSAVE,(stateheader**)&cfg);
	if(i<0) {//make new config
		memcpy(buffer3,&configtemplate,sizeof(configdata));
		cfg=(configdata*)buffer3;
	}
	cfg->bordercolor=bcolor;					//store current border type
	cfg->palettebank=palettebank;				//store current DMG palette
	cfg->misc = stime & 0x3;					//store current autosleep time
	cfg->misc |= (autostate & 0x1)<<4;			//store current autostate setting
	cfg->sram_checksum=0;						// we don't want to save the empty sram
	if(i<0) {	//create new config
		updatestates(0,0,CONFIGSAVE);
	} else {		//config already exists, update sram directly (faster)
		bytecopy((u8*)cfg-buffer1+MEM_SRAM,(u8*)cfg,sizeof(configdata));
	}
}

*/
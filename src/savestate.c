/*
#include "gba.h"
#include <string.h>

#include "fs.h"
#include "main.h"
#include "cache.h"
#include "filemenu.h"
#include "ui.h"
#include "savestate.h"
#include "asmcalls.h"
*/

/*
VERS	4	
REGS	12	
EMUF	20	
IO  	256	
MAPR	44	
PAL 	128	gbc_palette
OAM 	160	NULL
RAM 	8192	XGB_RAM
RAM2	24576	GBC_EXRAM
VRAM	16384	XGB_VRAM
PACK	112	
SPAL	64	
PALS	4096	
ATFS	4096	
ATTR	360	
SRAM	32768	XGB_SRAM
*/

TAG # 4
blocksize # 2
decompsize # 2

const char alltags[]="VERSREGSEMUFIO  MAPRPAL OAM RAM RAM2VRAMVRM2SRAMPACKSPALPALSATFSATTR"
const u32 *const tags=(u32*)alltags;
/*
VERS
REGS
EMUF
IO  
MAPR
PAL 
OAM 
RAM 
RAM2
VRAM
VRM2
SRAM
PACK
SPAL
PALS
ATFS
ATTR
*/

lzo1x_1_compress


void * addresses[]=
{
	(void*)saveversion,
	(void*)cpustate,
	(void*)ppustate,
	(void*)NES_RAM,
	(void*)NES_SRAM,
	(void*)NES_VRAM,
	(void*)NES_VRAM2,
	(void*)NES_VRAM4,
	(void*)mapperstate,
	(void*)agb_pal,
	(void*)agb_nt_map
};
const int sizes[]={
	 ((sizeof(saveversion)-2) | 3)+1 ,
	52,
	32,
	2048,
	8192,
	8192,
	2048,
	2048,
	56,
	96,
	16
};

void dumpdata(File file, const char *tag, int size, void* data)
{
	FAT_fwrite(tag  ,4   ,1,file);
	FAT_fwrite(&size,4   ,1,file);
	FAT_fwrite(data ,size,1,file);
}
void dumpdata2(File file, int tagid)
{
	if ( (tagid==VRAM4_TAG) && !(g_cartflags & 0x18) )
		return;
	dumpdata(file,tags[tagid],sizes[tagid],addresses[tagid]);
}

//loads the header of a data block, not the actual data...
bool loaddata(File file, char *tag, int *size)
{
	int read;
	read=FAT_fread(tag ,4  ,1,file);
	if (read!=4) return false;
	read=FAT_fread(size,4  ,1,file);
	if (read!=4) return false;
	return true;
}
int char_array_search(const char *lookfor, const char *const *const array, int arrsize)
{
	int i;
	for (i=0;i<arrsize;i++)
	{
		if (0==strcmp(lookfor,array[i]))
			return i;
	}
	return arrsize;
}


bool loadblock(File file, const char *tag, int size)
{
	int i;
	int expectedsize;
	bool skip=false;
//	char saveversion2[36];
	void *address;
	i=char_array_search(tag,tags,NUM_TAGS);
	if (i==NUM_TAGS)
	{
		FAT_fseek(file, size, SEEK_CUR);
		return false;
	}
	expectedsize=sizes[i];
	address=addresses[i];
	if (i==VERSION_TAG)
	{
		skip=true;
	}
	if ( (i==VRAM4_TAG) && !(g_cartflags & 0x18) )
	{
		skip=true;
	}
	if (skip)
	{
		FAT_fseek(file, size, SEEK_CUR);
		return true;
	}
	if (size>expectedsize)
	{
		FAT_fread(address,expectedsize,1,file);
		FAT_fseek(file, size-expectedsize, SEEK_CUR);
	}
	else
	{
		FAT_fread(address,size,1,file);
	}
	return true;
}

void add_to_nt_map(int address)
{
	int i;
	for (i=0;i<4;i++)
	{
//		if ((u32)agb_nt_map[i]>32768)
//		{
//			if (address<0)
//			{
//				agb_nt_map[i]+=address;
//			}
//		}
//		else
//		{
		agb_nt_map[i]+=address;
//		}
	}
}

bool savestate(const char *filename)
{
	if (usinggbamp)
	{
		File file;
		file=FAT_fopen(filename,"r+");
		if (file==NO_FILE)
		{
			file=FAT_fopen(filename,"w");
		}
		if (file!=NO_FILE)
		{
			int i;
			u8* old_lastbank=g_lastbank;
			g_m6502_pc=(u8*)(g_m6502_pc - g_lastbank);
			g_m6502_s=(u8*)((u32)g_m6502_s-(u32)NES_RAM);
			g_lastbank=NULL;

			add_to_nt_map(-(int)AGB_BG);
			
			for (i=0;i<NUM_TAGS;i++)
			{
				dumpdata2(file,i);
			}
			FAT_fclose(file);
			
			g_lastbank=old_lastbank;
			g_m6502_pc=(u8*)((u32)g_m6502_pc+(u32)g_lastbank);
			g_m6502_s=(u8*)((u32)g_m6502_s+(u32)NES_RAM);

			add_to_nt_map((int)AGB_BG);

			return true;
		}
	}
	
	return false;
}

bool loadstate(const char *filename)
{
	if (usinggbamp)
	{
		File file;
		file=FAT_fopen(filename,"r");
		if (file!=NO_FILE)
		{
			char TAG[5];
			int size;
			bool not_eof=false;
			TAG[4]='\0';
			do
			{
				not_eof=loaddata(file,TAG,&size);
				if (not_eof)
				{
					loadblock(file,TAG,size);
				}
			} while (not_eof);
			FAT_fclose(file);

			flushcache();
			update_cache();

			add_to_nt_map((int)AGB_BG);

			g_lastbank= g_memmap_tbl[ (((u32)g_m6502_pc) & 0xE000) / 8192];
			g_m6502_pc= (u8*)((u32)g_m6502_pc+(u32)g_lastbank);
			g_m6502_s=(u8*)((u32)g_m6502_s+(u32)NES_RAM);
			
			loadstate_gfx();

			return true;
		}
	}
	else
	{
//		g_m6502_pc=(u8*)((u32)g_m6502_pc-(u32)g_lastbank);
//		g_lastbank=0;
//		g_lastbank= g_memmap_tbl[ ((u32)g_m6502_pc & 0xE000) / 8192];
//		g_m6502_pc= ((u32)g_m6502_pc+g_lastbank);
	}

	return false;
}

/*
void write_byte(char *address,u8 value)
{
	u32 odd=((u32)address)&1;
	u16* p=(u16*)(address-odd);
	u16 old=*p;
	if (odd)
	{
		old&=0xFF;
		old|=value<<8;
	}
	else
	{
		old&=0xFF00;
		old|=value;
	}
	*p=old;
}
*/

void get_state_filename2(char state)
{
	int l;
	l=strlen(SramName);
	SramName[l-2]='t';
	SramName[l-1]=state;
//	write_byte(SramName+l-2,'t');
//	write_byte(SramName+l-1,state);
}
void restore_sram_filename()
{
	int l;
	l=strlen(SramName);
	SramName[l-2]='a';
	SramName[l-1]='v';
//	write_byte(SramName+l-2,'a');
//	write_byte(SramName+l-1,'v');
}

void get_state_filename()
{
	get_state_filename2(statelist[save_slot]);
}

bool quicksave()
{
	bool retval;
	get_state_filename();
	retval= savestate(SramName);
	if (retval) stateexist[save_slot]=1;
	restore_sram_filename();
	return retval;
}

bool quickload()
{
	bool retval;
	get_state_filename();
	retval= loadstate(SramName);
	restore_sram_filename();
	return retval;
}

bool state_exists(char state)
{
	bool retval;
	get_state_filename2(state);
	retval= FAT_FileExists(SramName);
	restore_sram_filename();
	return retval;
}

void find_save_slots(char *buffer)
{
	int filenum;
	int l;
	int i;
	char c;
	l=strlen(SramName);
	for (i=0;i<36;i++)
	{
		stateexist[i]=0;
	}
	
	filenum=FAT_FindFirstFileLFN(buffer);
	while (filenum!=0)
	{
		if (filenum==1)
		{
			for (i=0;i<l-2;i++)
			{
				if (ucase(buffer[i])!=ucase(SramName[i])) goto statenotfound;
			}
			if (ucase(buffer[i])=='T')
			{
				c=buffer[i+1];
				for (i=0;i<36;i++)
				{
					if (ucase(c)==ucase(statelist[i]))
					{
						stateexist[i]=1;
						break;
					}
				}
			}
		}
statenotfound:
		filenum=FAT_FindNextFileLFN(buffer);
	}
	
	
	
}

const char *const headings[]={
//0123456789ABCDEF0123456789ABC
 "     Select Save Slot",
 "        Save State",
 "        Load State"
};


void draw_state_menu(int sel, int mode)
{
	char txt[32];
	int selrow;
	int top;
	int row=0;
	const int count=36;
	strcpy(txt,headings[mode]);
	cls(2);
	drawtext(32,txt,0);
	//0...9                top
	//10...count-9         scroll
	//count-9...count-1    bottom
	strcpy(txt,"State Slot #_");
	top=sel-9;
	if (top<0 || count <=18)
	{
		top=0;
	}
	else if (count-18<=top)
	{
		top=count-18;
	}
	selrow=sel-top;
		
	while (1)
	{
		if (row+2>=20)
			return;
		txt[11]=ucase(statelist[row+top]);
		if (stateexist[row+top]) txt[12]='*'; else txt[12]=' ';
		drawtext(32+row+2,txt,selrow==row);
		row++;
		
	}
}

void state_menu(int mode)
{
	//find list of existing states
	int key;
	char oldsaveslot=save_slot;
	selected=save_slot;
	
	draw_state_menu(selected, mode);
	scrolll(0);
	oldkey=~REG_P1;			//reset key input
	do {
		key=getmenuinput(36);
		if(key&(A_BTN)) {
			if (mode==2)
			{
				oldsaveslot=save_slot;
				save_slot=selected;
				if (quickload())
				{
					break;
				}
				else
				{
					save_slot=oldsaveslot;
				}
			}
			else if (mode==1)
			{
				oldsaveslot=save_slot;
				save_slot=selected;
				if (quicksave())
				{
					break;
				}
				else
				{
					save_slot=oldsaveslot;
				}
			}
			else
			{
				save_slot=selected;
				break;
			}
		}
		if (key&(B_BTN+R_BTN+L_BTN))
		{
			break;
		}
		if(key&(A_BTN+UP+DOWN+LEFT+RIGHT)) {
			draw_state_menu(selected, mode);
		}
	} while(!(key&(B_BTN+R_BTN+L_BTN)));
	scrollr();
	while(key&(B_BTN)) {
		waitframe();		//(polling REG_P1 too fast seems to cause problems)
		key=~REG_P1;
	}
}


void selectstate()
{
	state_menu(0);
}
void savestatemenu()
{
	state_menu(1);
}
void loadstatemenu()
{
	state_menu(2);
}

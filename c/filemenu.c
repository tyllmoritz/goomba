#include "includes.h"

FILE_ENTRY *FILES=(FILE_ENTRY*)&Image$$RO$$Limit;
u16 *DATA=(u16*)0x06004000;
u16 *TEMP=(u16*)0x06008000;

/*


extern u32 Image$$RO$$Limit;

void hexdump(void* , int , char*);
void swapmem (u32* , u32*, u32 ); //for overlapping memory regions
void flushcache(void);
void init_cache(int rompages,int vrompages, int mapper);

int cistrcmp(const char *a, const char *b);
bool str_equiv(const char* str1, const char* str2);
void fixfilename(int type, char *filename);
void mergesort (char files[][32], u16 data[], u16 temp[], int size);

//supports about 7168 files in same directory before crashing
typedef char FILE_ENTRY[32];
FILE_ENTRY *FILES=(FILE_ENTRY*)&Image$$RO$$Limit;
u16 *DATA=(u16*)0x06008000;
u16 *TEMP=(u16*)0x0600C000;

extern u8 END_OF_EXRAM;
extern u8 AP32_COPY_POINT;
int memcpybyte(u8*, u8*, u32);
extern char SramName[256];
extern u8* romstart;
//u8* rom_base;
extern u8 g_rompages;
extern int usingcache;
//int usingcompcache;
extern int usinggbamp;
extern File rom_file;

extern char openFiles[2];

extern u32 g_emuflags;			//from cart.s
#define PALTIMING 4

void waitframe(void);			//io.s
//void depack(u8 *source, u8 *destination);

void cls(int);
void drawtext(int,char*,int);
extern int selected;
u32 getmenuinput(int menuitems);

extern u32 AGBinput;			//from ppu.s
extern u32 oldinput;

extern u8 *textstart;//points to first GB rom (initialized by boot.s)

*/


int getvalidfile(int reset, char *filename)
{
	char *ext;
	int type;
	do
	{
		if (reset)
		{
			reset=0;
			type=FAT_FindFirstFileLFN(filename);
		}
		else
		{
			type=FAT_FindNextFileLFN(filename);
		}
		if (type==0)
			return 0;
		if (type==2)
		{
			if (filename[0]!='.')
			{
				return 2;
			}
		}
		if (type==1)
		{
			//ends with .gb/gbc?
			if (filename!=NULL)
			{
				ext=strrchr(filename,'.');
				if (ext)
				{
					ext++;
					if (str_equiv(ext,"gb") || str_equiv(ext,"gbc") )
					{
						return 1;
					}
				}
			}
		}
	} while(1);
}
/*
int countroms(void)
{
	char filename[256];
	int count=0;
	int type;
	type=getvalidfile(1,filename);
	while (type!=0)
	{
		count++;
		type=getvalidfile(0,filename);
	}
	return count;
}
*/
int buildfiles(void)
{
	char filename[256];
	int count=0;
	int type;
	type=getvalidfile(1,filename);
	while (type!=0)
	{
		fixfilename(type,filename);
		memcpy(FILES[count],filename,32);
		DATA[count]=count;
		count++;
		type=getvalidfile(0,filename);
	}
	mergesort(FILES,DATA,TEMP,count);
	return count;
}
int skipandget(int skipnum, char *filename)
{
	int i;
	int type;
	type=getvalidfile(1,filename);
	for (i=0;i<skipnum;i++)
	{
		type=getvalidfile(0,filename);
	}
	return type;
}

bool remove_from_string(char *string, int pos, int count)
{
	int l=strlen(string);
	if (pos<0)
	{
		count+=pos;
		pos=0;
	}
	if (count+pos>=l) count=l-pos;
	if (count<0)
	{
		return false;
	}
	memmove(string+pos,string+pos+count,l-count-pos+1);
	return true;
}
bool insert_into_string(char *string, int pos, const char *insertthis)
{
	int l2=strlen(insertthis);
	int l=strlen(string);
	memmove(string+pos+l2,string+pos,l-pos+1);
	memcpy(string+pos,insertthis,l2);
	return true;
}

bool remove_string(char *string, const char *removethis)
{
	char *p=strstr(string,removethis);
	int l2=strlen(removethis);
	if (p)
	{
		remove_from_string(string,p-string,l2);
		return true;
	}
	return false;
}
bool search_replace(char *string, const char *replacethis, const char *withthis)
{
	char *p = strstr(string,replacethis);
	int l2=strlen(replacethis);
	if (p)
	{
		remove_from_string(string,p-string,l2);
		insert_into_string(string,p-string,withthis);
		return true;
	}
	return false;
}

char *const taglist[]={"[!]","[C]","[S]","(JUE)","(UE)","(JU)","(U)","(J)","(E)","(SGB)","(Japanese)","(Unl)","(F)","(G)","(UA)","(S)","(I)","(Chinese)","(JUA)"};
const int NUM_TAGS=19;

void fixfilename(int type, char *filename)
{
	int l;
	int end;
	int i;
	for (i=0;i<NUM_TAGS;i++)
	{
		while(remove_string(filename,taglist[i]));
	}
	while (search_replace(filename," .","."));  //remove trailing spaces
	l=strlen(filename);

	if (type==2) //directory
	{
		end=l-1;
		if (end>26) end=26;
		for (i=end;i>=0;i--)
		{
			filename[i+1]=filename[i];
		}
		filename[0]='[';
		filename[end+2]=']';
		filename[end+3]='\0';
	}
	else if (type==1)
	{
		if (filename[l-4]!='.') l++;
		filename[l-4]='\0';
		l-=4;
		end=l-1;
		if (end>=27)
		{
			filename[27]=filename[l-1];
			filename[28]=filename[l];
			filename[29]='\0';
		}
	}
}

void drawcfmenu(int sel, int count)
{
	int selrow;
	int top;
	int row=0;
	//0...9                top
	//10...count-9         scroll
	//count-9...count-1    bottom
	top=sel-10;
	if (top<0 || count <=19)
	{
		top=0;
	}
	else if (count-20<=top)
	{
		top=count-20;
	}
	selrow=sel-top;
	waitframe();
	cls(1);
	while (1)
	{
		if (row>=20)
			return;
		if (row+top>=count)
			return;
		drawtext(row,FILES[DATA[row+top]],row==selrow);
		row++;
	}
}

void copy_to_right_screen()
{
	//SCREENBASE+2048
	int i;
	u16 *screen=SCREENBASE;
	for (i=0;i<1024;i++)
	{
		screen[i+1024]=screen[i];
	}
}

void scroll_left(int selected, int count)
{
	int i;
	copy_to_right_screen();
	ui_x=256;
	move_ui();
	drawcfmenu(selected, count);
	for (i=32;i<=256;i+=32)
	{
		waitframe();
		ui_x=256-i;
		move_ui();
	}
}

void scroll_right(int selected, int count)
{
	int i;
	copy_to_right_screen();
	ui_x=256;
	move_ui();
	drawcfmenu(selected, count);
	for (i=32;i<=256;i+=32)
	{
		waitframe();
		ui_x=256+i;
		move_ui();
	}
	ui_x=0;
	move_ui();
}


void generate_sram_name(char *filename)
{
	//generate sram name
	{
//		char *ext=strrchr(filename,'.');
		int l=strlen(filename);
//		if (ext)
//		{
//			ext++;
//			strcpy(ext,"sav");
			
		if (filename[l-3]=='.') l++;
		filename[l-3]='s';
		filename[l-2]='a';
		filename[l-1]='v';
		if (l>=256)l=255;
		filename[l]=0;
		memcpy(SramName,filename,256);
	}
}

int execute(int sel, File *retfile)
{
	int type;
	File file;
	int filesize;
	const int sizelimit=128*1024;
	u8* dest=(u8*)&Image$$RO$$Limit;
	char filename[256];
	
	type=skipandget(sel,filename);
	if (type==2)
	{
		FAT_chdir(filename);
		return 2;
	}
	else if (type==1)
	{
		file=FAT_fopen(filename,"r");
		if (file==NO_FILE) return 1;

		filesize=FAT_GetFileSize();
		textstart=dest;

		if (filesize<=sizelimit) //128k and under?  Load full rom.
		{
			FAT_fread(dest,1,filesize,file);
			usingcache=0;
		}
		else
		{
			int readsize;
			readsize=16384;
			FAT_fread(dest,1,readsize,file);
			usingcache=1;
		}
		//generate sram name
		generate_sram_name(filename);
		//find the save slots
//		find_save_slots(filename);

		*retfile=file;
		return 3;
	}
	else
	{
		return 0;
	}
}

File cfmenu(void)
{
	//int cursor=0;
	int count=0;
	int type;
	int i;
	File file;
	u32 key;
	bool success;
	static int needsinit=1;
	selected=0;
	cls(3);
	
	ui_x=0;
	move_ui();
	
	success=true;
	if (needsinit)
	{
		success=FAT_InitFiles(); //don't need to init multiple times
		needsinit=0;
	}
	else
	{
		selected=selectedrom;
	}
	if (success)
	{
		ui_x=255;
		move_ui();
		oldinput=AGBinput=~REG_P1;
		count=buildfiles();
		drawcfmenu(selected,count);

		for(i=0;i<8;i++)
		{
			waitframe();
			ui_x=224-i*32;
			move_ui();
		}

		do
		{
			key=getmenuinput(count);
			if (key&A_BTN)
			{
				type=execute(DATA[selected], &file);
				if (type==3)
				{
					for(i=1;i<9;i++)
					{
						waitframe();
						ui_x=i*32;
						move_ui();
					}
					make_ui_invisible();
					selectedrom=selected;
					return file;
				}
				else if (type==2)
				{
					count=buildfiles();
					selected=0;
					scroll_right(selected,count);
				}
			}
			if (key&B_BTN)
			{
				if (FAT_chdir(".."))
				{
					count=buildfiles();
					selected=0;
					scroll_left(selected,count);
				}
			}
			if (key!=0)
			{
				drawcfmenu(selected,count);
			}

		} while(1);
	}
	else
	{
		drawtext(0,"CF Failed to init!",0);
		while (1);
	}
	return 0;
}



int cistrcmp(const char *a, const char *b)
{
	int diff;
	do
	{
		diff=ucase(*((u8*)a))-ucase(*((u8*)b));
		if (diff!=0) return diff;
		if (*a=='\0') return 0;
		a++;
		b++;
	} while (1);
}

bool str_equiv(const char* str1, const char* str2)
{
	return cistrcmp(str1,str2)==0;
}
		

//__inline bool lessthan (char files[][32], u16 a, u16 b)
//{
//	return strcmp(files[a],files[b])<=0;
//}

void mergesort (char files[][32], u16 data[], u16 temp[], int size)
{
	int i;
	int a;
	int a_end;
	int b;
	int b_end;
	int c;
	int step;
	step=2;
	while(step/2<size)
	{
		for (i=0;i<size;i+=step)
		{
			a=i;
			a_end=i+step/2;
			if (a_end>=size) break;
			b=a_end;
			b_end=i+step;
			if (b_end>size) b_end=size;
			c=i;
			while(1)
			{
				if (a==a_end)
				{
					if (b==b_end)
					{
						break;
					}
					temp[c]=data[b];
					c++;
					b++;
				}
				else if (b==b_end)
				{
					temp[c]=data[a];
					c++;
					a++;
				}
				else
				{
					if ( cistrcmp(files[data[a]],files[data[b]])<=0 )
					{
						temp[c]=data[a];
						c++;
						a++;
					}
					else
					{
						temp[c]=data[b];
						c++;
						b++;
					}
				}
			}
			memcpy(data+i,temp+i,step*sizeof(u16));
		}
		step=step*2;
	}
}

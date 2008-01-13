#ifndef __ASMCALLS_H__
#define __ASMCALLS_H__

#include "fs.h"
//#include "cache.h"

extern u8 ui_border_visible;
extern u8 ui_moved;
//extern u8 border_visible;
extern int ui_x;
extern int ui_y;

extern u8 sgb_palette_number;

#if !GCC
extern u8 Image$$RO$$Base[];
extern u8 Image$$RW$$Base[];
extern u8 Image$$RO$$Limit[];
extern u8 Image$$RW$$Limit[];
#endif

extern u32 max_multiboot_size;

//gbz80.s
void update_doublespeed_ui(void);

void emu_reset(void);
void cpuhack_reset(void);
void run(int dont_stop);
extern u32 op_table[256];
extern void default_scanlinehook(void);
extern u32 cpustate[26];

extern u8 *rommap[16];
extern u8 *g_memmap_tbl[16];

extern void* g_readmem_tbl[8];
extern void* g_writemem_tbl[8];

extern u32 frametotal;
extern u32 sleeptime;
extern u8 novblankwait;
extern u8 request_gb_type;
extern u8 request_gba_mode;

extern u8 g_hackflags;
extern u32 num_speedhacks;
extern u16 speedhacks[256];

extern u8 gb_mode;
extern u8 doubletimer;

extern u32 dontstop;

//extern u8* g_gbz80_pc;
//extern u8* g_lastbank;

extern u8 XGB_RAM[0x2000];
extern u8 XGB_HRAM[128];
extern u8 XGB_SRAM[0x8000];
extern u8 XGB_VRAM[0x4000];
extern u8 GBC_EXRAM[0x6000];

extern u8 *XGB_sram, *XGB_vram, *GBC_exram, *END_of_exram;
extern u32 XGB_sramsize,XGB_vramsize,GBC_exramsize;

//apack.s
void depack(u8 *source, u8 *destination);

//boot.s
extern u8 font_lz77[];				//from boot.s
extern u8 fontpal_bin[];				//from boot.s

//cart.s

extern u8* INSTANT_PAGES[256];

extern u32 g_rammask;
extern u8 g_banks[2];

void loadcart(int rom_number,int emu_flags);			//from cart.s
void map0123_(int page);
void map4567_(int page);
void map01234567_(int page);
void mapAB_(int page);

int savestate(void* dest);
void loadstate(int, void* dest);

extern u32 g_emuflags;
extern u8* romstart;
extern u32 romnum;
extern u32 END_OF_EXRAM;

/*
extern char lfnName[256];
extern unsigned char globalBuffer[BYTE_PER_READ];
extern unsigned char fatWriteBuffer[BYTE_PER_READ];
extern unsigned char fatBuffer[BYTE_PER_READ];
extern FAT_FILE openFiles[MAX_FILES_OPEN];
*/

extern char SramName[256];
extern u8 mapperstate[32];

//void loadstate_gfx(void);

extern u8 AGB_BG[8192];

extern u8 g_cartflags;	//(from GB header)
extern int bcolor;		//Border Color

//io.s
extern u32 joycfg;				//from io.s
void resetSIO(u32);				//io.s
void vbaprint(const char *text);		//io.s
void LZ77UnCompVram(void *source,u16 *destination);		//io.s
void waitframe(void);			//io.s
int CheckGBAVersion(void);		//io.s
void suspend(void);			//io.s
void waitframe(void);		//io.s
int gettime(void);			//io.s

/*
//memory.s
extern u32 sram_R[];
extern u32 sram_W[];
extern u32 rom_R60[];
extern u32 empty_W[];
*/

//lcd.s
extern u32 *vblankfptr;			//from lcd.s
//extern u32 *vcountfptr;			//from lcd.s
extern u32 vbldummy;			//from lcd.s
extern u32 vblankinterrupt;		//from lcd.s
//extern u32 vcountinterrupt;		//from lcd.s
extern u32 AGBinput;			//from lcd.s
extern u32 EMUinput;

void GFX_init(void);			//lcd.s
void debug_(int,int);		//lcd.s
void paletteinit(void);		//lcd.s
void PaletteTxAll(void);	//lcd.s
void transfer_palette(void);	//lcd.s
void move_ui(void);
//void makeborder(void);		//lcd.s
extern u32 FPSValue;		//from lcd.s
extern u8 fpsenabled;		//from lcd.s
extern u32 palettebank;		//from lcd.s palette bank
//extern u32 bcolor;			//from lcd.s ,border color, black, grey, blue
extern u8 gammavalue;	//from lcd.s


//ppu.s
/*
extern u32 *vblankfptr;			//from ppu.s
extern u32 vbldummy;			//from ppu.s
extern u32 vblankinterrupt;		//from ppu.s
extern u32 AGBinput;			//from ppu.s
extern u32 EMUinput;

void debug_(int,int);		//ppu.s
void paletteinit(void);		//ppu.s
void PaletteTxAll(void);	//ppu.s

void PPU_reset(void);
void PPU_init(void);

extern u32 FPSValue;		//from ppu.s
extern char fpsenabled;		//from ppu.s
extern char gammavalue;		//from ppu.s
extern char twitch;			//from ppu.s
extern char flicker;		//from ppu.s
extern u32 wtop;			//from ppu.s

extern u32 ppustate[8];
extern u16 agb_pal[48];
extern u32 agb_nt_map[4];

*/

//sound.s
/*
void make_freq_table(void);
extern u16* freqtbl;
extern u16 FREQTBL2[2048];
*/

/*
*/

//visoly.s
void doReset(void);

//sgb.s
extern u8 g_update_border_palette;

#endif
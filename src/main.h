#include "includes.h"

extern u32 oldinput;
extern u8 *textstart;//points to first GB rom (initialized by boot.s)
extern int roms;//total number of roms
extern int selectedrom;
extern int ui_visible;
extern int ui_x;
extern int ui_y;
extern char pogoshell_romname[32];	//keep track of rom name (for state saving, etc)
extern char rtc;
extern char pogoshell;
extern char gameboyplayer;
extern char gbaversion;

//#define WORSTCASE ((82048)+(82048)/64+16+4+64)

void C_entry(void);
void splash(void);
void rommenu(void);
u8 *findrom(int n);
int drawmenu(int sel);
int getinput(void);
void cls(int chrmap);
void drawtext(int row,char *str,int hilite);
void drawtextl(int row,char *str,int hilite,int len);
void setdarknessgs(int dark);
void setbrightnessall(int light);
void make_ui_visible(void);
void make_ui_invisible(void);

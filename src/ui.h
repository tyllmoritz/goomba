#ifndef __UI_H__
#define __UI_H__

extern u8 autoA,autoB;				//0=off, 1=on, 2=R
extern u8 stime;
extern u8 autostate;
extern int selected;//selected menuitem.  used by all menus.
extern int mainmenuitems;//? or CARTMENUITEMS, depending on whether saving is allowed
extern u32 oldkey;//init this before using getmenuinput

u32 getmenuinput(int menuitems);
void ui(void);
void subui(int menunr);
void ui2(void);
void ui3(void);
int text(int row,char *str);
int text2(int row,char *str);
void strmerge(char *dst,char *src1,char *src2);
void drawui1(void);
void drawui2(void);
void drawui3(void);
void drawclock(void);
void autoAset(void);
void autoBset(void);
void controller(void);
void sleepset(void);
void vblset(void);
void fpsset(void);
void brightset(void);
void multiboot(void);
void restart(void);
void exit_(void);
void sleep_(void);
void fadetowhite(void);
void scrolll(int f);
void scrollr(void);
void swapAB(void);
void autostateset(void);
void chpalette(void);
void gbtype(void);
void gbatype(void);
void sgbpalnum(void);
void timermode(void);
void go_multiboot(void);

#endif

#ifndef __SAVESTATE_H__
#define __SAVESTATE_H__

extern const char statelist[37];
extern char stateexist[36];
extern const char saveversion[];

void dumpdata(File file, const char *tag, int size, void* data);
void dumpdata2(File file, int tagid);
bool loaddata(File file, char *tag, int *size);
int char_array_search(const char *lookfor, const char *const *const array, int arrsize);
bool loadblock(File file, const char *tag, int size);
bool savestate(const char *filename);
bool loadstate(const char *filename);
//void write_byte(char *address,u8 value);
void get_state_filename2(char state);
void restore_sram_filename(void);
void get_state_filename(void);
bool quicksave(void);
bool quickload(void);
bool state_exists(char state);
void find_save_slots(char *buffer);
void draw_state_menu(int sel, int mode);
void state_menu(int mode);
void selectstate(void);
void savestatemenu(void);
void loadstatemenu(void);

#endif

#ifndef __FILEMENU_H__
#define __FILEMENU_H__

#include "fs.h"

typedef char FILE_ENTRY[32];

int getvalidfile(int reset, char *filename);
int countroms(void);
int buildfiles(void);
int skipandget(int skipnum, char *filename);
bool remove_from_string(char *string, int pos, int count);
bool insert_into_string(char *string, int pos, const char *insertthis);
bool remove_string(char *string, const char *removethis);
bool search_replace(char *string, const char *replacethis, const char *withthis);
void fixfilename(int type, char *filename);
void drawcfmenu(int sel, int count);
void generate_sram_name(char *filename);
int execute(int sel, File *retfile);
File cfmenu(void);
int cistrcmp(const char *a, const char *b);
bool str_equiv(const char* str1, const char* str2);
void mergesort (char files[][32], u16 data[], u16 temp[], int size);

#endif

#ifndef __INCLUDES_H__
#define __INCLUDES_H__

#define VERSION "12-24-06"

#define LITTLESOUNDDJ 0
//Little Sound DJ Hack requires M3/G6/Supercard

#ifdef _GBAMP_VERSION
	#define MULTIBOOT 0
	#define CARTSRAM 0
	#define SPEEDHACKS 0
	#define USETRIM 1
	#define MOVIEPLAYER 1
	#define MOVIEPLAYERDEBUG 1
	#define RUMBLE 0
	#define RESIZABLE 1
	#define GOMULTIBOOT 0
	#define POGOSHELL 0
#else
	#define MULTIBOOT 1
	#define CARTSRAM 1
	#define SPEEDHACKS 0
	#define USETRIM 1
	#define MOVIEPLAYER 0
	#define MOVIEPLAYERDEBUG 0
	#define RUMBLE 1
	#define RESIZABLE 0
	#define GOMULTIBOOT 1
	#define POGOSHELL 1
#endif


//#if !RESIZABLE
//#define XGB_sram XGB_SRAM
//#define END_of_exram END_OF_EXRAM
//#endif

#include <stdio.h>
#include <string.h>
#include "gba.h"
#define move_ui()

#include "asmcalls.h"
#include "fs.h"
#include "minilzo.107/minilzo.h"
#include "main.h"
#include "ui.h"
#include "sram.h"
#include "rumble.h"
#include "speedhack.h"
#include "mbclient.h"
#include "cache.h"

#if MOVIEPLAYER
#include "filemenu.h"
#endif

#endif

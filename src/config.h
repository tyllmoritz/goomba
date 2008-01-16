#ifndef __CONFIG_H__
#define __CONFIG_H__

#define GCC 1

#define SRAM_SIZE 64

#define VERSION "1-16-08"

#define LITTLESOUNDDJ 0
//Little Sound DJ Hack requires M3/G6/Supercard


#ifdef _GBAMP_VERSION
	#define SPLASH 0
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
	#define SPLASH 1
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

#endif

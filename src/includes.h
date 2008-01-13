#ifndef __INCLUDES_H__
#define __INCLUDES_H__

#include "config.h"

//#if !RESIZABLE
//#define XGB_sram XGB_SRAM
//#define END_of_exram END_OF_EXRAM
//#endif

#include <stdio.h>
#include <string.h>
#include "gba.h"

#include "asmcalls.h"
//#include "fs.h"
#include "minilzo.107/minilzo.h"
#include "main.h"
#include "ui.h"
#include "sram.h"
#include "rumble.h"
//#include "speedhack.h"
#include "mbclient.h"
#include "cache.h"

#if MOVIEPLAYER
#include "filemenu.h"
#endif

#endif

#ifndef __FS_H__
#define __FS_H__

#define using_new_driver 1

#if !using_new_driver

#include "gbamp_cf.h"
typedef int File;
#define FAT_chdir(xxxx) FAT_CWD(xxxx)
#define NO_FILE -1
#define disc_IsInserted() CF_IsInserted()
#define FAT_FindNextFileLFN() FAT_FindNextFile()
#define FAT_FindFirstFileLFN() FAT_FindFirstFile()

typedef struct {
	u32 firstCluster;
	u32 length;
	u32 curPos;
	u32 curClus;			// Current cluster to read from
	int curSect;			// Current sector within cluster
	int curByte;			// Current byte within sector
	char readBuffer[512];	// Buffer used for unaligned reads
	u32 appClus;			// Cluster to append to
	int appSect;			// Sector within cluster for appending
	int appByte;			// Byte within sector for appending
	bool read;	// Can read from file
	bool write;	// Can write to file
	bool append;// Can append to file
	bool inUse;	// This file is open
	u32 dirEntSector;	// The sector where the directory entry is stored
	int dirEntOffset;	// The offset within the directory sector
}	FAT_FILE;

#else

#include "gba_nds_fat.h"
typedef FAT_FILE *File;
#define NO_FILE NULL

#endif

#define CARD_TIMEOUT	10000000		// Updated due to suggestion from SaTa, otherwise card will timeout sometimes on a write
#define BYTE_PER_READ 512

#endif

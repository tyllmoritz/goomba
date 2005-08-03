
typedef struct {
	u16 size;	//header+data
	u16 type;	//=STATESAVE or SRAMSAVE
	u32 compressedsize;
	u32 framecount;
	u32 checksum;
	char title[32];
} stateheader;


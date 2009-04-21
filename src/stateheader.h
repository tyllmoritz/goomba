
#define BORDERTAG 0x789b4987
#define PALETTETAG 0x987b4789

typedef struct {
	u16 size;	//header+data
	u16 type;	//=STATESAVE or SRAMSAVE
	u32 compressedsize;
	u32 framecount;
	u32 checksum;
	char title[32];
} stateheader;


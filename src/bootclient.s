; generated by Norcroft  ARM C vsn 4.90 (ARM Ltd SDT2.50) [Build number 80]

|x$codeseg| DATA

;;;1      #include "gba.h"
;;;2      
;;;3      #define CHRBASE (u16*)0x6000000
;;;4      #define BG0BASE (u16*)0x6004000
;;;5      #define BG1BASE (u16*)0x6008000
;;;6      
;;;7      extern u32 Image$$RW$$Limit;
;;;8      extern u32 IOmode;	//IOmode=4 when transfer is finished
;;;9      extern u32 current;	//bytes received
;;;10     extern u32 total;	//bytes expected
;;;11     
;;;12     void loader(void);
;;;13     void initgfx(void);
;;;14     void tilecopy(int,int);
;;;15     void irq(void);
;;;16     
;;;17     const u16 tile1[128]={
;;;18     0x1111,0x1111,0x1121,0x1222,0x1121,0x1212,0x1121,0x1222,
;;;19     0x1111,0x1111,0x1121,0x1222,0x1121,0x1212,0x1121,0x1222,
;;;20     0x1111,0x1111,0x1222,0x1121,0x1212,0x1121,0x1222,0x1121,
;;;21     0x1111,0x1111,0x1222,0x1222,0x1212,0x1212,0x1222,0x1222,
;;;22     0x1111,0x1111,0x1121,0x1222,0x1121,0x1212,0x1121,0x1222,
;;;23     0x1111,0x1111,0x1222,0x1121,0x1212,0x1121,0x1222,0x1121,
;;;24     0x1111,0x1111,0x1222,0x1222,0x1212,0x1212,0x1222,0x1222,
;;;25     0x1111,0x1111,0x1121,0x1121,0x1121,0x1121,0x1121,0x1121,
;;;26     0x1111,0x1111,0x1222,0x1222,0x1212,0x1212,0x1222,0x1222,
;;;27     0x1111,0x1111,0x1121,0x1222,0x1121,0x1212,0x1121,0x1222,
;;;28     0x1111,0x1111,0x1121,0x1121,0x1121,0x1121,0x1121,0x1121,
;;;29     0x1111,0x1111,0x1121,0x1222,0x1121,0x1212,0x1121,0x1222,
;;;30     0x1111,0x1111,0x1222,0x1121,0x1212,0x1121,0x1222,0x1121,
;;;31     0x1111,0x1111,0x1121,0x1121,0x1121,0x1121,0x1121,0x1121,
;;;32     0x1111,0x1111,0x1222,0x1222,0x1212,0x1212,0x1222,0x1222,
;;;33     0x1111,0x1111,0x1222,0x1121,0x1212,0x1121,0x1222,0x1121};
;;;34     const u16 tile2[64]={
;;;35     0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,
;;;36     0x1111,0x1111,0x1221,0x1211,0x1111,0x1112,0x1112,0x1211,
;;;37     0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,
;;;38     0x2111,0x1111,0x2111,0x1111,0x1121,0x2121,0x1111,0x2111,
;;;39     0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,
;;;40     0x1111,0x1112,0x1112,0x1111,0x1211,0x1112,0x1111,0x2111,
;;;41     0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,0x1111,
;;;42     0x1111,0x1121,0x1121,0x1111,0x2111,0x1121,0x1112,0x1111};
;;;43     
;;;44     void AGBmain() {
;;;45     	u32 *src=(u32*)0x20000c0;
                  AGBmain
000000  e3a01402          MOV      a2,#0x2000000
;;;46     	u32 *dst=(u32*)0x3000000;
000004  e3a00403          MOV      a1,#0x3000000
;;;47     	fptr jump_to_iwram=loader;
000008  e59f201c          LDR      a3,[pc, #L00002c-.-8]
;;;48     	__asm {mov sp,#0x3007f00}
00000c  e59f301c          LDR      a4,[pc, #L000030-.-8]
000010  e280dc7f          ADD      sp,a1,#0x7f00
000014  e28110c0          ADD      a2,a2,#0xc0   ;;;45
;;;49     	do {				//copy self to internal ram
;;;50     		*dst=*src;
                  |L000018.J4.AGBmain|
000018  e491c004          LDR      ip,[a2],#4
;;;51     		src++;
;;;52     		dst++;
;;;53     	} while(dst<&Image$$RW$$Limit);
00001c  e480c004          STR      ip,[a1],#4
000020  e1500003          CMP      a1,a4
000024  3afffffb          BCC      |L000018.J4.AGBmain|
;;;54     	jump_to_iwram();
000028  e282f000          ADD      pc,a3,#0
                  L00002c
00002c  00000000          DCD      loader
                  L000030
000030  00000000          DCD      |Image$$RW$$Limit|

;;;55     }
;;;56     
;;;57     void loader() {
                  loader
000034  e92d4ff0          STMDB    sp!,{v1-v8,lr}
;;;58     	int scrollpos=0;
000038  e3a04000          MOV      v1,#0
;;;59     	int tilerotate=0;
00003c  e3a05000          MOV      v2,#0
;;;60     	fptr jump_to_exram=(fptr)0x2000000;
000040  e3a0a402          MOV      v7,#0x2000000
;;;61     
;;;62     	initgfx();
000044  ebffffed          BL       initgfx
;;;63     
;;;64     	REG_IF=0xffff;		//stop any pending interrupts
000048  e3a01801          MOV      a2,#0x10000
00004c  e3a00301          MOV      a1,#0x4000000
000050  e2800c02          ADD      a1,a1,#0x200
000054  e2411001          SUB      a2,a2,#1
000058  e1c010b2          STRH     a2,[a1,#2]
;;;65     	REG_IE=0x0080;		//serial interrupt enable
00005c  e3a01080          MOV      a2,#0x80
000060  e1c010b0          STRH     a2,[a1,#0]
;;;66     	REG_IME=1;		//master interrupt enable
000064  e3a01001          MOV      a2,#1
000068  e1c010b8          STRH     a2,[a1,#8]
;;;67     	INTR_VECT=(u32)irq;
00006c  e3a00a07          MOV      a1,#0x7000
000070  e59f10cc          LDR      a2,[pc, #L000144-.-8]
000074  e2800403          ADD      a1,a1,#0x3000000
;;;68     
;;;69     	REG_RCNT=0;
000078  e5801ffc          STR      a2,[a1,#0xffc]
00007c  e3a0b301          MOV      v8,#0x4000000
000080  e28bbc01          ADD      v8,v8,#0x100
000084  e3a00000          MOV      a1,#0
000088  e1cb03b4          STRH     a1,[v8,#0x34]
;;;70     	REG_SIOMLT_SEND=0x99;	//ready to receive
00008c  e3a00099          MOV      a1,#0x99
000090  e1cb02ba          STRH     a1,[v8,#0x2a]
;;;71     	REG_SIOCNT=0x6003;
000094  e3a00003          MOV      a1,#3
000098  e2800a06          ADD      a1,a1,#0x6000
00009c  e1cb02b8          STRH     a1,[v8,#0x28]
0000a0  e59f80a0          LDR      v5,[pc, #L000148-.-8]
0000a4  e59f90a0          LDR      v6,[pc, #L00014c-.-8]
0000a8  e3a06301          MOV      v3,#0x4000000
0000ac  e59f709c          LDR      v4,[pc, #L000150-.-8]
0000b0  ea00001b          B        |L000124.J5.loader|
;;;72     
;;;73     	while(IOmode<4) {
;;;74     		scrollpos--;
                  |L0000b4.J4.loader|
0000b4  e2444001          SUB      v1,v1,#1
;;;75     		REG_BG1VOFS=scrollpos;
0000b8  e1c641b6          STRH     v1,[v3,#0x16]
;;;76     		REG_BG0VOFS=96+160*current/total;
0000bc  e5990000          LDR      a1,[v6,#0]
0000c0  e0801100          ADD      a2,a1,a1,LSL #2
0000c4  e1a01281          MOV      a2,a2,LSL #5
0000c8  e5980000          LDR      a1,[v5,#0]
0000cc  ebffffcb          BL       __rt_udiv
0000d0  e2800060          ADD      a1,a1,#0x60
0000d4  e1c601b2          STRH     a1,[v3,#0x12]
;;;77     		while(REG_VCOUNT>=160) {};	//wait a while
                  |L0000d8.J7.loader|
0000d8  e1d600b6          LDRH     a1,[v3,#6]
0000dc  e35000a0          CMP      a1,#0xa0
0000e0  aafffffc          BGE      |L0000d8.J7.loader|
;;;78     		while(REG_VCOUNT<160) {};
                  |L0000e4.J10.loader|
0000e4  e1d600b6          LDRH     a1,[v3,#6]
0000e8  e35000a0          CMP      a1,#0xa0
0000ec  bafffffc          BLT      |L0000e4.J10.loader|
;;;79     		if(!(scrollpos&3))
0000f0  e3140003          TST      v1,#3
;;;80     			tilecopy(2,tilerotate++);
0000f4  01a01005          MOVEQ    a2,v2
0000f8  02855001          ADDEQ    v2,v2,#1
0000fc  03a00002          MOVEQ    a1,#2
000100  0bffffbe          BLEQ     tilecopy
;;;81     		if(!(scrollpos&7))
000104  e3140007          TST      v1,#7
;;;82     			tilecopy(1,tilerotate>>1);
000108  01a010c5          MOVEQ    a2,v2,ASR #1
00010c  03a00001          MOVEQ    a1,#1
000110  0bffffba          BLEQ     tilecopy
;;;83     		if(!(scrollpos&15))
000114  e314000f          TST      v1,#0xf
;;;84     			tilecopy(0,tilerotate>>2);
000118  01a01145          MOVEQ    a2,v2,ASR #2
00011c  03a00000          MOVEQ    a1,#0
000120  0bffffb6          BLEQ     tilecopy
                  |L000124.J5.loader|
000124  e5970000          LDR      a1,[v4,#0]   ;;;73
000128  e3500004          CMP      a1,#4   ;;;73
00012c  3affffe0          BCC      |L0000b4.J4.loader|   ;;;73
;;;85     	}
;;;86     	REG_SIOCNT=0x2000;
000130  e3a00a02          MOV      a1,#0x2000
000134  e1cb02b8          STRH     a1,[v8,#0x28]
;;;87     	jump_to_exram();
000138  e28ac000          ADD      ip,v7,#0
00013c  e8bd4ff0          LDMIA    sp!,{v1-v8,lr}
000140  e1a0f00c          MOV      pc,ip
                  L000144
000144  00000000          DCD      irq
                  L000148
000148  00000000          DCD      total
                  L00014c
00014c  00000000          DCD      current
                  L000150
000150  00000000          DCD      IOmode

;;;88     }
;;;89     
;;;90     void initgfx() {
                  initgfx
000154  e92d4030          STMDB    sp!,{v1,v2,lr}
;;;91     	int i;
;;;92     	u16 *p,*q;
;;;93     	u32 seed1=0x87654321;
;;;94     	u32 seed2=0x12345678;
;;;95     	u32 tmp;
;;;96     
;;;97     	REG_DISPCNT=FORCE_BLANK;	//screen OFF
000158  e3a01080          MOV      a2,#0x80
00015c  e3a05301          MOV      v2,#0x4000000
000160  e5851000          STR      a2,[v2,#0]
;;;98     	REG_BG0CNT=0x8800;	//16color 256x512 CHRbase0 SCRbase8 priority0
000164  e3a01b22          MOV      a2,#0x8800
000168  e1c510b8          STRH     a2,[v2,#8]
;;;99     	REG_BG1CNT=0x1001;	//16color 256x256 CHRbase0 SCRbase16 priority1
00016c  e3a01001          MOV      a2,#1
000170  e2811a01          ADD      a2,a2,#0x1000
000174  e1c510ba          STRH     a2,[v2,#0xa]
;;;100    
;;;101    	p=BG0BASE; q=BG1BASE;
000178  e3a01901          MOV      a2,#0x4000
00017c  e2811406          ADD      a2,a2,#0x6000000
000180  e2814901          ADD      v1,a2,#0x4000
000184  e59f00f4          LDR      a1,[pc, #L000280-.-8]   ;;;93
000188  e59f20f4          LDR      a3,[pc, #L000284-.-8]   ;;;94
00018c  e1a03004          MOV      a4,v1
;;;102    	for(i=0;i<32*32;i++) {//blank both BGs
000190  e3a0c000          MOV      ip,#0
000194  e3a0e00c          MOV      lr,#0xc
;;;103    		*p=0x0c; *q=0x0c;
                  |L000198.J4.initgfx|
000198  e0c1e0b2          STRH     lr,[a2],#2
00019c  e28cc001          ADD      ip,ip,#1   ;;;102
0001a0  e35c0b01          CMP      ip,#0x400   ;;;102
0001a4  e0c3e0b2          STRH     lr,[a4],#2
0001a8  bafffffa          BLT      |L000198.J4.initgfx|   ;;;102
;;;104    		p++; q++;
;;;105    	}
;;;106    	for(i=0;i<32*32;i++) {//BG0="water" level
0001ac  e3a03000          MOV      a4,#0
;;;107    		tmp=seed1;		//silly random number generator
                  |L0001b0.J6.initgfx|
0001b0  e1a0c000          MOV      ip,a1
;;;108    		seed1+=seed2;
0001b4  e0800002          ADD      a1,a1,a3
;;;109    		seed2=tmp;
0001b8  e1a0200c          MOV      a3,ip
;;;110    		*p=seed1>>29;
0001bc  e1a0cea0          MOV      ip,a1,LSR #29
0001c0  e2833001          ADD      a4,a4,#1   ;;;106
0001c4  e3530b01          CMP      a4,#0x400   ;;;106
0001c8  e0c1c0b2          STRH     ip,[a2],#2
0001cc  bafffff7          BLT      |L0001b0.J6.initgfx|   ;;;106
;;;111    		p++;
;;;112    	}
;;;113    	*(p-1025)=0x0428;//splash
0001d0  e3a0c028          MOV      ip,#0x28
0001d4  e2413c09          SUB      a4,a2,#0x900
0001d8  e28ccb01          ADD      ip,ip,#0x400
0001dc  e1c3cfbe          STRH     ip,[a4,#0xfe]
;;;114    	*(p-1054)=0x29;
0001e0  e3a0c029          MOV      ip,#0x29
0001e4  e1c3ccb4          STRH     ip,[a4,#0xc4]
;;;115    	*(p-1024)=0x20;
0001e8  e3a03020          MOV      a4,#0x20
0001ec  e2411b02          SUB      a2,a2,#0x800
0001f0  e1c130b0          STRH     a4,[a2,#0]
;;;116    	*(p-1023)=0x21;
0001f4  e3a03021          MOV      a4,#0x21
0001f8  e1c130b2          STRH     a4,[a2,#2]
;;;117    	*(p-992)=0x22;
0001fc  e3a03022          MOV      a4,#0x22
000200  e1c134b0          STRH     a4,[a2,#0x40]
;;;118    	*(p-991)=0x23;
000204  e3a03023          MOV      a4,#0x23
000208  e1c134b2          STRH     a4,[a2,#0x42]
;;;119    	*(p-1022)=0x14;
00020c  e3a03014          MOV      a4,#0x14
000210  e1c130b4          STRH     a4,[a2,#4]
;;;120    	*(p-993)=0x15;
000214  e3a03015          MOV      a4,#0x15
000218  e1c133be          STRH     a4,[a2,#0x3e]
;;;121    	q=BG1BASE;
;;;122    	for(i=0;i<32;i++) {//BG1=bit stream
00021c  e3a01000          MOV      a2,#0
;;;123    		tmp=seed1;
                  |L000220.J8.initgfx|
000220  e1a03000          MOV      a4,a1
;;;124    		seed1+=seed2;
000224  e0800002          ADD      a1,a1,a3
;;;125    		seed2=tmp;
000228  e1a02003          MOV      a3,a4
;;;126    		*q=seed1>>29;
00022c  e1a03ea0          MOV      a4,a1,LSR #29
000230  e1c430b0          STRH     a4,[v1,#0]
;;;127    		*(q+1)=seed1&7;
000234  e2003007          AND      a4,a1,#7
000238  e1c430b2          STRH     a4,[v1,#2]
00023c  e2811001          ADD      a2,a2,#1   ;;;122
000240  e3510020          CMP      a2,#0x20   ;;;122
;;;128    		q+=32;
000244  e2844040          ADD      v1,v1,#0x40
000248  bafffff4          BLT      |L000220.J8.initgfx|   ;;;122
;;;129    	}
;;;130    	p=MEM_PALETTE;
;;;131    	p[0]=0x7fff; p[1]=0x7fff; p[2]=0;
00024c  e3a01902          MOV      a2,#0x8000
000250  e2411001          SUB      a2,a2,#1
000254  e3a00405          MOV      a1,#0x5000000   ;;;130
000258  e1c010b0          STRH     a2,[a1,#0]
00025c  e1c010b2          STRH     a2,[a1,#2]
000260  e3a01000          MOV      a2,#0
000264  e1c010b4          STRH     a2,[a1,#4]
;;;132    
;;;133    	REG_BG0HOFS=111;
000268  e3a0006f          MOV      a1,#0x6f
00026c  e1c501b0          STRH     a1,[v2,#0x10]
;;;134    	REG_BG1HOFS=111;
000270  e1c501b4          STRH     a1,[v2,#0x14]
;;;135    	REG_DISPCNT=BG0_EN|BG1_EN;
000274  e3a00c03          MOV      a1,#0x300
000278  e5850000          STR      a1,[v2,#0]
00027c  e8bd8030          LDMIA    sp!,{v1,v2,pc}
                  L000280
000280  87654321          DCD      0x87654321
                  L000284
000284  12345678          DCD      0x12345678

;;;136    }
;;;137    
;;;138    void tilecopy(int tileset,int rotate) {
                  tilecopy
000288  e52de004          STR      lr,[sp,#-4]!
;;;139    	u16 *p=CHRBASE+tileset*0x100;
00028c  e3a02406          MOV      a3,#0x6000000
;;;140    	int i;
;;;141    	rotate*=16;
000290  e1a03201          MOV      a4,a2,LSL #4
;;;142    	for(i=0;i<128;i++) {
000294  e59fc058          LDR      ip,[pc, #L0002f4-.-8]
000298  e3a01000          MOV      a2,#0
00029c  e0822480          ADD      a3,a3,a1,LSL #9   ;;;139
;;;143    		*p=tile1[(i+rotate)&127];
                  |L0002a0.J4.tilecopy|
0002a0  e081e003          ADD      lr,a2,a4
0002a4  e20ee07f          AND      lr,lr,#0x7f
0002a8  e1a0e08e          MOV      lr,lr,LSL #1
0002ac  e19ce0be          LDRH     lr,[ip,lr]
0002b0  e2811001          ADD      a2,a2,#1   ;;;142
0002b4  e3510080          CMP      a2,#0x80   ;;;142
0002b8  e0c2e0b2          STRH     lr,[a3],#2
0002bc  bafffff7          BLT      |L0002a0.J4.tilecopy|   ;;;142
;;;144    		p++;
;;;145    	}
;;;146    	if(tileset==2) for(i=0;i<64;i++) {
0002c0  e3500002          CMP      a1,#2
0002c4  149df004          LDRNE    pc,[sp],#4
0002c8  e3a00000          MOV      a1,#0
0002cc  e59f1024          LDR      a2,[pc, #L0002f8-.-8]
;;;147    		*p=tile2[(i+rotate)&63];
                  |L0002d0.J8.tilecopy|
0002d0  e080c003          ADD      ip,a1,a4
0002d4  e20cc03f          AND      ip,ip,#0x3f
0002d8  e1a0c08c          MOV      ip,ip,LSL #1
0002dc  e191c0bc          LDRH     ip,[a2,ip]
0002e0  e2800001          ADD      a1,a1,#1   ;;;146
0002e4  e3500040          CMP      a1,#0x40   ;;;146
0002e8  e0c2c0b2          STRH     ip,[a3],#2
0002ec  bafffff7          BLT      |L0002d0.J8.tilecopy|   ;;;146
0002f0  e49df004          LDR      pc,[sp],#4   ;;;146
                  L0002f4
0002f4  00000000          DCD      |x$constdata|   ;;;146
                  L0002f8
0002f8  00000100          DCD      |x$constdata|+0x100   ;;;146
;;;148    		p++;
;;;149    	}
;;;150    }
;;;151    
                          AREA |C$$constdata|, DATA, READONLY

|x$constdata|
                  tile1
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1222
                          DCW      0x1121,0x1212
                          DCW      0x1121,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1222
                          DCW      0x1121,0x1212
                          DCW      0x1121,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1121
                          DCW      0x1212,0x1121
                          DCW      0x1222,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1222
                          DCW      0x1212,0x1212
                          DCW      0x1222,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1222
                          DCW      0x1121,0x1212
                          DCW      0x1121,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1121
                          DCW      0x1212,0x1121
                          DCW      0x1222,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1222
                          DCW      0x1212,0x1212
                          DCW      0x1222,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1222
                          DCW      0x1212,0x1212
                          DCW      0x1222,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1222
                          DCW      0x1121,0x1212
                          DCW      0x1121,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1222
                          DCW      0x1121,0x1212
                          DCW      0x1121,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1121
                          DCW      0x1212,0x1121
                          DCW      0x1222,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1121,0x1121
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1222
                          DCW      0x1212,0x1212
                          DCW      0x1222,0x1222
                          DCW      0x1111,0x1111
                          DCW      0x1222,0x1121
                          DCW      0x1212,0x1121
                          DCW      0x1222,0x1121
                  tile2
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1221,0x1211
                          DCW      0x1111,0x1112
                          DCW      0x1112,0x1211
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x2111,0x1111
                          DCW      0x2111,0x1111
                          DCW      0x1121,0x2121
                          DCW      0x1111,0x2111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1112
                          DCW      0x1112,0x1111
                          DCW      0x1211,0x1112
                          DCW      0x1111,0x2111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1111
                          DCW      0x1111,0x1121
                          DCW      0x1121,0x1111
                          DCW      0x2111,0x1121
                          DCW      0x1112,0x1111

                          END

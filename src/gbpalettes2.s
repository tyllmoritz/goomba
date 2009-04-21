	AREA rom_code, CODE, READONLY
EXPORT GBPalettes
EXPORT GBPalettes_end

GBPalettes

;pea soup
	DCB 171,200,26, 101,166,68, 66,118,66, 26,75,50
;	DCB 171,200,26, 101,166,68, 66,118,66, 26,75,50
	DCB 171,200,26, 101,166,68, 66,118,66, 26,75,50
	DCB 171,200,26, 101,166,68, 66,118,66, 26,75,50
;yellow
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;BG
;	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;WIN
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;OB0
	DCB 0xF3,0xFF,0x33, 0xC1,0xCE,0x22, 0x6F,0x7B,0x11, 0x00,0x00,0x00		;OB1
;grey
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;multi1
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
	DCB 0xEF,0xEF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	DCB 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
;multi2
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;	DCB 0xE7,0xEF,0xD6, 0xC6,0xDE,0x8C, 0x6B,0x84,0x29, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
;Zelda.
	DCB 0xFF,0xFF,0xA0, 0x67,0xD7,0x67, 0x8C,0x55,0x20, 0x46,0x15,0x07
;	DCB 0xFF,0xFF,0xAD, 0x80,0x80,0xB7, 0x25,0x29,0x59, 0x00,0x00,0x00
	DCB 0xFF,0xB0,0x7F, 0x5A,0x8C,0xE7, 0x18,0x4A,0x9C, 0x00,0x00,0x00
	DCB 0xFF,0xEF,0xEF, 0xEF,0x5A,0x63, 0xAD,0x10,0x18, 0x00,0x00,0x00
;Metroid
	DCB 0xDF,0xDF,0x7F, 0x00,0x5F,0xAF, 0x1F,0x3F,0x1F, 0x00,0x00,0x00
;	DCB 0xFF,0xDF,0x00, 0x80,0xFF,0xFF, 0x00,0x80,0x80, 0x00,0x00,0x00
	DCB 0xFF,0xDF,0x00, 0xFF,0x00,0x00, 0x3F,0x37,0x00, 0x00,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xC0,0xC0,0xC0, 0x80,0x80,0x80, 0x00,0x00,0x00
;Adventure Island
	DCB 0xFF,0xFF,0xFF, 0x9C,0xB5,0xFF, 0x31,0x94,0x00, 0x00,0x00,0x00
;	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	DCB 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Adventure Island 2
	DCB 0xFF,0xFF,0xFF, 0xF7,0xEF,0x75, 0x29,0x6B,0xBD, 0x00,0x00,0x00
;	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xFF,0xDE, 0xEF,0xC6,0x73, 0xFF,0x63,0x52, 0x00,0x00,0x29
	DCB 0xFF,0xFF,0xFF, 0xE7,0xA5,0xA5, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Balloon Kid
	DCB 0xA5,0xD6,0xFF, 0xE7,0xEF,0xFF, 0xDE,0x8C,0x10, 0x5A,0x10,0x00
;	DCB 0xFF,0xFF,0xFF, 0xF7,0xCE,0x73, 0x8C,0x4A,0x08, 0x21,0x21,0x9C
	DCB 0xFF,0xC6,0xC6, 0xFF,0x6B,0x6B, 0xFF,0x00,0x00, 0x63,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xEF,0x42,0xEF, 0x7B,0x29,0x29, 0x42,0x00,0x00
;Batman
	DCB 0xFF,0xF7,0xEF, 0xC8,0x90,0x88, 0x84,0x50,0x44, 0x42,0x10,0x00
;	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xFF, 0x52,0x52,0xBD, 0x00,0x00,0xA5
	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xC6, 0x52,0x52,0x8C, 0x00,0x00,0x5A
	DCB 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
;Batman - Return of the Joker
	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
;	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	DCB 0xFF,0xFF,0xFF, 0xA5,0xAD,0xBD, 0x52,0x5A,0x7B, 0x00,0x10,0x39
	DCB 0xFF,0xFF,0xFF, 0xAD,0xB5,0xBD, 0x5A,0x6B,0x7B, 0x08,0x21,0x42
;Bionic Commando
	DCB 0xEF,0xF7,0xFF, 0xCE,0xB5,0xAD, 0xC6,0x21,0x29, 0x39,0x00,0x00
;	DCB 0xFF,0xFF,0xFF, 0x94,0xCE,0xF7, 0x10,0x39,0xFF, 0x00,0x00,0x4A
	DCB 0xFF,0xFF,0xFF, 0xFF,0xAD,0x84, 0x5A,0x39,0x00, 0x00,0x00,0x00
	DCB 0xEF,0xEF,0xEF, 0xAD,0xA5,0x9C, 0x6B,0x5A,0x5A, 0x42,0x10,0x08
;Castlevania Adventure
	DCB 0xD6,0xD6,0xE7, 0x8C,0xA5,0xB5, 0x42,0x52,0x6B, 0x00,0x10,0x18
;	DCB 0xFF,0xFF,0xFF, 0xA5,0xA5,0xD6, 0x52,0x52,0xAD, 0x00,0x00,0x84
	DCB 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x5A,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xF7,0xEF,0xCE, 0xF7,0xDE,0x9C, 0xF7,0xB5,0x6B
;Dr. Mario
	DCB 0xFF,0xFF,0xFF, 0xFF,0xFF,0x66, 0x21,0x42,0xFF, 0x00,0x10,0x52
;	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xD6, 0x55,0x55,0xAD, 0x00,0x00,0x84
	DCB 0xFF,0xFF,0xFF, 0xFF,0xE7,0x84, 0xFF,0x52,0x42, 0x8C,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xFF,0xCE,0x8C, 0xF7,0x9C,0x5A, 0x84,0x52,0x00
;Kirby
	DCB 0xFF,0xFF,0x83, 0xFF,0xA5,0x3E, 0x73,0x42,0x00, 0x33,0x09,0x00
;	DCB 0xCC,0xCC,0xFF, 0x77,0x78,0xFF, 0x23,0x35,0xC1, 0x05,0x0A,0x5A
	DCB 0xFF,0xBD,0xC4, 0xF1,0x4D,0x60, 0x9F,0x12,0x29, 0x20,0x00,0x00
	DCB 0xFF,0xFF,0xFF, 0xAA,0xAA,0xAA, 0x55,0x55,0x55, 0x00,0x00,0x00
;Donkey Kong Land
	DCB 0xE2,0xFF,0xD1, 0xA9,0xFF,0x89, 0x51,0xA2,0x48, 0x04,0x25,0x03
;	DCB 0xFF,0xB4,0xB4, 0xFF,0x47,0x47, 0x80,0x00,0x00, 0x00,0x00,0x00
	DCB 0xFF,0xF2,0xB0, 0xD6,0xC3,0x4D, 0xA3,0x5B,0x11, 0x6A,0x00,0x00
	DCB 0xF7,0xFF,0x63, 0xC6,0xCE,0x42, 0x73,0x7B,0x21, 0x00,0x00,0x00

;1A	// Lord Asaki: whole lotta colors added here
	DCB 0xF8,0xE8,0xC8, 0xD8,0x90,0x48, 0xA8,0x28,0x20, 0x30,0x18,0x50		;BG
;	DCB 0xF8,0xE8,0xC8, 0xD8,0x90,0x48, 0xA8,0x28,0x20, 0x30,0x18,0x50		;WIN
	DCB 0xF8,0xE8,0xC8, 0xD8,0x90,0x48, 0xA8,0x28,0x20, 0x30,0x18,0x50		;OB0
	DCB 0xF8,0xE8,0xC8, 0xD8,0x90,0x48, 0xA8,0x28,0x20, 0x30,0x18,0x50		;OB1
;1B
	DCB 0xD8,0xD8,0xC0, 0xC8,0xB0,0x70, 0xB0,0x50,0x10, 0x00,0x00,0x00
;	DCB 0xD8,0xD8,0xC0, 0xC8,0xB0,0x70, 0xB0,0x50,0x10, 0x00,0x00,0x00
	DCB 0xD8,0xD8,0xC0, 0xC8,0xB0,0x70, 0xB0,0x50,0x10, 0x00,0x00,0x00
	DCB 0xD8,0xD8,0xC0, 0xC8,0xB0,0x70, 0xB0,0x50,0x10, 0x00,0x00,0x00
;1C
	DCB 0xF8,0xC0,0xF8, 0xE8,0x98,0x50, 0x98,0x38,0x60, 0x38,0x38,0x98
;	DCB 0xF8,0xC0,0xF8, 0xE8,0x98,0x50, 0x98,0x38,0x60, 0x38,0x38,0x98
	DCB 0xF8,0xC0,0xF8, 0xE8,0x98,0x50, 0x98,0x38,0x60, 0x38,0x38,0x98
	DCB 0xF8,0xC0,0xF8, 0xE8,0x98,0x50, 0x98,0x38,0x60, 0x38,0x38,0x98
;1D
	DCB 0xF8,0xF8,0xA8, 0xC0,0x80,0x48, 0xF8,0x00,0x00, 0x50,0x18,0x00
;	DCB 0xF8,0xF8,0xA8, 0xC0,0x80,0x48, 0xF8,0x00,0x00, 0x50,0x18,0x00
	DCB 0xF8,0xF8,0xA8, 0xC0,0x80,0x48, 0xF8,0x00,0x00, 0x50,0x18,0x00
	DCB 0xF8,0xF8,0xA8, 0xC0,0x80,0x48, 0xF8,0x00,0x00, 0x50,0x18,0x00
;1E
	DCB 0xF8,0xD8,0xB0, 0x78,0xC0,0x78, 0x68,0x88,0x40, 0x58,0x38,0x20
;	DCB 0xF8,0xD8,0xB0, 0x78,0xC0,0x78, 0x68,0x88,0x40, 0x58,0x38,0x20
	DCB 0xF8,0xD8,0xB0, 0x78,0xC0,0x78, 0x68,0x88,0x40, 0x58,0x38,0x20
	DCB 0xF8,0xD8,0xB0, 0x78,0xC0,0x78, 0x68,0x88,0x40, 0x58,0x38,0x20
;1F
	DCB 0xD8,0xE8,0xF8, 0xE0,0x88,0x50, 0xA8,0x00,0x00, 0x00,0x40,0x10
;	DCB 0xD8,0xE8,0xF8, 0xE0,0x88,0x50, 0xA8,0x00,0x00, 0x00,0x40,0x10
	DCB 0xD8,0xE8,0xF8, 0xE0,0x88,0x50, 0xA8,0x00,0x00, 0x00,0x40,0x10
	DCB 0xD8,0xE8,0xF8, 0xE0,0x88,0x50, 0xA8,0x00,0x00, 0x00,0x40,0x10
;1G
	DCB 0x00,0x00,0x50, 0x00,0xA0,0xE8, 0x78,0x78,0x00, 0xF8,0xF8,0x58
;	DCB 0x00,0x00,0x50, 0x00,0xA0,0xE8, 0x78,0x78,0x00, 0xF8,0xF8,0x58
	DCB 0x00,0x00,0x50, 0x00,0xA0,0xE8, 0x78,0x78,0x00, 0xF8,0xF8,0x58
	DCB 0x00,0x00,0x50, 0x00,0xA0,0xE8, 0x78,0x78,0x00, 0xF8,0xF8,0x58
;1H
	DCB 0xF8,0xE8,0xE0, 0xF8,0xB8,0x88, 0x80,0x40,0x00, 0x30,0x18,0x00
;	DCB 0xF8,0xE8,0xE0, 0xF8,0xB8,0x88, 0x80,0x40,0x00, 0x30,0x18,0x00
	DCB 0xF8,0xE8,0xE0, 0xF8,0xB8,0x88, 0x80,0x40,0x00, 0x30,0x18,0x00
	DCB 0xF8,0xE8,0xE0, 0xF8,0xB8,0x88, 0x80,0x40,0x00, 0x30,0x18,0x00
;2A
	DCB 0xF0,0xC8,0xA0, 0xC0,0x88,0x48, 0x28,0x78,0x00, 0x00,0x00,0x00
;	DCB 0xF0,0xC8,0xA0, 0xC0,0x88,0x48, 0x28,0x78,0x00, 0x00,0x00,0x00
	DCB 0xF0,0xC8,0xA0, 0xC0,0x88,0x48, 0x28,0x78,0x00, 0x00,0x00,0x00
	DCB 0xF0,0xC8,0xA0, 0xC0,0x88,0x48, 0x28,0x78,0x00, 0x00,0x00,0x00
;2B
	DCB 0xF8,0xF8,0xF8, 0xF8,0xE8,0x50, 0xF8,0x30,0x00, 0x50,0x00,0x58
;	DCB 0xF8,0xF8,0xF8, 0xF8,0xE8,0x50, 0xF8,0x30,0x00, 0x50,0x00,0x58
	DCB 0xF8,0xF8,0xF8, 0xF8,0xE8,0x50, 0xF8,0x30,0x00, 0x50,0x00,0x58
	DCB 0xF8,0xF8,0xF8, 0xF8,0xE8,0x50, 0xF8,0x30,0x00, 0x50,0x00,0x58
;2C
	DCB 0xF8,0xC0,0xF8, 0xE8,0x88,0x88, 0x78,0x30,0xE8, 0x28,0x28,0x98
;	DCB 0xF8,0xC0,0xF8, 0xE8,0x88,0x88, 0x78,0x30,0xE8, 0x28,0x28,0x98
	DCB 0xF8,0xC0,0xF8, 0xE8,0x88,0x88, 0x78,0x30,0xE8, 0x28,0x28,0x98
	DCB 0xF8,0xC0,0xF8, 0xE8,0x88,0x88, 0x78,0x30,0xE8, 0x28,0x28,0x98
;2D
	DCB 0xF8,0xF8,0xA0, 0x00,0xF8,0x00, 0xF8,0x30,0x00, 0x00,0x00,0x50
;	DCB 0xF8,0xF8,0xA0, 0x00,0xF8,0x00, 0xF8,0x30,0x00, 0x00,0x00,0x50
	DCB 0xF8,0xF8,0xA0, 0x00,0xF8,0x00, 0xF8,0x30,0x00, 0x00,0x00,0x50
	DCB 0xF8,0xF8,0xA0, 0x00,0xF8,0x00, 0xF8,0x30,0x00, 0x00,0x00,0x50
;2E
	DCB 0xF8,0xC8,0x80, 0x90,0xB0,0xE0, 0x28,0x10,0x60, 0x10,0x08,0x10
;	DCB 0xF8,0xC8,0x80, 0x90,0xB0,0xE0, 0x28,0x10,0x60, 0x10,0x08,0x10
	DCB 0xF8,0xC8,0x80, 0x90,0xB0,0xE0, 0x28,0x10,0x60, 0x10,0x08,0x10
	DCB 0xF8,0xC8,0x80, 0x90,0xB0,0xE0, 0x28,0x10,0x60, 0x10,0x08,0x10
;2F
	DCB 0xD0,0xF8,0xF8, 0xF8,0x90,0x50, 0xA0,0x00,0x00, 0x18,0x00,0x00
;	DCB 0xD0,0xF8,0xF8, 0xF8,0x90,0x50, 0xA0,0x00,0x00, 0x18,0x00,0x00
	DCB 0xD0,0xF8,0xF8, 0xF8,0x90,0x50, 0xA0,0x00,0x00, 0x18,0x00,0x00
	DCB 0xD0,0xF8,0xF8, 0xF8,0x90,0x50, 0xA0,0x00,0x00, 0x18,0x00,0x00
;2G
	DCB 0x68,0xB8,0x38, 0xE0,0x50,0x40, 0xE0,0xB8,0x80, 0x00,0x18,0x00
;	DCB 0x68,0xB8,0x38, 0xE0,0x50,0x40, 0xE0,0xB8,0x80, 0x00,0x18,0x00
	DCB 0x68,0xB8,0x38, 0xE0,0x50,0x40, 0xE0,0xB8,0x80, 0x00,0x18,0x00
	DCB 0x68,0xB8,0x38, 0xE0,0x50,0x40, 0xE0,0xB8,0x80, 0x00,0x18,0x00
;2H
	DCB 0xF8,0xF8,0xF8, 0xB8,0xB8,0xB8, 0x70,0x70,0x70, 0x00,0x00,0x00
;	DCB 0xF8,0xF8,0xF8, 0xB8,0xB8,0xB8, 0x70,0x70,0x70, 0x00,0x00,0x00
	DCB 0xF8,0xF8,0xF8, 0xB8,0xB8,0xB8, 0x70,0x70,0x70, 0x00,0x00,0x00
	DCB 0xF8,0xF8,0xF8, 0xB8,0xB8,0xB8, 0x70,0x70,0x70, 0x00,0x00,0x00
;3A
	DCB 0xF8,0xD0,0x98, 0x70,0xC0,0xC0, 0xF8,0x60,0x28, 0x30,0x48,0x60
;	DCB 0xF8,0xD0,0x98, 0x70,0xC0,0xC0, 0xF8,0x60,0x28, 0x30,0x48,0x60
	DCB 0xF8,0xD0,0x98, 0x70,0xC0,0xC0, 0xF8,0x60,0x28, 0x30,0x48,0x60
	DCB 0xF8,0xD0,0x98, 0x70,0xC0,0xC0, 0xF8,0x60,0x28, 0x30,0x48,0x60
;3B
	DCB 0xD8,0xD8,0xC0, 0xE0,0x80,0x20, 0x00,0x50,0x00, 0x00,0x10,0x10
;	DCB 0xD8,0xD8,0xC0, 0xE0,0x80,0x20, 0x00,0x50,0x00, 0x00,0x10,0x10
	DCB 0xD8,0xD8,0xC0, 0xE0,0x80,0x20, 0x00,0x50,0x00, 0x00,0x10,0x10
	DCB 0xD8,0xD8,0xC0, 0xE0,0x80,0x20, 0x00,0x50,0x00, 0x00,0x10,0x10
;3C
	DCB 0xE0,0xA8,0xC8, 0xF8,0xF8,0x78, 0x00,0xB8,0xF8, 0x20,0x20,0x58
;	DCB 0xE0,0xA8,0xC8, 0xF8,0xF8,0x78, 0x00,0xB8,0xF8, 0x20,0x20,0x58
	DCB 0xE0,0xA8,0xC8, 0xF8,0xF8,0x78, 0x00,0xB8,0xF8, 0x20,0x20,0x58
	DCB 0xE0,0xA8,0xC8, 0xF8,0xF8,0x78, 0x00,0xB8,0xF8, 0x20,0x20,0x58
;3D
	DCB 0xF0,0xF8,0xB8, 0xE0,0xA8,0x78, 0x08,0xC8,0x00, 0x00,0x00,0x00
;	DCB 0xF0,0xF8,0xB8, 0xE0,0xA8,0x78, 0x08,0xC8,0x00, 0x00,0x00,0x00
	DCB 0xF0,0xF8,0xB8, 0xE0,0xA8,0x78, 0x08,0xC8,0x00, 0x00,0x00,0x00
	DCB 0xF0,0xF8,0xB8, 0xE0,0xA8,0x78, 0x08,0xC8,0x00, 0x00,0x00,0x00
;3E
	DCB 0xF8,0xF8,0xC0, 0xE0,0xB0,0x68, 0xB0,0x78,0x20, 0x50,0x48,0x70
;	DCB 0xF8,0xF8,0xC0, 0xE0,0xB0,0x68, 0xB0,0x78,0x20, 0x50,0x48,0x70
	DCB 0xF8,0xF8,0xC0, 0xE0,0xB0,0x68, 0xB0,0x78,0x20, 0x50,0x48,0x70
	DCB 0xF8,0xF8,0xC0, 0xE0,0xB0,0x68, 0xB0,0x78,0x20, 0x50,0x48,0x70
;3F
	DCB 0x78,0x78,0xC8, 0xF8,0x68,0xF8, 0xF8,0xD0,0x00, 0x40,0x40,0x40
;	DCB 0x78,0x78,0xC8, 0xF8,0x68,0xF8, 0xF8,0xD0,0x00, 0x40,0x40,0x40
	DCB 0x78,0x78,0xC8, 0xF8,0x68,0xF8, 0xF8,0xD0,0x00, 0x40,0x40,0x40
	DCB 0x78,0x78,0xC8, 0xF8,0x68,0xF8, 0xF8,0xD0,0x00, 0x40,0x40,0x40
;3G
	DCB 0x60,0xD8,0x50, 0xF8,0xF8,0xF8, 0xC8,0x30,0x38, 0x38,0x00,0x00
;	DCB 0x60,0xD8,0x50, 0xF8,0xF8,0xF8, 0xC8,0x30,0x38, 0x38,0x00,0x00
	DCB 0x60,0xD8,0x50, 0xF8,0xF8,0xF8, 0xC8,0x30,0x38, 0x38,0x00,0x00
	DCB 0x60,0xD8,0x50, 0xF8,0xF8,0xF8, 0xC8,0x30,0x38, 0x38,0x00,0x00
;3H
	DCB 0xE0,0xF8,0xA0, 0x78,0xC8,0x38, 0x48,0x88,0x18, 0x08,0x18,0x00
;	DCB 0xE0,0xF8,0xA0, 0x78,0xC8,0x38, 0x48,0x88,0x18, 0x08,0x18,0x00
	DCB 0xE0,0xF8,0xA0, 0x78,0xC8,0x38, 0x48,0x88,0x18, 0x08,0x18,0x00
	DCB 0xE0,0xF8,0xA0, 0x78,0xC8,0x38, 0x48,0x88,0x18, 0x08,0x18,0x00
;4A
	DCB 0xF0,0xA8,0x68, 0x78,0xA8,0xF8, 0xD0,0x00,0xD0, 0x00,0x00,0x78
;	DCB 0xF0,0xA8,0x68, 0x78,0xA8,0xF8, 0xD0,0x00,0xD0, 0x00,0x00,0x78
	DCB 0xF0,0xA8,0x68, 0x78,0xA8,0xF8, 0xD0,0x00,0xD0, 0x00,0x00,0x78
	DCB 0xF0,0xA8,0x68, 0x78,0xA8,0xF8, 0xD0,0x00,0xD0, 0x00,0x00,0x78
;4B
	DCB 0xF0,0xE8,0xF0, 0xE8,0xA0,0x60, 0x40,0x78,0x38, 0x18,0x08,0x08
;	DCB 0xF0,0xE8,0xF0, 0xE8,0xA0,0x60, 0x40,0x78,0x38, 0x18,0x08,0x08
	DCB 0xF0,0xE8,0xF0, 0xE8,0xA0,0x60, 0x40,0x78,0x38, 0x18,0x08,0x08
	DCB 0xF0,0xE8,0xF0, 0xE8,0xA0,0x60, 0x40,0x78,0x38, 0x18,0x08,0x08
;4C
	DCB 0xF8,0xE0,0xE0, 0xD8,0xA0,0xD0, 0x98,0xA0,0xE0, 0x08,0x00,0x00
;	DCB 0xF8,0xE0,0xE0, 0xD8,0xA0,0xD0, 0x98,0xA0,0xE0, 0x08,0x00,0x00
	DCB 0xF8,0xE0,0xE0, 0xD8,0xA0,0xD0, 0x98,0xA0,0xE0, 0x08,0x00,0x00
	DCB 0xF8,0xE0,0xE0, 0xD8,0xA0,0xD0, 0x98,0xA0,0xE0, 0x08,0x00,0x00
;4D
	DCB 0xF8,0xF8,0xB8, 0x90,0xC8,0xC8, 0x48,0x68,0x78, 0x08,0x20,0x48
;	DCB 0xF8,0xF8,0xB8, 0x90,0xC8,0xC8, 0x48,0x68,0x78, 0x08,0x20,0x48
	DCB 0xF8,0xF8,0xB8, 0x90,0xC8,0xC8, 0x48,0x68,0x78, 0x08,0x20,0x48
	DCB 0xF8,0xF8,0xB8, 0x90,0xC8,0xC8, 0x48,0x68,0x78, 0x08,0x20,0x48
;4E
	DCB 0xF8,0xD8,0xA8, 0xE0,0xA8,0x78, 0x78,0x58,0x88, 0x00,0x20,0x30
;	DCB 0xF8,0xD8,0xA8, 0xE0,0xA8,0x78, 0x78,0x58,0x88, 0x00,0x20,0x30
	DCB 0xF8,0xD8,0xA8, 0xE0,0xA8,0x78, 0x78,0x58,0x88, 0x00,0x20,0x30
	DCB 0xF8,0xD8,0xA8, 0xE0,0xA8,0x78, 0x78,0x58,0x88, 0x00,0x20,0x30
;4F
	DCB 0xB8,0xD0,0xD0, 0xD8,0x80,0xD8, 0x80,0x00,0xA0, 0x38,0x00,0x00
;	DCB 0xB8,0xD0,0xD0, 0xD8,0x80,0xD8, 0x80,0x00,0xA0, 0x38,0x00,0x00
	DCB 0xB8,0xD0,0xD0, 0xD8,0x80,0xD8, 0x80,0x00,0xA0, 0x38,0x00,0x00
	DCB 0xB8,0xD0,0xD0, 0xD8,0x80,0xD8, 0x80,0x00,0xA0, 0x38,0x00,0x00
;4G
	DCB 0xB0,0xE0,0x18, 0xB8,0x20,0x58, 0x28,0x10,0x00, 0x00,0x80,0x60
;	DCB 0xB0,0xE0,0x18, 0xB8,0x20,0x58, 0x28,0x10,0x00, 0x00,0x80,0x60
	DCB 0xB0,0xE0,0x18, 0xB8,0x20,0x58, 0x28,0x10,0x00, 0x00,0x80,0x60
	DCB 0xB0,0xE0,0x18, 0xB8,0x20,0x58, 0x28,0x10,0x00, 0x00,0x80,0x60
;4H
	DCB 0xF8,0xF8,0xC8, 0xB8,0xC0,0x58, 0x80,0x88,0x40, 0x40,0x50,0x28
;	DCB 0xF8,0xF8,0xC8, 0xB8,0xC0,0x58, 0x80,0x88,0x40, 0x40,0x50,0x28
	DCB 0xF8,0xF8,0xC8, 0xB8,0xC0,0x58, 0x80,0x88,0x40, 0x40,0x50,0x28
	DCB 0xF8,0xF8,0xC8, 0xB8,0xC0,0x58, 0x80,0x88,0x40, 0x40,0x50,0x28
GBPalettes_end


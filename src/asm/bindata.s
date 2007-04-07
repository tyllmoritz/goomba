	.text
	.global font
	.global fontpal

font:
	.incbin "bin/font.lz77"
fontpal:
	.incbin "bin/fontpal.bin"

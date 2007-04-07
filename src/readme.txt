This is the second snapshot of me trying to convert Goomba Color to the GNU Assembler.
(12:33AM CDT, 4/8/2007)

Contents:
src\source_conversion_tools:
	The hacky tools I made to convert much of the code's syntax
src\source_conversion_tools\labelkiller:
	Labelkiller - Takes in a list of labels, then for each "LDR, STR, ADR" line in the source code which refers to one of those labels, adds a underscore suffix.  This lets me kill off the register reletive labels by replacing them with macros like ldr_ str_ adr_.
src\source_conversion_tools\asmconv2:
	Asmconv2 - Tries to convert ARM SDT-formatted code to GNU-formatted code.  Conversion is not complete.
src\c:
	The C sources for goomba color
src\asm_old:
	The ASM source (ARM SDT) for Goomba Color.  Register Reletive labels were removed with almost no change in the binary.  Labelkiller works wonders.
src\asm:
	The ASM source, changed to GNU Assembler.  Code had to be integrated into one big file, which is very ugly and wrong, but works.	
	Assemble only "all.s".

Not yet finished C stuff:
	* Some C files referred to "image$$ro$$limit" (ARM SDT linker variable which pointed after the last byte of ewram).  Those got replaced with a new variable called "ewram_textstart", but that variable is never initialized.  Something like that would usually be initialze by the boot system, but this version does not yet have the new boot system in.  If someone could tell me the equivalent linker variable for GCC I'd appreciate that.
	* "mbclient.c" basically takes the sections for the code, and sends them over the link cable.  It sends the EWRAM and IWRAM data over, since the complete original binary is not intact after the boot process.  This code is very highly dependent on ARM SDT's linking variables and convention, so it needs to be completly changed around along with the new boot system.

Necessary to do/I need help:
	New boot code, the ctr0 which comes with devkitarm is not good enough.  Needs these features:
	* Get the address of the last byte in the binary, and store it to a variable.  This probably isn't necessary if someone points out to me which linker variable this is.  Also need to get the address of the last byte of EWRAM.
	* In multiboot mode, remove the sections that do not stay in EWRAM.  Also make sure there are no holes (all non-ewram content strictly comes after ewram content in the binary)
	* In multiboot mode, move the appended content (initially stored after the end of the MB binary) over to what becomes the last byte of EWRAM. This removes the IWRAM content from EWRAM. Also store a pointer to the location the appended data was copied to.

	I also don't get makefiles at all.  If someone could help me there, I would appreciate it.


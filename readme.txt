Goomba Color 01-26-2008
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
By Dwedit (Dan Weiss)
http://www.dwedit.org/gba/goombacolor.php

It's a Game Boy Color emulator for the Game Boy Advance. 
- Why? Because the GB Micro and DS can't play GBC games!

Stay tuned for updates!  Check the Pocketheaven forums for a later version!
http://www.pocketheaven.com/boards/viewforum.php?f=29

Known Issues:
	Background tiles not updated at same time as tile graphics
	Savestates are broken, therefore DISABLED in this version.
	Timing may be off
	No "hi-color mode"

Todo:
	Fix Savestates
	Add real HDMA
	Fix the broken games
	Add mid-screen palette changes


Getting Started
-=-=-=-=-=-=-=-

Before you can use Goomba Color, you need to add some GB roms to the emulator.
You can do this with various tools (Goomba Front etc.).
Or you can do it manual by using a "DOS" shell:
copy /b goomba.gba+game1.gb+game2.gb goombamenu.gba
you can also insert a splashscreen between Goomba Color and the first game if you want to.
Make sure the game's size are correct and that they contain a "real" Nintendo header,
some unlicensed games seem to use their own headers.
Also make sure your flashing software allocates 64kByte/512kbit SRAM for Goomba Color.

Note: If you use a crappy flash cartridge which does not let you use 64K size saves,
then use goomba_save32.gba instead of goomba.gba.


Controls
-=-=-=-=

Menu navigation:  Press L+R to open the menu, A to choose, B (or L+R again)
to cancel.

Speed modes:  L+START switches between throttled/unthrottled/slomo mode.

Quick load:  R+START loads the last savestate of the current rom.

Quick save:  R+SELECT saves to the last savestate of the current rom (or makes
a new one if none exist).

Sleep:  START+SELECT wakes up from sleep mode (activated from menu or 5/10/30
minutes of inactivity)


Other Stuff
-=-=-=-=-=-=-

Gameboy SRAM: Goomba Color automaticly takes care of games which use 8kByte SRAM.
  Games which use 32kByte SRAM must be saved by returning to the menu with L+R.

Link transfer:  Sends Goomba Color to another GBA.  The other GBA must be in
  multiboot receive mode (no cartridge inserted, powered on and waiting with
  the "GAME BOY" logo displayed).  Only one game can be sent at a time, and
  only if it's small enough to send (128kB or less). A game can only
  be sent to 1 (one) Gameboy at a time, disconnect all other gameboys during
  transfer.
Use an original Nintendo cable!
Multi player link play: NOT DONE YET.

Go Multiboot: Allows you to play without a cartridge!  For small games only,
  128k or less.  This feature makes "Link transfer" kinda useless.
  Note: You can't eject a cartridge from a Gamecube Game Boy Player while it is running.

Double Speed:  Controls whether the emulated GBC runs in double speed mode or not.
There are two modes for this option:
    Full   - Emulates the GBC at full double speed.  This can be twice as slow as
             emulating it at normal speed.
             This is the default mode.
    Timers - Only the GBC's internal clock runs at double speed, the processor
             stays at single speed.  Games may run faster at this setting.
             This setting may cause some games to crash.

Pogoshell Plugin: If you wish to use Goomba Color with Pogoshell
  just rename goomba.gba to goomba.mb, put it in the plugins directory,
  then edit pogoshell's configuration file.

GameBoy Player:
  To be able to check for the GameBoy Player one must display the
  GameBoy Player logo, the easiest way to get it is by downloading it from my
  homepage. Otherwise you can rip it from any other game that displays it
  (SMA4 & Pokemon Pinball). This is a must if you want rumble to work.


ROM program
-=-=-=-=-=-
Goomba Color now runs from ROM, and the standard "goomba.gba" file can no longer be booted
over a multiboot cable.  If you want to boot Goomba Color over a multiboot cable, or otherwise
want to run the emulator in multiboot mode, and you do not have a flash cartridge, you can
use "goomba_mb.gba", which is the mutiboot version of the program.
Note that "goomba.gba" also contains a complete copy of "goomba_mb.gba" embedded inside
to allow the "Go Multiboot" and "Link Transfer" features to work.
(that's also why the emulator is two times bigger than previous versions)


More Information
-=-=-=-=-=-=-=-=-

For more information, go to the Pocketheaven.com message boards
http://www.pocketheaven.com/boards/viewforum.php?f=29

! Thank you:
-=-=-=-=-=-=-
Red Mage - page hosting, testing
newbie and the nation of Japan - Goomba Front, testing
MarkUK - testing
Markus Oberhumer - LZO compression library
Jeff Frohwein - MBV2
Neal Tew - For PocketNES
Forgotten - For VisualBoy(Advance)
Chishm - For the cool FAT driver


-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Fredrik Olsson
flubba@passagen.se
http://hem.passagen.se/flubba/gba.html
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Dan Weiss
danweiss@gmail.com
http://www.dwedit.org/

Goomba Color (Alpha 6)  02-17-2006
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
By Dwedit (Dan Weiss)
Based on Goomba 2.30 by Flubba

It's a Game Boy Color emulator for the Game Boy Advance. 
- Why? Because the GB Micro and DS can't play GBC games!


Alpha Version
-=-=-=-=-=-=-
This is an alpha version of Goomba Color, based on Goomba 2.30.

Stay tuned for updates that are coming soon!  If you downloaded this version
after March 17, 2006, go get a new version!
http://www.pocketheaven.com/boards/viewforum.php?f=29

Known Issues:
	Savestates are broken, therefore DISABLED in this version.
	Frames draw graphics from the future, sometimes looking glitchy
	Some games do not properly show graphics
	Timing may be off
	No mid-frame palette changing, so programs that use the so-called
	  "hi-color" mode won't work.
	  Millionaire also looks incorrect.

Todo:
	Fix Savestates
	Write VRAM and Tilemap at end of frame instead of during frame
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

Gameboy SRAM: Goomba Color automaticly takes care of games which use 8kByte SRAM,
  games which use 32kByte SRAM must be saved by returning to the menu with L+R.

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
There are three modes for this option:
    None   - No double speed
    Timers - Only the GBC's internal clock runs at double speed, the processor
             stays at single speed, use this for games which play the music at
             half speed when double speed mode is turned off.
             This is the default mode.
    Full   - Emulates the GBC at full double speed.  This is twice as slow as
             emulating it at normal speed.  Some games need it.

Pogoshell Plugin: If you wish to use Goomba Color with Pogoshell
  just rename goomba.gba to goomba.mb, put it in the plugins directory,
  then edit pogoshell's configuration file.

GameBoy Player:
  To be able to check for the GameBoy Player one must display the
  GameBoy Player logo, the easiest way to get it is by downloading it from my
  homepage. Otherwise you can rip it from any other game that displays it
  (SMA4 & Pokemon Pinball). This is a must if you want rumble to work.


For more information, go to the Pocketheaven.com message boards - A real site
for Goomba Color will come later.
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
http://dwedit.home.comcast.net/

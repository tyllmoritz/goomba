Goomba v2.39
-=-=-=-=-=-=-

It's a Gameboy emulator for the GameBoy Advance. 
- Why? The GBA allready plays gameboy games.
- Well, I don't really have a good excuse, see it as a programming experiment.

It's not a Gameboy Color emulator.
- Why? I want to play my Zolda Orifice DX!
- Well, go buy the game, or even better learn ARM assembler and fix it. =)

Getting Started
-=-=-=-=-=-=-=-

Before you can use Goomba, you need to add some GB roms to the emulator.
You can do this with various tools (Goomba Front etc.).
Or you can do it manual by using a "DOS" shell:
copy /b goomba.gba+game1.gb+game2.gb goombamenu.gba
you can also insert a splashscreen between goomba and the first game if you want to.
Make sure the game's size are correct and that they contain a "real" Nintendo header,
some unlicensed games seem to use their own headers.
Also make sure your flashing software allocates 64kByte/512kbit SRAM for Goomba.

Controls
-=-=-=-=

Menu navigation:  Press L+R to open the menu, A to choose, B (or L+R again)
to cancel.

Speed modes:  L+START switches between throttled/unthrottled/slomo mode.

Quick load:  R+START loads the last savestate of the current rom.

Quick save:  R+SELECT saves to the last savestate of the current rom (or makes
a new one if none exist).

Quick pallete Change: L+LEFT moves left in the palette list
                      L+RIGHT moves right in the palette list

Quick border Change: L+UP moves up in the border list
                     L+DOWN moves down in the border list

Sleep:  START+SELECT wakes up from sleep mode (activated from menu or 5/10/30
minutes of inactivity)

Precompiled, For Your Convenience
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

The following collection of pre-compiled versions of goomba.gba.  That is, they
have already appended a collection of either palettes or borders so you don't
have to go through the effort:

goomba_raw.gba                 : Contains the minimal palettes and borders
goomba_with_some_borders.gba   : Contains the old Goomba built-in palettes,
                                 Super Gameboy Palettes, Gameboy Color Palettes,
                                 the DGBMax Preset Palettes, and a few borders
goomba_with_most_borders.gba   : Contains all of goomba_with_some_borders.gba
                                 along with all Super Gameboy's built-in borders
                                 both cropped and resized to fit the GBA screen
goomba_with_marc_borders_and_palettes.gba : Contains all the palettes (but not the
                                            borders) from above along with a few
                                            more as well as a collection of cropped
                                            Super Gameboy game borders
goomba_with_all_borders_and_palettes.gba : Everything above, borders and palettes
                                           alike; there are some duplicates where
                                           Marc's palettes and borders overlap the
                                           other borders and palettes

Appendable Palette
-=-=-=-=-=-=-=-=-=-

Create a text file containing four lines.  Each lines should contain 12 comma
seperated values.  Each group of three values, left to right, represents an
RGB value.  Lines top to bottom are for the background, window, object 1, and
object 2.  Semicolons are for comments and blank lines are allowed.  Use
txt2pal.py to convert a text file into a palette file.  Palette titles and
palette filenames are derived from the text file's name.  Displayed titles
will be only 20 characters long, so name your text file accordingly.  One can
add one or more palettes to goomba.gba as follows:

copy /b goomba.gba+new_palette.pal goomba_new.gba

Custom Palette
-=-=-=-=-=-=-=-

Copying [from the current palette, only if the current palette isn't the
custom palette,] to or modifying an element of the custom palette will store
it to your flashcard's SRAM (if you're using one).  Clearing the custom
palette will blank the palette and remove the game's custom palette from the
flashcard's SRAM (if you're using a flash card and if the game actually has
a custom palette saved).  Each palette entry is in #RRGGBB form, just like in
html.  Editing occurs on each color channel separately (ie, RR, GG, and BB).

Quasi-GBC Preset Palette
-=-=-=-=-=-=-=-=-=-=-=-=-

The GBC BIOS includes a simple checksum plus lookup routine to construct a
palette from a palette dictionary for a select number of Nintendo games.
However, the actually algorithm at least hypothetically could apply to any
game although with obviously unpredictable results (as it would be just a
coincidence that a non-Nintendo game would match).  Since I didn't see a
reason to limit the routine to just Nintendo games, the result generates
only quasi-GBC preset palettes.  For Nintendo games, the results should be
accurate; for non-Nintendo games, it's more of a crap shoot.

DGBMax Palettes
-=-=-=-=-=-=-=-=-

DGBMax was a program for flashing the Doctor GB flash cart with a game.  It
also included the feature of adding color palettes to game (presumably the
flash cart's boot program acted like a GBC and DGBMax inserted the palettes
into the flash cart's boot program based on the game, not unlike my fork of
gbc2gba.gb does although my fork uses a small preset bunch of palettes).  In
any case, the result is a relatively large database of game-specific palettes
in a dgbmax.ini file.  Now, Goomba Paletted supports these palettes as well
if dgbmax.bin is appended.  More importantly, you can create your own dgbmax.bin
by altering dgbmax.ini or creating a new similarly formatted file.   An important
note:  only the last dgbmax.bin appended will work.  The rest end up being
pointless filler.  To append, do as follows:

copy /b goomba.gba+dgbmax.bin goomba_new.gba

Custom Borders
-=-=-=-=-=-=-=-

Use append in the Append folder to convert one or more 240x160 15-color images
into a custom border collection.  Append one or more of these custom border
collections onto goomba.gba to use.  If using goomba.gba as a plugin with
Pogoshell, you can also prepend a custom border collection to a ROM.

ex. append
copy /b goomba.gba+new_border.bin goomba_new.gba

ex. prepend
copy /b new_border.bin+game.gb game_new.gb

Note: Do not try to use ROMs prepended with a custom border in a compilation. It
probably won't work.


Multiboot Pogoshell Plugin Note
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
If you are using goomba.gba as a multiboot plugin under Pogoshell, you only have
about 48K of total space for your appended palettes, dgbmax palettes, and custom
borders.  This is because multiboot mode copies the palettes and borders to RAM.
To work around this limitation, you can either prepend palettes and borders to
each ROM file or you can use goomba.gba as a non-multiboot plugin.

Other Stuff
-=-=-=-=-=-=-

Gameboy SRAM: Goomba automaticly takes care of games which use 8kByte SRAM,
  games which use 32kByte SRAM (most of the Pokemon games) must be saved
  by using savestates though.
Link transfer:  Sends Goomba to another GBA.  The other GBA must be in
  multiboot receive mode (no cartridge inserted, powered on and waiting with
  the "GAME BOY" logo displayed).  Only one game can be sent at a time, and
  only if it's small enough to send (128kB or less). A game can only
  be sent to 1 (one) Gameboy at a time, disconnect all other gameboys during
  transfer.

Use an original Nintendo cable!

Multi player link play: NOT DONE YET.

PoGoomba: If you wish to use Goomba with Pogoshell
  just rename goomba.gba to gb.bin and put it in the plugins directory.

GameBoy Player:
  To be able to check for the GameBoy Player one must display the
  GameBoy Player logo, the easiest way to get it is by downloading it from my
  homepage. Otherwise you can rip it from any other game that displays it
  (SMA4 & Pokemon Pinball). This is a must if you want rumble to work.

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Big thanks to www.XGFlash2.com for support, go there for all your GBA/SP flash card needs.
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

For more information, go to Goomba - The Official Site at
http://goomba.bornonapirateship.com/
or my own
http://hem.passagen.se/flubba/gba.html

! Thank you:
-=-=-=-=-=-=-
Red Mage - page hosting, testing
newbie and the nation of Japan - Goomba Front, testing
MarkUK - testing
Markus Oberhumer - LZO compression library
Jeff Frohwein - MBV2
Neal Tew - For PocketNES
Forgotten - For VisualBoy(Advance)

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Fredrik Olsson
flubba@passagen.se
http://hem.passagen.se/flubba/gba.html

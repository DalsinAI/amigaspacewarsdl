Spacewar for GFOS
=================

A port of Spacewar 0.3 by Sijmen Mulder (spacewar-sdl), the two-player
duel in space, from https://sourceforge.net/projects/spacewar-sdl/ (GPL 2
or later), for GFOS: AmigaOS 3.2 with GFOpenUp, on a 68040 or 68060 with
an FPU, on GFOpenUp's SDL 2 through sdl12-compat.

Two ships, one keyboard: shoot the other ship five times and it blows
up; three wins take the game.

Status: built in the os32-gcc16-open6 stove; played in the AmiCradle lab
(t3-blues-20261104): both ships fly and fire, a screenshot, Esc quits.


What you need
-------------

- GFOS: AmigaOS 3.2 with GFOpenUp 0.8.26 or later, which installs
  LIBS:GFOpenGPU/SDL2.module.
- A 68040 or 68060 with an FPU (not an LC040 or EC040), an RTG screen
  with room for an 800 x 600 window (or the AmiCradle lab), and about
  6 MB of free memory.


How to play
-----------

Install it one of three ways:

- GFOpenUp: `GFOpenUpTool INSTALL Parts/Spacewar` puts it in
  SYS:Games/Spacewar.
- Run Install-Spacewar from the archive (it offers Work:Games).
- Or copy the Spacewar drawer where you want it.

Then double-click Spacewar. The keys are in the drawer's Controls file:
blue fires with Return, since an Amiga keyboard has no Right Ctrl.


Building
--------

    sh package/build-amiga.sh        (STOVE=/path/to/os32-gcc16-open6)

or, in Cradle, stove_build with the os32-gcc16-open6 stove and target
package. It fetches Spacewar 0.3 as the tarball package/spacewar.lock
names, checks its sha256 sum, applies amiga/patches, builds with
amiga/Makefile.amigaos and packs Spacewar-VERSION-68040.lha and the
GFOpenUp part Parts/Spacewar. Upstream is not kept in this repository.

Host test: `sh tests/host/test_patch.sh` fetches and checks upstream,
applies the patch and preprocesses the game for AmigaOS and Linux: the
Amiga build opens an 800 x 600 window in the Workbench's depth, blue
fires with Return, the game moves to its drawer first and util.cpp uses
the standard <iostream>; the Linux build keeps upstream's full screen and
Right Ctrl.


What was changed
----------------

- amiga/patches/0001-amigaos.patch: a window on the Workbench instead of
  a 16-bit full screen (gfx_sdl.cpp); blue fires with Return (input.cpp);
  amiga_setup() first (main.cpp); <iostream> instead of the pre-standard
  <iostream.h> (util.cpp), which no current C++ compiler has.
- amiga/amiga_start.c: 128 KB stack, $VER, the game moves to its own
  drawer (PROGDIR:) so images/ is found from any Shell, and back at exit.
- amiga/gfx_nogl.cpp: upstream's OpenGL drawing is two empty functions
  behind <GL/gl.h>; these are the same two without it.

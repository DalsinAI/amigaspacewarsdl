// Spacewar's OpenGL drawing (upstream's src/gfx_opengl.cpp) was never
// written: two empty functions behind <GL/gl.h>. The Amiga build has no
// OpenGL headers to give it, so these are the same two empty functions
// without them; the game only ever draws through SDL.
// Copyright (c) 2026 AmiCradle Team. GPL 2 or later, like Spacewar.
#include "gfx.h"

void GFX::openglInit()
{
}

void GFX::openglDrawFrame( Player &red, Player &blue, Textbar &textbar, bool printscreen )
{
    (void)red; (void)blue; (void)textbar; (void)printscreen;
}

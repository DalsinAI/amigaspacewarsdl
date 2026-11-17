/* The Amiga port's start: the stack, the version string, and the drawer
 * the game reads its images/ from.
 * Copyright (c) 2026 AmiCradle Team. GPL 2 or later, like Spacewar. */
#include <stdlib.h>
#include <exec/types.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include "amiga_start.h"

/* A Shell gives 4 KB of stack; SDL wants more. libnix's startup sets this
 * much up. */
unsigned long __stack = 128 * 1024;
static const char version[] __attribute__((used)) =
    "$VER: Spacewar 0.3 (16.11.2026)";

static BPTR old_dir;
static int dir_changed;

static void amiga_restore_dir(void)
{
    if (dir_changed)
    {
        BPTR mine = CurrentDir(old_dir);
        UnLock(mine);
        dir_changed = 0;
    }
}

/* Upstream reads images/... from the current directory, and a screenshot
 * (P) is written there. A Workbench start is already in the drawer; a
 * Shell start may be anywhere, so the game moves to its own drawer
 * (PROGDIR:) and back at exit. */
void amiga_setup(void)
{
    BPTR prog = GetProgramDir();
    if (prog)
    {
        BPTR dup = DupLock(prog);
        if (dup)
        {
            old_dir = CurrentDir(dup);
            dir_changed = 1;
            atexit(amiga_restore_dir);
        }
    }
}

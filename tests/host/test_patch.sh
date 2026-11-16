#!/bin/sh
# Applies amiga/patches to upstream Spacewar 0.3 (fetched and checked as
# package/spacewar.lock says, or SW=/an/unpacked/tree) and preprocesses
# the patched files for AmigaOS and for Linux against a stub SDL.h: the
# Amiga build opens an 800 x 600 window in the Workbench's depth, blue
# fires with Return, main moves to the drawer first; the Linux build keeps
# upstream's 16-bit full screen and Right Ctrl. Both use <iostream>.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/../.." && pwd)
. "$ROOT/package/spacewar.lock"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
if [ -z "${SW:-}" ]; then
    curl -fsSL -o "$T/sw.tbz" "$SPACEWAR_URL"
    echo "$SPACEWAR_SHA256  $T/sw.tbz" | sha256sum -c - >/dev/null
    tar -xjf "$T/sw.tbz" -C "$T"
else
    cp -r "$SW" "$T/spacewar-0.3"
fi
SW="$T/spacewar-0.3"
for p in "$ROOT"/amiga/patches/*.patch; do (cd "$SW" && patch -p1 -s < "$p"); done
for os in amiga linux; do
    D=; [ $os = amiga ] && D=-D__amigaos__
    for f in gfx_sdl input main; do
        ${CXX:-c++} -E -P $D -I"$HERE/stub" -I"$ROOT/amiga" -I"$SW/src" "$SW/src/$f.cpp" > "$T/$os-$f.i"
    done
done
fails=0
check() { if eval "$2"; then echo "pass $1"; else echo "FAIL $1"; fails=$((fails+1)); fi; }
check "Amiga: 800 x 600 window in the Workbench's depth" 'grep -q "SDL_SetVideoMode( 800, 600, 0, SDL_SWSURFACE )" "$T/amiga-gfx_sdl.i" && ! grep -q "SDL_FULLSCREEN" "$T/amiga-gfx_sdl.i"'
check "Amiga: blue fires with Return" 'grep -q "case SDLK_RETURN:" "$T/amiga-input.i" && ! grep -q "SDLK_RCTRL" "$T/amiga-input.i"'
check "Amiga: amiga_setup before SDL_Init" 'awk "/amiga_setup\(\)/{s=NR} /SDL_Init\(/{if(!i)i=NR} END{exit !(s&&i&&s<i)}" "$T/amiga-main.i"'
check "Linux: upstream's full screen" 'grep -q "SDL_SetVideoMode( 800, 600, 16, SDL_FULLSCREEN" "$T/linux-gfx_sdl.i"'
check "Linux: blue fires with Right Ctrl" 'grep -q "case SDLK_RCTRL:" "$T/linux-input.i"'
check "Linux: no amiga_setup" '! grep -q amiga_setup "$T/linux-main.i"'
check "util.cpp: standard <iostream>" '! grep -q "iostream.h" "$SW/src/util.cpp" && grep -q "using namespace std;" "$SW/src/util.cpp"'
check "util.cpp compiles on the host's C++" '${CXX:-c++} -fsyntax-only -Wno-write-strings -I"$HERE/stub" -I"$SW/src" "$SW/src/util.cpp"'
echo "$( [ $fails = 0 ] && echo PASS || echo FAIL ): $fails failed"
[ $fails = 0 ]

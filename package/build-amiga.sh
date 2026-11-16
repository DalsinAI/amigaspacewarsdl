#!/bin/sh
# The release archive and the GFOpenUp part, for Cradle's stove_build
# (target package):
#  1. upstream Spacewar 0.3 (spacewar-sdl), fetched as the tarball
#     package/spacewar.lock names and checked against its sha256 sum (it is
#     never kept in this repository), with amiga/patches applied;
#  2. the game built by amiga/Makefile.amigaos;
#  3. the drawer, its icon and the Installer script beside it packed as
#     NAME-VERSION-68040.lha (tools/pack_dist.py), with its .sha256 and a
#     short .readme;
#  4. OUT/Parts/Spacewar, a GFOpenUp part: its Part file and the drawer's
#     files for SYS:Games/Spacewar, installed with
#       GFOpenUpTool INSTALL Parts/Spacewar
#     It needs the GFOpenGPU part, whose SDL2.module draws the game (through
#     sdl12-compat, linked in).
# Nothing is published from here.
# Copyright (c) 2026 AmiCradle Team. GPL 2 or later, like Spacewar.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
. "$HERE/package.env"
. "$HERE/spacewar.lock"
OUT=${OUT:-"$ROOT/build-amiga-package"}
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
STOVE=${STOVE:-"$HOME/AmiCradle/stoves/os32-gcc16-open6"}
# outside the checkout: Cradle cleans it (git clean -ffdx) before every job
WORK=${WORK:-"$HOME/.cache/amigaspacewarsdl"}
mkdir -p "$WORK"
cd "$ROOT"

# 1. upstream, downloaded once, its sum always checked, unpacked and patched afresh
T="$WORK/spacewar-0.3.tar.bz2"
if [ ! -f "$T" ] || ! echo "$SPACEWAR_SHA256  $T" | sha256sum -c - >/dev/null 2>&1; then
    curl -fsSL -o "$T.part" "$SPACEWAR_URL"
    mv "$T.part" "$T"
fi
echo "$SPACEWAR_SHA256  $T" | sha256sum -c - >/dev/null || { echo "sha256 of $T is wrong" >&2; exit 1; }
SW="$WORK/spacewar-0.3"
rm -rf "$SW"
tar -xjf "$T" -C "$WORK"
for p in "$ROOT"/amiga/patches/*.patch; do
    (cd "$SW" && patch -p1 -s < "$p")
done

# 2. the game (a stove's compiler is in its prefix/, or STOVE is the prefix)
if [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then PREFIX="$STOVE/prefix"; else PREFIX="$STOVE"; fi
make -f amiga/Makefile.amigaos SW="$SW" STOVE="$STOVE" PREFIX="$PREFIX" -j4 $TARGET > "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }

# 3. the archive
python3 "$ROOT/tools/pack_dist.py" --dist "$DIST" --name "$NAME" --out "$OUT"

# 4. the GFOpenUp part
sh "$ROOT/package/write-part.sh" "$DIST/$NAME" "$OUT/Parts/$NAME" "$NAME" "$PORT_VERSION" \
    "Spacewar: two ships, one keyboard, shoot the other one three times"
echo "part: $(grep -c '^copy' "$OUT/Parts/$NAME/Part") files, $(du -sk "$OUT/Parts/$NAME" | cut -f1) KB"
ls -l "$DIST/$NAME/$NAME"

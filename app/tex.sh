#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2020 by David Rabkin

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
[ "$#" -eq 1 ] || die "Usage: $BASE_IAM FILENAME.tex"
[ -r "$1" ] || die "Unable to read from source $1."
validate 'tex'
validate 'dvipdfm'
NME=$(basename -- "$1")

# Makes sure that source filename has tex extention.
[ 'tex' = "${NME##*.}" ] || die "Source file $1 should have .tex extention."

# Extracts file name only.
NME="${NME%.*}"
TEX="$NME.tex"
DVI="$NME.dvi"
PDF="$NME.pdf"
LOG="$NME.log"

# Do not worry about file cleaning on exit. Garbage collector will remove the
# temporarily directory.
cp "$1" "$BASE_LCK"
cd "$BASE_LCK"
if ! tex --interaction=batchmode "./$TEX" >/dev/null 2>&1; then
  cp "./$LOG" "$OLDPWD"
  die "See $LOG for errors."
fi
dvipdfm "./$DVI" >/dev/null 2>&1
cp "./$PDF" "$OLDPWD"
open "$OLDPWD/$PDF"
exit 0

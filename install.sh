#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2022 David Rabkin
ROOT="$(pwd)"
REPO="$ROOT"/shellbase
if [ ! -r "$REPO" ]; then
	[ -w "$ROOT" ] || \
		{ printf '%s is not writable.\n' "$ROOT" >&2; exit 11; }
	mkdir "$REPO" || \
		{ printf 'Unable to create %s.\n' "$REPO" >&2; exit 12; }
	command -v git >/dev/null 2>&1 || \
		{ printf 'Install git.\n' >&2; exit 13; }
	URL=https://github.com/rdavid/shellbase.git
	git clone $URL "$REPO" || \
		{ printf 'Unable to clone %s to %s.\n' $URL "$REPO" >&2; exit 14; }
fi
BASE="$REPO"/inc/base
[ -r "$BASE" ] || \
	{ printf 'Unable to read %s.\n' "$BASE" >&2; exit 15; }
printf 'shellbase is installed.\n'
exit 0

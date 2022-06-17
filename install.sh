#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2022 David Rabkin
set -- --quiet "$@"
TAG=v0.9.20220613
URL=https://github.com/rdavid/shellbase/releases/download/$TAG/base
command -v wget >/dev/null 2>&1 || \
	{ printf 'Install wget.\n' >&2; exit 12; }

# wget downloads shellbase content to stdout, eval sources it to the script
# running environment.
eval "$( \
	wget $URL \
		--output-document - \
		--quiet \
	)"
DST=/usr/local/bin
TGT=$DST/shellbase
if file_exists $TGT; then
	yes_to_continue \
		"$(sh $TGT --quiet --version)" \
		is already installed. Install \
		"$BASE_VERSION"?
fi
is_writable $DST || \
	die $DST is not writable.
wget $URL \
	--output-document $TGT \
	--quiet \
	|| die "Unable to install $URL to $DST."
printf \
	'%s is installed to %s.\n' \
	"$(sh $TGT --quiet --version)" \
	$DST
exit 0

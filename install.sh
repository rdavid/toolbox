#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2022 David Rabkin
VERS=v0.9.20220516
URL=https://github.com/rdavid/shellbase/releases/download/$VERS/base
command -v wget >/dev/null 2>&1 || \
	{ printf 'Install wget.\n' >&2; exit 12; }

# wget downloads shellbase content to stdout, eval sources it to the script
# running environment.
eval "$( \
	wget $URL \
		--output-document - \
		--quiet \
	)"
DEST=/usr/local/bin
TRGT=$DEST/shellbase
if file_exists $TRGT; then
	printf \
		'%s is already installed. Install %s?\n' \
		"$(sh $TRGT --version)" \
		"$BASE_VERSION"
	yes_to_continue
fi
is_writable $DEST || \
	die $DEST is not writable.
wget $URL \
	--output-document $TRGT \
	--quiet || \
	die "Unable to install $URL to $DEST."
printf \
	'%s is installed to %s.\n' \
	"$(sh $TRGT --version)" \
	$DEST
exit 0

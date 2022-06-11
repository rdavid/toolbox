#!/bin/sh -eu
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# Copyright 2019-2022 David Rabkin
# Sets owner to a user from the first argument, set right permitions for files
# and directories started from the seconds argument.
BASE_APP_VERSION=0.9.20220611

# shellcheck source=/usr/local/bin/shellbase
. shellbase
be_root
[ "$#" -eq 2 ] || die Usage: chown.sh user directory.
USR="$1"
DIR="$2"
user_exists "$USR" || die "$USR": No such user.
file_exists "$DIR" || die "$DIR": No such file or directory.
is_writable "$DIR" || die "$DIR" is not writable.
chown -R "$USR" "$DIR"
find "$DIR" -type d -exec chmod 755 {} \;
find "$DIR" -type f -exec chmod 644 {} \;
log "Owner of $DIR is changed to $USR."
exit 0

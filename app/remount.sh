#!/bin/sh -eu
# vi:ts=2 sw=2 tw=79 et lbr wrap
# Copyright 2016 by David Rabkin

# shellcheck source=../../shellbase/inc/base
. "$(dirname "$(realpath "$0")")/../shellbase/inc/base"
TMP='/etc/fstab-tmp'
PRM='/etc/fstab-prm'
be_root
[ -f $TMP ] || bye "$TMP not found."
[ -f $PRM ] || bye "$PRM not found."
cp $TMP /etc/fstab && mount -a
cp $PRM /etc/fstab
exit 0

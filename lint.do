# shellcheck shell=sh
# vi:et lbr noet sw=2 ts=2 tw=79 wrap
# SPDX-FileCopyrightText: 2024-2025 David Rabkin
# SPDX-License-Identifier: 0BSD
redo-ifchange \
	./*.do \
	.github/*.yml \
	.github/workflows/*.yml \
	app/* \
	README.adoc

# shellcheck disable=SC2034 # Variable appears unused.
readonly \
	BASE_APP_VERSION=0.9.20250609 \
	BASE_MIN_VERSION=0.9.20231212 \
	BSH=/usr/local/bin/base.sh
[ -r "$BSH" ] || {
	printf >&2 Install\ Shellbase.\\n
	exit 1
}
set -- "$@" --quiet

# shellcheck disable=SC1090 # File not following.
. "$BSH"
find . \
	-name '*.do' \
	-or \
	-name '*' -not -name pass -path '*/app/*' |
	while read -r f; do
		cmd_exists shellcheck && shellcheck "$f"
		cmd_exists shfmt && shfmt -d "$f"
	done
cmd_exists reuse && reuse lint
cmd_exists typos && typos
cmd_exists vale && {
	vale sync
	vale README.adoc
}
cmd_exists yamllint && yamllint .github/*.yml .github/workflows/*.yml

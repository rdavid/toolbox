# shellcheck shell=sh
# vi: lbr noet sw=2 ts=2 tw=79 wrap
# SPDX-FileCopyrightText: 2024-2026 David Rabkin
# SPDX-License-Identifier: 0BSD
# File not following, appears unused:
#  shellcheck disable=SC1090,SC2034
redo-ifchange \
	./.github/*.yml \
	./.github/workflows/*.yml \
	./*.do \
	./app/* \
	./README.adoc
readonly \
	BASE_APP_VERSION=0.9.20260707 \
	BSH=/usr/local/bin/base.sh
[ -r "$BSH" ] || {
	printf >&2 'Install Shellbase.\n'
	exit 1
}
set -- "$@" --quiet
. "$BSH"
cmd_runif actionlint
cmd_runif zizmor \
	--no-online-audits \
	./.github/workflows
find . \
	-name '*.do' \
	-or \
	-name '*' -path '*/app/*' |
	while read -r f; do
		cmd_runif shellcheck "$f"
		cmd_runif shfmt -d "$f"
		cmd_runif dash -n "$f"
		cmd_runif mksh -n "$f"
	done
cmd_runif reuse lint
cmd_runif typos
cmd_runif vale sync
cmd_runif vale ./README.adoc
cmd_runif yamllint \
	./.github/*.yml \
	./.github/workflows/*.yml

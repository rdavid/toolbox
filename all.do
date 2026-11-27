# vi: lbr noet sw=2 ts=2 tw=79 wrap
# SPDX-FileCopyrightText: 2024-2026 David Rabkin
# SPDX-License-Identifier: 0BSD
#
# Runs the default target, which lints the project.
#
# Shellcheck cannot infer the shell without a shebang:
#  shellcheck shell=sh
redo-ifchange ./lint

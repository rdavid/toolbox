# Toolbox

[![linters](https://github.com/rdavid/toolbox/actions/workflows/lint.yml/badge.svg)](https://github.com/rdavid/toolbox/actions/workflows/lint.yml)
[![hits of code](https://hitsofcode.com/github/rdavid/toolbox?branch=master&label=hits%20of%20code)](https://hitsofcode.com/view/github/rdavid/toolbox?branch=master)
[![release)](https://img.shields.io/github/v/release/rdavid/toolbox?color=blue&label=%20&logo=semver&logoColor=white&style=flat)](https://github.com/rdavid/toolbox/releases)
[![license](https://img.shields.io/github/license/rdavid/toolbox?color=blue&labelColor=gray&logo=freebsd&logoColor=lightgray&style=flat)](https://github.com/rdavid/toolbox/blob/master/LICENSE)

* [About](#about)
* [Install](#install)
* [License](#license)

## About

`toolbox` is a set of Unix shell utilities for everyday use. Every utility is a
POSIX-compliant and uses Unix shell framework
[`shellbase`](https://github.com/rdavid/shellbase):

* [`bak`](app/bak) is a wrapper on
[`rdiff-backup`](https://github.com/rdiff-backup/rdiff-backup) to produce, well,
backups.
* [`chowner`](app/chowner) changes an owner and sets right permissions on a
directory.
* [`copyright`](app/copyright) updates published years in copyrighed title.
* [`flactomp3`](app/flactomp3) converts audio to `mp3` with tags.
* [`myip`](app/myip) continuously prints external IP, uses `dig`.
* [`pingo`](app/pingo) adds timestamps to the ping command output.
* [`speed`](app/speed) continuously prints download and upload internet speeds,
uses [`speedtest`](https://github.com/sivel/speedtest-cli) utility.
* [`tru`](app/tru) stands for transmission remote updater. It removes a
torrent with content and than adds it again. It could be ran by `cron` to
increase a ratio.
* [`ydata`](app/ydata) is a wrapper on
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp): downloads, converts, renames and
keeps safe. It could be ran by `cron`.

## Install

Make sure `/usr/local/bin` is in your `PATH`.

```sh
git clone git@github.com:rdavid/toolbox.git &&
  ./toolbox/app/install
```

## License

`toolbox` is copyright [David Rabkin](http://cv.rabkin.co.il) and available
under a
[Zero-Clause BSD license](https://github.com/rdavid/toolbox/blob/master/LICENSE).

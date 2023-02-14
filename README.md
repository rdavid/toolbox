# Toolbox [![Linters](https://github.com/rdavid/toolbox/actions/workflows/lint.yml/badge.svg)](https://github.com/rdavid/toolbox/actions/workflows/lint.yml) [![hits of code](https://hitsofcode.com/github/rdavid/toolbox?branch=master&label=hits%20of%20code)](https://hitsofcode.com/view/github/rdavid/toolbox?branch=master) [![license](https://img.shields.io/github/license/rdavid/toolbox?color=blue&labelColor=gray&logo=freebsd&logoColor=lightgray&style=flat)](https://github.com/rdavid/toolbox/blob/master/LICENSE)
Unix shell utilities for everyday use.

* [About](#about)
* [Install](#install)
* [License](#license)

## About
Hi, I'm [David Rabkin](http://cv.rabkin.co.il).

Almost every utility uses [`shellbase`](https://github.com/rdavid/shellbase).
The utilities are mostly POSIX-compliant. There are following utilities:
- [`bak`](app/bak) is a wrapper on
[`rdiff-backup`](https://github.com/rdiff-backup/rdiff-backup) to produce, well,
backups.
- [`chowner`](app/chowner) changes an owner and sets right permissions on a
directory.
- [`copyright`](app/copyright) updates published years in copyrighed title.
- [`flactomp3`](app/flactomp3) converts audio to mp3 with tags.
- [`myip`](app/myip) continuously prints external IP, uses `dig`.
- [`pingo`](app/pingo) adds timestamps to the ping command output.
- [`speed`](app/speed) continuously prints download and upload internet speeds,
uses `speedtest` utility.
- [`tru`](app/tru) stands for transmission remote updater. It removes a
torrent with content and than adds it again. It is usefull with cron to increase
a ratio.
- [`ydata`](app/ydata) is a wrapper on
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp): downloads, converts, renames and
keeps safe. It is usefull with cron.

## Install
Make sure `/usr/local/bin` is in your `PATH`.
```sh
git clone git@github.com:rdavid/toolbox.git &&
	./toolbox/install
```
## License
`toolbox` is copyright [David Rabkin](http://cv.rabkin.co.il) and available
under a
[Zero-Clause BSD license](https://github.com/rdavid/toolbox/blob/master/LICENSE).

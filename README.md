# Toolbox
Unix shell scripts for everyday use.

[![Hits-of-Code](https://hitsofcode.com/github/rdavid/toolbox?branch=master)](https://hitsofcode.com/view/github/rdavid/toolbox?branch=master)
[![License](https://img.shields.io/badge/license-0BSD-green)](https://github.com/rdavid/toolbox/blob/master/LICENSE)

* [About](#about)
* [Install](#install)
* [License](#license)

## About
Hi, I'm [David Rabkin](http://cv.rabkin.co.il).

Almost every script uses [`shellbase`](https://github.com/rdavid/shellbase).

There are following utilities:
- [`bak`](app/bak.sh) is a wrapper on
[`rdiff-backup`](https://github.com/rdiff-backup/rdiff-backup) to produce, well,
backups.
- [`chown`](app/chown.sh) change an owner and set right permissions on a
directory.
- [`flactomp3`](app/flactomp3.sh) converts audio to mp3 with tags.
- [`tru`](app/tru.sh) stands for transmission remote updater. It removes a
torrent with content and than adds it again. It is usefull with cron to increase
a ratio.
- [`ytda`](app/ytda.sh) is a wrapper on
[`youtube-dl`](https://github.com/ytdl-org/youtube-dl): downloads, converts,
renames and keeps safe. It is usefull with cron.

## Install

    git clone --recurse-submodules https://github.com/rdavid/toolbox.git

## License
The scripts are copyright [David Rabkin](http://cv.rabkin.co.il) and available
under a
[Zero-Clause BSD license](https://github.com/rdavid/toolbox/blob/master/LICENSE)
.

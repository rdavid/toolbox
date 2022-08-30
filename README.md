# Toolbox [![Hits-of-Code](https://hitsofcode.com/github/rdavid/toolbox?branch=master)](https://hitsofcode.com/view/github/rdavid/toolbox?branch=master) [![License](https://img.shields.io/badge/license-0BSD-green)](https://github.com/rdavid/toolbox/blob/master/LICENSE)
Unix shell scripts for everyday use.

* [About](#about)
* [Install](#install)
* [License](#license)

## About
Hi, I'm [David Rabkin](http://cv.rabkin.co.il).

Almost every script uses [`shellbase`](https://github.com/rdavid/shellbase).

There are following utilities:
- [`bak`](app/bak) is a wrapper on
[`rdiff-backup`](https://github.com/rdiff-backup/rdiff-backup) to produce, well,
backups.
- [`chowner`](app/chowner) change an owner and set right permissions on a
directory.
- [`flactomp3`](app/flactomp3) converts audio to mp3 with tags.
- [`tru`](app/tru) stands for transmission remote updater. It removes a
torrent with content and than adds it again. It is usefull with cron to increase
a ratio.
- [`ydata`](app/ydata) is a wrapper on
[`yt-dlp`](https://github.com/yt-dlp/yt-dlp): downloads, converts, renames and
keeps safe. It is usefull with cron.

## Install
Make sure `/usr/local/bin/` is in your `PATH`.

    git clone https://github.com/rdavid/toolbox.git &&
    	./toolbox/install

## License
The scripts are copyright [David Rabkin](http://cv.rabkin.co.il) and available
under a
[Zero-Clause BSD license](https://github.com/rdavid/toolbox/blob/master/LICENSE).

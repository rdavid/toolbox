#!/usr/local/bin/zsh
# vim: tabstop=2 shiftwidth=2 expandtab textwidth=80 linebreak wrap

#for f in *.m4v
for f in *.mp4
#for f in *.avi
#for f in *.mkv
do
  echo $f
#  name=`echo "$f" | sed -e "s/.m4v$//g"`
  name=`echo "$f" | sed -e "s/.mp4$//g"`
#  name=`echo "$f" | sed -e "s/.avi$//g"`
#  name=`echo "$f" | sed -e "s/.mkv$//g"`
  ffmpeg -i "$f" -vn -ar 44100 -ac 2 -ab 192k -f mp3 "$name.mp3"
done

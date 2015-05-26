# MacBlackBox
Remember what you did on your Mac by creating videos of all your screen activity each day

This is a small bash script that takes a screen-shot of all your screens every ten seconds.  Every hour it combines them into an
mp4 file (two screenshots per second).  Every day it combines the hourly mp4s into a daily mp4.

You end up with an mp4 which you can watch to remember what you did each day.  This script was inspired by TimeSnapper for
Windows.

It needs ffmpeg, imagemagick and ghostscript.  I suggest you install these via http://brew.sh/
```
brew install ffmpeg
brew install imagemagick
brew install ghostscript
```

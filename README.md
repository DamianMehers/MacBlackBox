# MacBlackBox
Remember what you did on your Mac by creating videos of all your screen activity each day

[TimeSnapper for the Mac is now available](https://apps.apple.com/us/app/timesnapper/id1456327684?mt=12) - I'm personally using that now.

This is a small bash script that takes a screen-shot of all your screens every ten seconds.  Every hour it combines them into an
mp4 file (two screenshots per second).  Every day it combines the hourly mp4s into a daily mp4.

Each screenshot has the current time overlaid on it at the bottom of the screen.

You end up with an mp4 which you can watch to remember what you did each day.  This script was inspired by http://www.timesnapper.com/

It needs ffmpeg, imagemagick and ghostscript.  I suggest you install these via http://brew.sh/
```
brew install ffmpeg
brew install imagemagick
brew install ghostscript
```

Create a couple of directories like this, and put capture.sh in MacBlackBox
```
mkdir ~/MacBlackBox
mkdir ~/MacBlackBox/captures
cp ~/Downloads/capture.sh ~/MacBlackBox
~/MacBlackBox/capture.sh
```

Its been a long time since I've written bash scripts, and I've never used ffmpeg or imagemagick before, so don't hesitate to suggest changes.

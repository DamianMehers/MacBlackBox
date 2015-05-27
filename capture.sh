#!/bin/bash
# set -x #echo on

# The MIT License (MIT)

# Copyright (c) 2015 Damian Mehers (damian@mehers.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Needs ffmpeg, ghostscript, imagemagick

configuration_file=${HOME}/.MacBlackBox
if [ -f $configuration_file ]; then
	source $configuration_file
fi 

# How long to wait between screenshots
snapshot_interval_seconds=${snapshot_interval_seconds-10}

# How many snapshots per second in the hourly movies
snapshots_per_second=${snapshots_per_second-2}

# How long to keep the hourly videos, in days
keep_video_days=${keep_video_days-120}

# Location of the captures.  Captures are saved into this directory.  Hourly movies to the parent directory.
videos_location=${videos_location-~/MacBlackBox}

if [ -n "$show_config" -a "$show_config" != "0" ]; then
	echo Capturing a screenshot every $snapshot_interval_seconds seconds
	echo Creating videos with $snapshots_per_second snapshots per second 
	echo \($((snapshots_per_second*snapshot_interval_seconds)) real life seconds per video second\)
	echo Keeping videos for $keep_video_days days, in $videos_location
fi

# Change this as you wish.  Captures are saved into this directory.  Hourly movies to the parent directory.
cd ${videos_location}/captures

previous_hour=$(date +%Y%m%d%H)
previous_day=$(date +%Y%m%d)
while true
do
	sleep $snapshot_interval_seconds

	# skip capture if the screensaver is running
	ps ax|grep [S]creenSaverEngine > /dev/null
	if [ "$?" != "0" ] ; then
		# Capture up to four screens with no sound, of type jpg
		timestamp=$(date +%Y%m%d%H%M%S)
		label=$(date)
		screencapture -x -tjpg ${timestamp}_1.jpg ${timestamp}_2.jpg ${timestamp}_3.jpg ${timestamp}_4.jpg

		# Use imagemagick to overlay the current time over the images so that we see when each 
		# capture was taken since the clock is not always visible
		for i in `seq 1 4`
		do
			# If we have a capture for this screen
			if [ -f ${timestamp}_${i}.jpg ]
			then
				convert ${timestamp}_${i}.jpg -fill white  -undercolor '#00000080'  -gravity South -annotate +0+5 "${label}" ${timestamp}_${i}.jpg
			fi
		done
	fi

	# If we are on a new hour, make a movie from the previous hour's captures and delete them.
	# Two frames per second means that each second of video is twenty seconds of real life if we
	# do a screen capture every ten seconds
	current_hour=$(date +%Y%m%d%H)
	if [ "$previous_hour" != "$current_hour" ]
	then
		for i in `seq 1 4`
		do
			# Only create the movie if we have files for the last hour
			if ls ${previous_hour}*_${i}.jpg 1> /dev/null 2>&1
			then
				# Run in the background so that we can continue capturing screens.  Use 'nice' to not hit foreground apps too hard
				(nice ffmpeg -framerate $snapshots_per_second -pattern_type glob -i "${previous_hour}*_${i}.jpg" -c:v libx264 ${videos_location}/${previous_hour}_${i}.mp4 > /dev/null 2>/dev/null ; rm ${previous_hour}*_${i}.jpg) &
			fi
		done
		previous_hour=$current_hour
	fi

	# If we are on a new day, bring all the last day's movies into a single movie
	current_day=$(date +%Y%m%d)
	if [ "$previous_day" != "$current_day" ]
	then
		for i in `seq 1 4`
		do
			# Only create the movie if we have files for the last day
			if ls ${previous_day}*_${i}.jpg 1> /dev/null 2>&1
			then
				(nice ffmpeg -f concat -i <(for f in $videos_location/$previous_day*_$i.mp4; do echo "file '$f'"; done) -c copy $videos_location/${previous_day}_${i}.mp4; rm $videos_location/$previous_day??_$i.mp4) &
			fi
		done
		previous_day=$current_day
		
		# Remove older files
		find ../*.mp4 -type f -mtime +$keep_video_days -delete
	fi

done

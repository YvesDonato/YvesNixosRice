#!/bin/bash

while true; do

	player_status=$(spotifycli --status 2>/dev/null)

	if [ -z "$(spotifycli --album)" ]; then
		if [ "$player_status" = "Playing" ]; then
			echo "$(spotifycli --artist) - $(spotifycli --song)"
		elif [ "$player_status" = "Paused" ]; then
			echo " $(spotifycli --artist) - $(spotifycli --song)"
    else
			echo ""
		fi
	else
		if [ "$player_status" = "Playing" ]; then
			echo "<span color='#1db954'></span> $(spotifycli --artist) - $(spotifycli --song)"
		elif [ "$player_status" = "Paused" ]; then
			echo "<span color='#1db954'></span>  $(spotifycli --artist) - $(spotifycli --song)"
    else
			echo ""
		fi
	fi

	sleep 1

done

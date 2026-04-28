#!/usr/bin/env bash

select=$(printf "Turn Off\nReboot\nLock" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 3;}')

case $select in "Turn Off")
	poweroff
	;;
"Reboot")
	reboot
	;;
"Lock")
	hyprlock
	;;
esac

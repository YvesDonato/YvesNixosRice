#!/usr/bin/env bash
set -euo pipefail

select=$(printf "Turn Off\nReboot\nLock" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 3;}' || true)

case $select in "Turn Off")
	poweroff
	;;
"Reboot")
	reboot
	;;
"Lock")
	session-lock
	;;
esac

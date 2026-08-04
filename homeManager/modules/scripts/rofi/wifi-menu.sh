#!/usr/bin/env bash
set -euo pipefail

# || true: a missing device would otherwise kill the script via set -e.
wifi=$(rfkill | grep "phy0" | awk '{print $4}' || true)
bluetooth=$(rfkill | grep "hci0" | awk '{print $4}' || true)

if [ "$wifi" = "blocked" ]; then
	wifi="Unblock"
else
	wifi="Block"
fi

if [ "$bluetooth" = "blocked" ]; then
	bluetooth="Unblock"
else
	bluetooth="Block"
fi

select=$(printf "%s Wifi\n%s Bluetooth" "$wifi" "$bluetooth" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 2;}' -p "Wifi Options:" || true)

case $select in "${wifi} Wifi")
	rfkill toggle wlan
	;;
"${bluetooth} Bluetooth")
	rfkill toggle bluetooth
	;;
esac

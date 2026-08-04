#!/usr/bin/env bash
set -euo pipefail

# hyprctl is absent under Mango; treat that the same as "no headless monitor".
if hyprctl monitors 2>/dev/null | grep -q "streaming_monitor"; then
	headless="Disable Headless"
else
	headless="Enable Headless"
fi

select=$(printf "Search\nPower\nWifi\nApp\nCodebox\n%s" "$headless" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 6;}' -p " " || true)

case $select in "Power")
	power-menu
	;;
"Wifi")
	wifi-menu
	;;
"Search")
	uni-search
	;;
"Codebox")
	codebox
	;;
"App")
	rofi -show drun
	;;
"Enable Headless")
	toggle-headless
	;;
"Disable Headless")
	toggle-headless
	;;
esac

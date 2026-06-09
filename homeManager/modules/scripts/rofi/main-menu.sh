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
	bash /home/yvesd/nixos/homeManager/modules/scripts/rofi/power-menu.sh
	;;
"Wifi")
	bash /home/yvesd/nixos/homeManager/modules/scripts/rofi/wifi-menu.sh
	;;
"Search")
	bash /home/yvesd/nixos/homeManager/modules/scripts/rofi/uni-search.sh
	;;
"Codebox")
	bash /home/yvesd/nixos/homeManager/modules/scripts/rofi/codebox.sh
	;;
"App")
	rofi -show drun
	;;
"Enable Headless")
	/home/yvesd/nixos/homeManager/modules/scripts/rofi/toggle-headless.sh
	;;
"Disable Headless")
	/home/yvesd/nixos/homeManager/modules/scripts/rofi/toggle-headless.sh
	;;
esac

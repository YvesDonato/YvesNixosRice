#!/usr/bin/env bash

select=$(printf "Search\nPower\nWifi\nApp" |rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 4;}' -p " ")

case $select in "Power")
bash /home/yvesd/Nixos/homeManager/modules/scripts/rofi/power-menu.sh
;;
"Wifi")
bash /home/yvesd/Nixos/homeManager/modules/scripts/rofi/wifi-menu.sh
;;
"Search")
bash /home/yvesd/Nixos/homeManager/modules/scripts/rofi/search.sh
;;
"App")
rofi -show drun
esac

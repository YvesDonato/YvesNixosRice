#!/usr/bin/env bash

select=$(printf "Search\nPower\nWifi\nApp" |rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; } listview {lines: 4;}' -p " ")

case $select in "Power")
bash /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/power-menu.sh
;;
"Wifi")
bash /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/wifi-menu.sh
;;
"Search")
bash /home/yvesd/Nixos/Configuration/Configs/rofi/scripts/search.sh
;;
"App")
rofi -show drun
esac

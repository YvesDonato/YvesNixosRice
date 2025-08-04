#!/usr/bin/env bash

user_input=$(echo "" | rofi -dmenu -p " " -theme-str 'listview { enabled: false; }')

if [[ -n "$user_input" ]]; then
  
  zen --new-tab "https://www.google.com/search?q=${user_input}"   

fi

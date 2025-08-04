#!/usr/bin/env bash

user_input=$(echo "" | rofi -dmenu -p " " -theme-str 'listview { enabled: false; }')

if [ -n "$user_input" ]; then
  zen --new-tab "https://chat.openai.com/?q=${user_input}"
fi


#!/usr/bin/env bash

session=$(zellij ls -n | awk '{print $1}')
if [[ -n $session ]]; then
    session="\n${session}"
fi
extra="New"
append="Clear"
select=$(echo -e "$extra$session\n$append" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; }')

if [[ -n "$select" ]]; then
    
    case $select in "Clear")
        zellij delete-all-sessions --yes
    ;;
    "New")
        ghostty -e zellij
    ;;
    *)
        ghostty -e zellij a "$select"
    esac

fi 

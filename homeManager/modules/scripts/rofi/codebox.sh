#!/usr/bin/env bash
set -euo pipefail

# zellij ls fails when no server is running; treat that as "no sessions".
session=$(zellij ls -n 2>/dev/null | awk '{print $1}' || true)
if [[ -n $session ]]; then
	session="\n${session}"
fi
extra="New"
append="Clear"
select=$(echo -e "$extra$session\n$append" | rofi -dmenu -no-show-icons -theme-str 'inputbar { enabled: false; }' || true)

if [[ -n "$select" ]]; then

	case $select in "Clear")
		zellij delete-all-sessions --yes
		;;
	"New")
		ghostty -e zellij
		;;
	*)
		ghostty -e zellij a "$select"
		;;
	esac

fi

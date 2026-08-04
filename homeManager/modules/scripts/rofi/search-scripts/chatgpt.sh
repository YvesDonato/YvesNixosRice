#!/usr/bin/env bash
set -euo pipefail

# Percent-encode byte-wise so query text can't break the URL.
urlencode() {
	local LC_ALL=C
	local s="$1" out="" c i
	for ((i = 0; i < ${#s}; i++)); do
		c="${s:i:1}"
		case "$c" in
		[a-zA-Z0-9.~_-]) out+="$c" ;;
		*) printf -v c '%%%02X' "'$c" && out+="$c" ;;
		esac
	done
	printf '%s' "$out"
}

user_input=$(echo "" | rofi -dmenu -p " " -theme-str 'listview { enabled: false; }' || true)

if [ -n "$user_input" ]; then
	helium "https://chat.openai.com/?q=$(urlencode "$user_input")"
fi

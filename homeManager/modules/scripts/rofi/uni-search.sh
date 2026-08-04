#!/usr/bin/env bash
set -euo pipefail

browser="helium"
user_input="$(printf '' | rofi -dmenu -p " " -theme-str 'listview { enabled: false; }' || true)"

if [[ -z "$user_input" ]]; then
	exit 0
fi

looks_like_url() {
	[[ "$user_input" =~ ^https?:// ]] ||
		[[ "$user_input" =~ ^[^[:space:]]+\.(com|ca|org|to|io|ai)(/.*)?$ ]]
}

parse_flag() {
	flag=""
	query=""
	if [[ "$user_input" =~ ^[[:space:]]*(-[cahngsw])[[:space:]]+(.+)$ ]]; then
		flag="${BASH_REMATCH[1]}"
		query="${BASH_REMATCH[2]}"
		return 0
	fi
	return 1
}

urlencode() {
	jq -sRr @uri
}

flag=""
query=""
if ! looks_like_url && ! parse_flag; then
	user_input="$(printf '%s' "$user_input" | aichat -r systemhelp || true)"
fi

if [[ -z "$user_input" ]]; then
	exit 0
fi

flag=""
query=""
parse_flag || true

if looks_like_url; then
	"$browser" "$user_input"
elif [[ -n "$flag" ]]; then
	case "$flag" in
	-g)
		"$browser" "https://www.google.com/search?q=$(printf '%s' "$query" | urlencode)"
		;;
	-c)
		"$browser" "https://chat.openai.com/?q=$(printf '%s' "$query" | urlencode)"
		;;
	-a)
		"$browser" "https://9animetv.to/search?keyword=$(printf '%s' "$query" | urlencode)"
		;;
	-h)
		"$browser" --incognito "https://www.google.com/search?q=$(printf '%s' "$query" | urlencode)"
		;;
	-n)
		"$browser" "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=$(printf '%s' "$query" | urlencode)"
		;;
	-s)
		printf '%s\n' "$query"
		;;
	-w)
		route="$(printf '%s' "$query" | aichat -r route || true)"
		if [[ -n "$route" ]]; then
			"$browser" "$route"
		fi
		;;
	esac
fi

#!/usr/bin/env bash

set -euo pipefail

browser="zen-beta"
url="https://chatgpt.com/"
scratchpad_name="chatgpt"

have() {
	command -v "$1" >/dev/null 2>&1
}

is_hyprland() {
	have hyprctl && hyprctl monitors >/dev/null 2>&1
}

is_mango() {
	have mmsg
}

hypr_clients() {
	hyprctl clients 2>/dev/null || true
}

hypr_chatgpt_address() {
	hypr_clients | awk '
    function flush() {
      if (address != "" && class ~ /zen/ && title ~ /^ChatGPT/) {
        print address
        found = 1
      }
    }

    /^Window / {
      if (!found) flush()
      address = $2
      sub(/:$/, "", address)
      class = ""
      title = ""
      next
    }

    /^[[:space:]]+class:/ {
      sub(/^[[:space:]]+class:[[:space:]]*/, "")
      class = $0
      next
    }

    /^[[:space:]]+title:/ {
      sub(/^[[:space:]]+title:[[:space:]]*/, "")
      title = $0
      next
    }

    END {
      if (!found) flush()
    }
  ' | head -n 1
}

hypr_zen_addresses() {
	hypr_clients | awk '
    function flush() {
      if (address != "" && class ~ /zen/) print address
    }

    /^Window / {
      flush()
      address = $2
      sub(/:$/, "", address)
      class = ""
      next
    }

    /^[[:space:]]+class:/ {
      sub(/^[[:space:]]+class:[[:space:]]*/, "")
      class = $0
      next
    }

    END {
      flush()
    }
  '
}

hypr_new_zen_address() {
	local before="$1"

	while IFS= read -r address; do
		if [ -n "$address" ] && ! printf '%s\n' "$before" | grep -Fxq "$address"; then
			printf '%s\n' "$address"
			return 0
		fi
	done < <(hypr_zen_addresses)

	return 1
}

hypr_place_scratchpad() {
	local address="$1"

	hyprctl dispatch setfloating "address:$address" >/dev/null 2>&1 || true
	hyprctl dispatch resizewindowpixel "exact 1200 900,address:$address" >/dev/null 2>&1 || true
	hyprctl dispatch movetoworkspacesilent "special:$scratchpad_name,address:$address" >/dev/null 2>&1 || true
}

toggle_hyprland() {
	local address before

	address="$(hypr_chatgpt_address)"
	if [ -n "$address" ]; then
		hypr_place_scratchpad "$address"
		hyprctl dispatch togglespecialworkspace "$scratchpad_name" >/dev/null
		return 0
	fi

	before="$(hypr_zen_addresses)"
	setsid -f "$browser" --new-window "$url" >/dev/null 2>&1

	for _ in $(seq 1 50); do
		address="$(hypr_chatgpt_address)"
		if [ -z "$address" ]; then
			address="$(hypr_new_zen_address "$before" || true)"
		fi

		if [ -n "$address" ]; then
			hypr_place_scratchpad "$address"
			hyprctl dispatch togglespecialworkspace "$scratchpad_name" >/dev/null
			return 0
		fi

		sleep 0.1
	done

	printf 'Timed out waiting for ChatGPT Zen window\n' >&2
	return 1
}

toggle_mango() {
	mmsg -s -d "toggle_named_scratchpad,zen-beta,^ChatGPT,$browser --new-window $url"

	for _ in $(seq 1 60); do
		local appid=""
		local floating=""
		local status=""
		local title=""

		status="$(mmsg -g 2>/dev/null || true)"
		appid="$(printf '%s\n' "$status" | awk '/ appid / { sub(/^.* appid /, ""); print; exit }')"
		title="$(printf '%s\n' "$status" | awk '/ title / { sub(/^.* title /, ""); print; exit }')"
		floating="$(printf '%s\n' "$status" | awk '/ floating / { sub(/^.* floating /, ""); print; exit }')"

		if [ "$appid" = "zen-beta" ] && [[ "$title" == ChatGPT* ]]; then
			if [ "$floating" != "1" ]; then
				mmsg -s -d "toggle_named_scratchpad,zen-beta,^ChatGPT,$browser --new-window $url"
			fi
			return 0
		fi

		sleep 0.1
	done
}

if is_hyprland; then
	toggle_hyprland
elif is_mango; then
	toggle_mango
else
	printf 'No running Hyprland or Mango compositor found\n' >&2
	exit 1
fi

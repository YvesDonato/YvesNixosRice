#!/usr/bin/env bash
set -euo pipefail

INTERNAL_OUTPUT="${HYPR_INTERNAL_OUTPUT:-eDP-1}"
INTERNAL_MODE="${HYPR_INTERNAL_MODE:-highres@highrr}"
INTERNAL_POSITION="${HYPR_INTERNAL_POSITION:-auto}"
INTERNAL_SCALE="${HYPR_INTERNAL_SCALE:-1.333333}"
OPEN_RETRIES="${HYPR_LID_OPEN_RETRIES:-14}"
OPEN_RETRY_DELAY="${HYPR_LID_OPEN_RETRY_DELAY:-0.5}"

enable_internal() {
	hyprctl keyword monitor "$INTERNAL_OUTPUT, $INTERNAL_MODE, $INTERNAL_POSITION, $INTERNAL_SCALE, vrr, 1" || true
	hyprctl dispatch dpms on || true
}

disable_internal() {
	sleep 0.5
	hyprctl keyword monitor "$INTERNAL_OUTPUT, disable"
}

internal_is_active() {
	hyprctl monitors 2>/dev/null | awk -v internal="$INTERNAL_OUTPUT" '
		/^Monitor / {
			if (seen && name == internal) {
				found = 1
				active = (disabled != "true")
			}

			name = $2
			disabled = "false"
			seen = 1
			next
		}

		/^[[:space:]]*disabled:/ {
			disabled = $2
			next
		}

		END {
			if (seen && name == internal) {
				found = 1
				active = (disabled != "true")
			}

			exit !(found && active)
		}
	'
}

enable_internal_with_retries() {
	local attempt

	for ((attempt = 1; attempt <= OPEN_RETRIES; attempt++)); do
		enable_internal

		if internal_is_active; then
			exit 0
		fi

		sleep "$OPEN_RETRY_DELAY"
	done

	enable_internal
}

case "${1:-}" in
	closed) disable_internal ;;
	open) enable_internal_with_retries ;;
	*)
		printf 'usage: %s {closed|open}\n' "$0" >&2
		exit 2
		;;
esac

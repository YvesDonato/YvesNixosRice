#!/usr/bin/env bash
set -euo pipefail

TOGGLE_FILE="$HOME/.my_toggle_state"
# The key lives outside the repo (this file is version-controlled; the old
# inlined key had to be rotated). Same env file the Quickshell lights panel
# reads.
ENV_FILE="$HOME/.config/govee/.env"
if [[ ! -r "$ENV_FILE" ]]; then
	echo "lights.bash: missing $ENV_FILE (expected GOVEE_API_KEY=...)" >&2
	exit 1
fi
# shellcheck source=/dev/null
source "$ENV_FILE"
API_KEY="${GOVEE_API_KEY:-}"
if [[ -z "$API_KEY" ]]; then
	echo "lights.bash: no GOVEE_API_KEY in $ENV_FILE" >&2
	exit 1
fi
API_URL="https://openapi.api.govee.com/router/api/v1/device/control"

send_power() {
	local request_id="$1"
	local sku="$2"
	local device="$3"
	local value="$4"

	curl \
		--fail \
		--silent \
		--show-error \
		--connect-timeout 5 \
		--max-time 15 \
		-X POST "$API_URL" \
		-H "Content-Type: application/json" \
		-H "Govee-API-Key: $API_KEY" \
		-d "{\"requestId\":\"$request_id\",\"payload\":{\"sku\":\"$sku\",\"device\":\"$device\",\"capability\":{\"type\":\"devices.capabilities.on_off\",\"instance\":\"powerSwitch\",\"value\":$value}}}"
}

# Per-bulb device IDs — valid while the bulbs are NOT grouped in the Govee
# Home app (grouping hides them from the API and breaks these calls; check
# `user/devices` if this ever starts failing).
if [[ -e "$TOGGLE_FILE" ]]; then
	send_power "uuid-bulb-1" "H6010" "E7:28:98:17:3C:0F:9E:2A" 0
	send_power "uuid-bulb-2" "H6010" "AE:50:98:17:3C:10:E7:10" 0
	rm -f "$TOGGLE_FILE"
else
	send_power "uuid-bulb-1" "H6010" "E7:28:98:17:3C:0F:9E:2A" 1
	send_power "uuid-bulb-2" "H6010" "AE:50:98:17:3C:10:E7:10" 1
	touch "$TOGGLE_FILE"
fi

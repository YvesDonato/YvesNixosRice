#!/usr/bin/env bash
set -euo pipefail

TOGGLE_FILE="$HOME/.my_toggle_state"
API_KEY="af25940e-97c7-4488-aab6-9cb43bef077e"
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

if [[ -e "$TOGGLE_FILE" ]]; then
	send_power "uuid-bulb-1" "H6010" "E7:28:98:17:3C:0F:9E:2A" 0
	send_power "uuid-bulb-2" "H6010" "AE:50:98:17:3C:10:E7:10" 0
	rm -f "$TOGGLE_FILE"
else
	send_power "uuid-bulb-1" "H6010" "E7:28:98:17:3C:0F:9E:2A" 1
	send_power "uuid-bulb-2" "H6010" "AE:50:98:17:3C:10:E7:10" 1
	touch "$TOGGLE_FILE"
fi

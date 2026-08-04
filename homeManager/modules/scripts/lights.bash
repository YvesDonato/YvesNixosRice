#!/usr/bin/env bash
set -euo pipefail

TOGGLE_FILE="$HOME/.my_toggle_state"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/govee-toggle-${UID}.lock"
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

# Serialize toggles so two bindings cannot race and invert the persisted state.
exec 9>"$LOCK_FILE"
flock -x 9

send_power() {
	local request_id="$1"
	local response
	local sku="$2"
	local device="$3"
	local value="$4"

	response="$(curl \
		--fail \
		--silent \
		--show-error \
		--connect-timeout 5 \
		--max-time 15 \
		-X POST "$API_URL" \
		-H "Content-Type: application/json" \
		-H "Govee-API-Key: $API_KEY" \
		-d "{\"requestId\":\"$request_id\",\"payload\":{\"sku\":\"$sku\",\"device\":\"$device\",\"capability\":{\"type\":\"devices.capabilities.on_off\",\"instance\":\"powerSwitch\",\"value\":$value}}}")"

	if ! printf '%s' "$response" | jq -e --arg request_id "$request_id" '
		.code == 200
		and .requestId == $request_id
		and (((.msg // .message // "") | ascii_downcase) == "success")
	' >/dev/null; then
		printf 'govee-toggle: API rejected request %s for %s\n' "$request_id" "$device" >&2
		return 1
	fi
}

# Per-bulb device IDs — valid while the bulbs are NOT grouped in the Govee
# Home app (grouping hides them from the API and breaks these calls; check
# `user/devices` if this ever starts failing).
if [[ -e "$TOGGLE_FILE" ]]; then
	target_value=0
else
	target_value=1

fi

send_power "$(uuidgen)" "H6010" "E7:28:98:17:3C:0F:9E:2A" "$target_value" &
first_pid=$!
send_power "$(uuidgen)" "H6010" "AE:50:98:17:3C:10:E7:10" "$target_value" &
second_pid=$!

status=0
wait "$first_pid" || status=1
wait "$second_pid" || status=1

if ((status != 0)); then
	echo "govee-toggle: one or more bulb requests failed; state was not changed" >&2
	exit 1
fi

if ((target_value == 1)); then
	touch "$TOGGLE_FILE"
else
	rm -f "$TOGGLE_FILE"
fi

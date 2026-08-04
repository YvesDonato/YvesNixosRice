#!/usr/bin/env bash

set -euo pipefail

primary_output="DP-2"
laptop_output="eDP-1"

primary_mode_wlr="3440x1440@143.975Hz"
primary_mode_hypr="3440x1440@143.975"
laptop_mode_wlr="2560x1600@165.002Hz"
laptop_mode_hypr="2560x1600@165.002"
primary_scale="1"
laptop_scale="1.333333"

primary_width=3440
laptop_logical_width=1920

wlr_position_x() {
	local output="$1"

	wlr-randr 2>/dev/null | awk -v output="$output" '
    $1 == output {
      in_output = 1
      next
    }
    /^[^[:space:]]/ {
      in_output = 0
    }
    in_output && $1 == "Position:" {
      split($2, coords, ",")
      print coords[1]
      exit
    }
  '
}

hypr_position_x() {
	local output="$1"

	hyprctl monitors 2>/dev/null | awk -v output="$output" '
    $1 == "Monitor" && $2 == output {
      in_output = 1
      next
    }
    $1 == "Monitor" {
      in_output = 0
    }
    in_output && $1 == "at" {
      split($2, coords, "x")
      print coords[1]
      exit
    }
  '
}

target_side() {
	local current_x="$1"

	if [[ "$current_x" =~ ^-?[0-9]+$ ]] && ((current_x <= 0)); then
		printf 'right\n'
	else
		printf 'left\n'
	fi
}

apply_wlr_layout() {
	local side="$1"

	case "$side" in
	left)
		wlr-randr \
			--output "$laptop_output" --on --mode "$laptop_mode_wlr" --pos "0,0" --scale "$laptop_scale" \
			--output "$primary_output" --on --mode "$primary_mode_wlr" --pos "${laptop_logical_width},0" --scale "$primary_scale"
		;;
	right)
		wlr-randr \
			--output "$primary_output" --on --mode "$primary_mode_wlr" --pos "0,0" --scale "$primary_scale" \
			--output "$laptop_output" --on --mode "$laptop_mode_wlr" --pos "${primary_width},0" --scale "$laptop_scale"
		;;
	esac
}

apply_hypr_layout() {
	local side="$1"

	case "$side" in
	left)
		hyprctl eval "hl.monitor({ output = \"$laptop_output\", mode = \"$laptop_mode_hypr\", position = \"0x0\", scale = $laptop_scale, vrr = 1 })"
		hyprctl eval "hl.monitor({ output = \"$primary_output\", mode = \"$primary_mode_hypr\", position = \"${laptop_logical_width}x0\", scale = $primary_scale, vrr = 0 })"
		;;
	right)
		hyprctl eval "hl.monitor({ output = \"$primary_output\", mode = \"$primary_mode_hypr\", position = \"0x0\", scale = $primary_scale, vrr = 0 })"
		hyprctl eval "hl.monitor({ output = \"$laptop_output\", mode = \"$laptop_mode_hypr\", position = \"${primary_width}x0\", scale = $laptop_scale, vrr = 1 })"
		;;
	esac
}

current_x=""
if command -v wlr-randr >/dev/null 2>&1; then
	current_x="$(wlr_position_x "$laptop_output" || true)"
fi
if [ -z "$current_x" ] && command -v hyprctl >/dev/null 2>&1; then
	current_x="$(hypr_position_x "$laptop_output" || true)"
fi

side="$(target_side "$current_x")"

if command -v wlr-randr >/dev/null 2>&1 && apply_wlr_layout "$side"; then
	printf 'Moved %s to the %s of %s\n' "$laptop_output" "$side" "$primary_output"
	exit 0
fi

if command -v hyprctl >/dev/null 2>&1 && apply_hypr_layout "$side"; then
	printf 'Moved %s to the %s of %s\n' "$laptop_output" "$side" "$primary_output"
	exit 0
fi

printf 'Unable to move %s: no working wlr-randr or hyprctl command found\n' "$laptop_output" >&2
exit 1

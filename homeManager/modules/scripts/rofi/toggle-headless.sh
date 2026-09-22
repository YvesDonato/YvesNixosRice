#!/usr/bin/env bash

set -euo pipefail

monitor="streaming_monitor"

if hyprctl monitors | grep -q "$monitor"; then
	hyprctl output remove "$monitor"
else
	hyprctl output create headless "$monitor"
	hyprctl eval "hl.monitor({ output = \"$monitor\", mode = \"1920x1200@60\", position = \"auto\", scale = 1.2 })"
fi

#!/usr/bin/env bash

swww init &
sleep 1 & # Wait for 1 second
waypaper --restore &
blanket &
spotify &
discord &
echo 80 | tee /sys/class/power_supply/BAT0/charge_control_end_threshold

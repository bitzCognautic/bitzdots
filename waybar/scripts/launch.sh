#!/bin/bash

# Start waybar and swaync if not already running
pgrep -x waybar > /dev/null || waybar &
pgrep -x swaync > /dev/null || swaync &

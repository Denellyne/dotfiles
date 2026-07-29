#!/bin/bash
# Credits to isaiah76 https://github.com/isaiah76/hypr-rotate-monitor/blob/main/hypr-rotate-monitor.sh

if [ -n "$1" ] && [ "$1" == 2 ]; then
  ROTATE=2
elif [ -n "$1" ]; then
  ROTATE=3
else
  ROTATE=1
fi

# find target monitor
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

if [ -z "$MONITOR" ]; then
  notify-send "Rotation Error" "Could not detect active monitor"
  exit 1
fi

# get current monitor
MON_INFO=$(hyprctl monitors -j | jq -r --arg m "$MONITOR" '.[] | select(.name == $m)')

if [ -z "$MON_INFO" ]; then
  notify-send "Rotation Error" "Monitor $MONITOR not found"
  exit 1
fi

read -r NATIVE_WIDTH NATIVE_HEIGHT REFRESH SCALE X_POS Y_POS CURRENT_TRANSFORM <<<"$(echo "$MON_INFO" | jq -r '
    .scale as $s |
    .width as $wp |
    .height as $hp |
    ([$wp, $hp] | max | floor) as $native_w |
    ([$wp, $hp] | min | floor) as $native_h |
    "\($native_w) \($native_h) \(.refreshRate) \($s) \(.x) \(.y) \(.transform)"
')"
REFRESH=$(echo "scale=2; $REFRESH / 1.00" | bc)
SCALE=$(echo "scale=0; $SCALE / 1.00" | bc)

# 0: Normal, 1: 90 deg, 2: 180 deg, 3: 270 deg
NEXT_TRANSFORM=$(((CURRENT_TRANSFORM + (1 * ROTATE)) % 4))
if [ $ROTATE == 2 ]; then
  NEXT_TRANSFORM=0
fi

# apply rotation
hyprctl eval "hl.monitor({ output = \"$MONITOR\", mode = \"${NATIVE_WIDTH}x${NATIVE_HEIGHT}@${REFRESH}\", position = \"${X_POS}x${Y_POS}\", scale = $SCALE, transform = $NEXT_TRANSFORM })"

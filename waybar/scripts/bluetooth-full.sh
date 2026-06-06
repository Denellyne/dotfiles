#!/bin/bash

STATE=$(bluetoothctl show | awk '/Powered:/ {print $2}')


# Display status in Waybar
if [ "$STATE" = "yes" ]; then

  CONNECTED_MAC=$(bluetoothctl devices Connected | awk '{print $2}')
  if [ -n "$CONNECTED_MAC" ]; then
    CONNECTED_NAME=$(bluetoothctl info "$CONNECTED_MAC" | awk -F': ' '/Name/ {print $2}')
    echo " $CONNECTED_NAME"
  else
    echo " On"
  fi
else
  echo " Off"
fi

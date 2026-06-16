#!/bin/bash

while true; do

  STATE=$(bluetoothctl show | awk '/Powered:/ {print $2}')

  # Display status in Waybar
  if [ "$STATE" = "yes" ]; then

    CONNECTED_MAC=$(bluetoothctl devices Connected | awk '{print $2}')
    if [ -n "$CONNECTED_MAC" ]; then
      CONNECTED_NAME=$(bluetoothctl info "$CONNECTED_MAC" | awk -F': ' '/Name/ {print $2}')
      BATT=$(bluetoothctl info "$CONNECTED_MAC" | grep "Battery Percentage" | awk -F '[()]' '{print $2}')
      if [ -n "$BATT" ]; then
        echo " $CONNECTED_NAME $BATT%"
      else
        echo " $CONNECTED_NAME"
      fi
    else
      echo " On"
    fi
  else
    echo " Off"
  fi
  sleep 5
done

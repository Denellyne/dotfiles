#!/bin/bash
while true; do
read -r cpu_raw < /sys/class/hwmon/hwmon4/temp1_input
read -r gpu_raw < /sys/class/drm/card2/device/hwmon/hwmon2/temp1_input
printf " %d°C  󰢮 %d°C\n" $((cpu_raw / 1000)) $((gpu_raw / 1000))
sleep 5
done

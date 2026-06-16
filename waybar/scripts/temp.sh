#!/bin/bash

# Dynamically find the AMD CPU thermal zone
CPU_PATH=$(grep -l "k10temp" /sys/class/hwmon/hwmon*/name 2>/dev/null | sed 's/name$//')

# Ensure this PCI address matches your NVIDIA card (check via: lspci | grep VGA)
NV_PCI="0000:01:00.0"

while true; do
  # Read CPU Temp
  if [ -n "$CPU_PATH" ] && [ -f "${CPU_PATH}temp1_input" ]; then
    read -r cpu_raw <"${CPU_PATH}temp1_input"
    cpu_temp=$((cpu_raw / 1000))
  else
    cpu_temp="--"
  fi

  # Check kernel PCI runtime status to see if the card is awake
  nv_status="suspended"
  if [ -f "/sys/bus/pci/devices/$NV_PCI/power/runtime_status" ]; then
    read -r nv_status <"/sys/bus/pci/devices/$NV_PCI/power/runtime_status"
  fi

  # Only run nvidia-smi if the card is active
  if [ "$nv_status" = "active" ]; then
    gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null)
    [ -z "$gpu_temp" ] && gpu_temp="Err"

    # Print both temps
    printf " %s°C  󰢮 %s°C\n" "$cpu_temp" "$gpu_temp"
  else
    # Hide the GPU entirely to keep the bar clean when suspended
    printf " %s°C\n" "$cpu_temp"
  fi

  sleep 5
done

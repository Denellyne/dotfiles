#!/bin/bash

CONFIG="$HOME/.config/cava/config"

trap 'pkill -P $$' EXIT SIGINT SIGTERM

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

mapfile -t colors < <(
  grep -E "^gradient_color_" "$CONFIG" |
    sort -t_ -k3,3n |
    sed "s/.*= *//g" |
    tr -d "'\""
)

if [ ${#colors[@]} -eq 0 ]; then
  colors=("#2a6ef6" "#39e036" "#ffc300" "#f52055")
fi

hex_to_rgb() {
  hex=${1#"#"}
  echo "$((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))"
}

interp_color() {
  local v=$1
  local max=7
  local segments=$((${#colors[@]} - 1))
  local pos=$((v * segments))
  local idx=$((pos / max))
  local t=$(((pos % max) * 100 / max))

  local c1=${colors[$idx]}
  local c2=${colors[$((idx + 1 < ${#colors[@]} ? idx + 1 : idx))]}

  read -r r1 g1 b1 <<<"$(hex_to_rgb "$c1")"
  read -r r2 g2 b2 <<<"$(hex_to_rgb "$c2")"

  r=$((r1 + (r2 - r1) * t / 100))
  g=$((g1 + (g2 - g1) * t / 100))
  b=$((b1 + (b2 - b1) * t / 100))

  printf "#%02x%02x%02x" "$r" "$g" "$b"
}

awk_array_init=""
for i in {0..7}; do
  c=$(interp_color "$i")
  awk_array_init+="spans[$i]=\"<span foreground='$c'>${bars[$i]}</span>\"; "
done

stdbuf -oL cava -p "$CONFIG" | awk -F';' '
  BEGIN {
    # Inject the pre-computed spans array into awk
    '"$awk_array_init"'
  }
  {
    # Skip empty lines
    if ($0 == "") next
    
    out = ""
    # Loop through each delimited value from cava
    for(i=1; i<=NF; i++) {
      v = $i
      if (v == "") continue
      
      # Clamp the values to our 0-7 range
      if (v > 7) v = 7
      if (v < 0) v = 0
      
      # Append the pre-formatted pango span
      out = out spans[v]
    }
    
    # Print the JSON string and flush buffer immediately for Waybar
    printf "{\"text\":\"%s\",\"markup\":\"pango\"}\n", out
    fflush()
  }
'

#!/bin/bash

CONFIG="$HOME/.config/cava/config"

# ---- FIFO SETUP ----
PIPE="/tmp/cava_waybar_$$.fifo"
mkfifo "$PIPE"

# Clean up the pipe and kill cava when the script exits
trap "rm -f $PIPE; pkill -P $$" EXIT SIGINT SIGTERM

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

# ---- extract gradient colors from cava config ----
mapfile -t colors < <(
    grep -E "^gradient_color_" "$CONFIG" \
    | sort -t_ -k3,3n \
    | sed "s/.*= *//g" \
    | tr -d "'\""
)

# fallback if no gradient defined
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
    local segments=$(( ${#colors[@]} - 1 ))
    local pos=$(( v * segments ))
    local idx=$(( pos / max ))
    local t=$(( (pos % max) * 100 / max ))

    local c1=${colors[$idx]}
    local c2=${colors[$((idx+1 < ${#colors[@]} ? idx+1 : idx))]}

    read r1 g1 b1 <<< $(hex_to_rgb "$c1")
    read r2 g2 b2 <<< $(hex_to_rgb "$c2")

    r=$(( r1 + (r2 - r1) * t / 100 ))
    g=$(( g1 + (g2 - g1) * t / 100 ))
    b=$(( b1 + (b2 - b1) * t / 100 ))

    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# ==========================================
# PERFORMANCE FIX: PRE-COMPUTE ALL 8 COLORS
# ==========================================
declare -a fast_colors
for i in {0..7}; do
    fast_colors[$i]=$(interp_color "$i")
done


# ---- RUN CAVA IN BACKGROUND ----
stdbuf -oL cava -p "$CONFIG" > "$PIPE" &


# ---- THE ULTRA-FAST READ LOOP ----
while IFS= read -r line; do
    [ -z "$line" ] && continue

    output=""
    IFS=';' read -ra values <<< "$line"

    for v in "${values[@]}"; do
        [[ -z "$v" ]] && continue
        
        # Clamp values
        (( v > 7 )) && v=7
        (( v < 0 )) && v=0

        # Instant array lookup instead of doing math
        color="${fast_colors[$v]}"
        bar="${bars[$v]}"

        output+="<span foreground='$color'>$bar</span>"
    done

    # Remove quotes to avoid breaking JSON
    output=${output//\"/\\\"}

    echo "{\"text\":\"$output\",\"markup\":\"pango\"}"
done < "$PIPE"

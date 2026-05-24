#!/bin/bash
CONFIG=$1
OUTPUT=$2
cava -p "$CONFIG" | while read -r line; do
    echo "$line" > "$OUTPUT"
done

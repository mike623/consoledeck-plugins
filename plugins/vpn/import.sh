#!/bin/bash
# Keeps a copy of the picked .ovpn beside deck.json, hands it to Tunnelblick to install (it asks how)
# and prints the name Tunnelblick gives it: the file name without extension.
set -euo pipefail
dir="$CONSOLEDECK_DIR/vpn"
mkdir -p "$dir"
cp "$1" "$dir/"
open -a /Applications/Tunnelblick.app "$dir/$(basename "$1")"
name=$(basename "$1")
echo "${name%.*}"

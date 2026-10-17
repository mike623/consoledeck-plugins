#!/bin/sh
# Prints one stat of le-scanner's last imported character when it changes: "level", "sheet.Fire Resistance"...
# Keeps the last value while le-scanner is busy (409) or closed; "–" until there is one.
API=http://127.0.0.1:8765/api/character
shown=
while :; do
  if v=$(curl -sf -m 3 "$API" | plutil -extract "$1" raw -o - - 2>/dev/null); then
    [ "$1" = playtime_s ] && v="$((v / 3600))h"
  else
    v=${shown:-–}
  fi
  [ "$v" != "$shown" ] && echo "$v" && shown=$v
  sleep 10
done

#!/bin/sh
# Prints the game Boosteroid is streaming when it changes, or an empty line when none, from its log:
# "Stream IDs WxH: 2560 1440 app: Last Epoch" starts one; "Stopping everything..." or a restart ends it.
# A loop, not tail -F: ConsoleDeck kills this shell, and a tail in a pipeline would outlive it.
LOG="$HOME/Library/Application Support/Boosteroid Games S.R.L./bstr_client.log"
off=0 game= shown=x
while :; do
  size=$(stat -f %z "$LOG" 2>/dev/null || echo 0)
  [ "$size" -lt "$off" ] && off=0 # rotated
  if [ "$size" -gt "$off" ]; then
    last=$(tail -c +$((off + 1)) "$LOG" | sed -n -e 's/.*Stream IDs WxH: .* app: /=/p' \
      -e 's/.*Controller\]: Stopping everything\.\.\..*/=/p' -e 's/.*\] Starting  "Boosteroid".*/=/p' | tail -n 1)
    [ -n "$last" ] && game=${last#=}
    off=$size
  fi
  [ "$game" != "$shown" ] && echo "$game" && shown=$game
  sleep 2
done

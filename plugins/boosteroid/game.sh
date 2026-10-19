#!/bin/sh
# Prints the game Boosteroid is streaming when it changes, or an empty line when none, from its log:
# "Stream IDs WxH: 2560 1440 app: Last Epoch" starts one; "Stopping everything..." or a restart ends it.
# Keeps the stream from timing out: Boosteroid warns ("Inactivity dialog shown") after ~8.5 min without
# input and ends the session 2 min later, so on a warning it taps Shift. This runs only while Boosteroid
# is in front, so the key lands there.
# A loop, not tail -F: ConsoleDeck kills this shell, and a tail in a pipeline would outlive it.
LOG="$HOME/Library/Application Support/Boosteroid Games S.R.L./bstr_client.log"
off=0 game= shown=x first=1
while :; do
  size=$(stat -f %z "$LOG" 2>/dev/null || echo 0)
  [ "$size" -lt "$off" ] && off=0 # rotated
  if [ "$size" -gt "$off" ]; then
    new=$(tail -c +$((off + 1)) "$LOG")
    last=$(printf '%s\n' "$new" | sed -n -e 's/.*Stream IDs WxH: .* app: /=/p' \
      -e 's/.*Controller\]: Stopping everything\.\.\..*/=/p' -e 's/.*\] Starting  "Boosteroid".*/=/p' | tail -n 1)
    [ -n "$last" ] && game=${last#=}
    # ponytail: Shift (key code 56) is harmless in most games; keeps a forgotten stream alive until Boosteroid's own limit
    [ -z "$first" ] && [ -n "$game" ] && case $new in *"Inactivity dialog shown"*)
      /usr/bin/osascript -e 'tell application "System Events" to key code 56' >/dev/null 2>&1 ;; esac
    off=$size first=
  fi
  [ "$game" != "$shown" ] && echo "$game" && shown=$game
  sleep 2
done

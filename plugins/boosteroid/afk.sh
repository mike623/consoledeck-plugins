#!/bin/sh
# AFK mode, toggled by a press: keeps the Mac awake and taps a random modifier (Shift, Control or Option)
# every 2-5 min, well inside Boosteroid's ~8.5 min inactivity warning. Taps only while Boosteroid is in
# front, so nothing lands in another app. Stops on the next press or when Boosteroid quits.
PID="${TMPDIR:-/tmp}/consoledeck-boosteroid-afk.pid"
say() { /usr/bin/osascript -e "display notification \"$1\" with title \"Boosteroid\"" >/dev/null 2>&1; }
# Every tap and its result goes to the log; macOS refuses taps until ConsoleDeck may control System Events
LOG="${TMPDIR:-/tmp}/consoledeck-boosteroid-afk.log"
log() { echo "$(date '+%F %T') $*" >>"$LOG"; }
if [ "$1" != loop ]; then
  pid=$(cat "$PID" 2>/dev/null)
  if [ -n "$pid" ] && ps -p "$pid" -o command= | grep -q afk.sh && kill "$pid"; then
    rm -f "$PID"; log "stop: pressed"; say "AFK mode off"; exit
  fi
  nohup /bin/sh "$0" loop </dev/null >/dev/null 2>&1 &
  echo $! >"$PID"
  say "AFK mode on"
  exit
fi
log "start pid $$"
/usr/bin/caffeinate -di -w $$ & # display and system stay awake until this loop ends
while pgrep -xq Boosteroid; do
  case $(lsappinfo info -only bundleid "$(lsappinfo front)") in
    *'"com.boosteroid.macclient"'*)
      # ponytail: Shift, Option, Control alone are harmless in most games; swap key codes here if one isn't
      key=$(printf '56\n58\n59\n' | sort -R | head -n 1)
      err=$(/usr/bin/osascript -e "tell application \"System Events\" to key code $key" 2>&1)
      log "tap $key ${err:-ok}" ;;
    *) log "skip: Boosteroid not in front" ;;
  esac
  sleep "$(jot -r 1 120 300)"
done
log "stop: Boosteroid quit"
rm -f "$PID"
say "AFK mode off: Boosteroid quit"

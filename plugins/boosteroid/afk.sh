#!/bin/sh
# AFK mode, toggled by a press: keeps the Mac awake and, once Boosteroid has had no input for 5 min, taps a
# random modifier (Shift, Control or Option), well inside its ~8.5 min inactivity warning. While you play,
# your own input resets the count, so it can stay on. Each tap goes to Boosteroid, brought to the front for
# it if needed. Stops on the next press or when Boosteroid quits.
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
IDLE=300 # ponytail: seconds without input before a tap; Boosteroid warns at ~510, kicks at ~630 (idle.sh)
last=$(date +%s)
while pgrep -xq Boosteroid; do
  sleep 5
  now=$(date +%s)
  # Only input while Boosteroid is in front reaches the stream, so idle time counts from the last input there
  case $(lsappinfo info -only bundleid "$(lsappinfo front)") in *'"com.boosteroid.macclient"'*)
    idle=$(ioreg -c IOHIDSystem -d 4 | awk '/HIDIdleTime/ { print int($NF / 1000000000); exit }')
    [ $((now - idle)) -gt "$last" ] && last=$((now - idle)) ;;
  esac
  [ $((now - last)) -lt "$IDLE" ] && continue
  # ponytail: Shift, Option, Control alone are harmless in most games; swap key codes here if one isn't
  key=$(printf '56\n58\n59\n' | sort -R | head -n 1)
  # If another app took the front, bring Boosteroid forward for the tap and hand the front back: AFK means nobody is typing there
  err=$(/usr/bin/osascript -e "tell application \"System Events\"
    set prev to first application process whose frontmost is true
    set away to name of prev is not \"Boosteroid\"
    if away then
      set frontmost of process \"Boosteroid\" to true
      delay 1
    end if
    if not frontmost of process \"Boosteroid\" then error \"Boosteroid would not come to front from \" & name of prev
    key code $key
    if away then
      delay 0.5
      set frontmost of prev to true
      return \"ok via \" & name of prev
    end if
  end tell" 2>&1)
  log "tap $key ${err:-ok}"
  last=$(date +%s)
done
log "stop: Boosteroid quit"
rm -f "$PID"
say "AFK mode off: Boosteroid quit"

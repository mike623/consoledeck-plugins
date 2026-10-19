#!/bin/sh
# Time left before Boosteroid ends the stream for inactivity. It warns after ~8.5 min without input and
# ends the session 2 min later (game.sh taps Shift on the warning). Only input while
# Boosteroid is in front reaches the stream, so idle time counts from the last input there.
KICK=630 # ponytail: seconds, measured 18 Oct 2026 from bstr_client.log; change here if Boosteroid does
last=$(date +%s)
while :; do
  now=$(date +%s)
  if ! pgrep -xq Boosteroid; then
    echo "Boosteroid off"
    last=$now
  else
    case $(lsappinfo info -only bundleid "$(lsappinfo front)") in *'"com.boosteroid.macclient"'*)
      idle=$(ioreg -c IOHIDSystem -d 4 | awk '/HIDIdleTime/ { print int($NF / 1000000000); exit }')
      [ $((now - idle)) -gt "$last" ] && last=$((now - idle)) ;;
    esac
    gone=$((now - last)) left=$((KICK - now + last))
    [ "$left" -lt 0 ] && left=0
    printf 'Kick in %d:%02d\t%s\n' $((left / 60)) $((left % 60)) "$(echo "scale=2; $gone / $KICK" | bc)"
  fi
  sleep 1
done

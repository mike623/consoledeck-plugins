#!/bin/sh
# Phone tile, every second: the running action's last line, how the last one ended, else the character.
API=http://127.0.0.1:8765/api
get() { printf '%s' "$1" | plutil -extract "$2" raw -o - - 2>/dev/null; }
n=0 level=
while :; do
  job=$(curl -s -m 2 "$API/actions/current")
  if [ -z "$job" ]; then
    line=offline
  else
    if [ $((n % 30)) = 0 ]; then # the character changes rarely
      c=$(curl -s -m 2 "$API/character")
      level=$(get "$c" level) && level="Lv $level $(get "$c" class)" || level=idle
    fi
    action=$(get "$job" action)
    case $(get "$job" state) in
      running) count=$(get "$job" output); line=$( [ "${count:-0}" -gt 0 ] && get "$job" output.$((count - 1)) || echo "$action…") ;;
      done) line="✓ $action" ;;
      failed) line="✗ $action" ;;
      *) line=$level ;;
    esac
  fi
  echo "$line"
  n=$((n + 1))
  sleep 1
done

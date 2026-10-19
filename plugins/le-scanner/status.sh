#!/bin/sh
# Phone button text, every second, for the button's action ($1). Scan All Tabs shows any action: the running
# one's last line, how the last one ended, else "ready". Other buttons show only their own action, else
# nothing (their label). Character stats are the Last Epoch Character plugin's tiles.
API=http://127.0.0.1:8765/api
get() { printf '%s' "$1" | plutil -extract "$2" raw -o - - 2>/dev/null; }
while :; do
  job=$(curl -s -m 2 "$API/actions/current")
  action=$(get "$job" action)
  case $(get "$job" state) in
    running) count=$(get "$job" output); line=$( [ "${count:-0}" -gt 0 ] && get "$job" output.$((count - 1)) || echo "${action}…") ;;
    done) line="✓ ${action}" ;;
    failed) line="✗ ${action}" ;;
    idle) line=ready ;;
    *) line=offline ;;
  esac
  [ "$1" = scan-all ] || [ "$action" = "$1" ] || line=
  echo "$line"
  sleep 1
done

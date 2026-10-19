#!/bin/sh
# Starts a le-scanner action through its local API; it runs in the background there, one at a time.
API=http://127.0.0.1:8765/api
case "$1" in
  unuse) url=$API/unuse body= ;;
  planner) url=$API/planner body= ;;
  scan-tab) url=$API/actions/scan-tab body="{\"tab\":\"$2\"}" ;;
  *) url=$API/actions/$1 body={} ;;
esac
out=$(curl -sS -m 5 -X POST -H 'Content-Type: application/json' ${body:+-d "$body"} -w '\n%{http_code}' "$url" 2>&1) ||
  { echo "le-scanner isn't running: start it with \`le-scanner overlay\`" >&2; exit 1; }
code=${out##*
}
[ "${code#2}" != "$code" ] || { echo "le-scanner $1: HTTP $code ${out%
*}" >&2; exit 1; }

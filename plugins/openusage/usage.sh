#!/bin/sh
# One "29% · 2h31m<TAB>0.29<TAB>0.14" line per 30s from OpenUsage's local API: the session (or first) limit, its reset
# countdown, then session and weekly shares for the chart. OpenUsage itself refreshes every 5 minutes.
while :; do
  json=$(curl -sf -m 3 "http://127.0.0.1:6736/v1/limits/$1")
  [ -z "$json" ] && echo "OpenUsage off" || echo "$json" | /usr/bin/jq -r --arg p "$1" '
    def left: sub("\\.[0-9]+Z$"; "Z") | fromdate - now | floor | if . < 0 then 0 else . end
      | if . >= 86400 then "\(. / 86400 | floor)d\(. % 86400 / 3600 | floor)h" else "\(. / 3600 | floor)h\(. % 3600 / 60 | floor)m" end;
    def amount(v): if .unit == "percent" then "\(v | round)%" elif .unit == "usd" then "$\(v * 100 | round / 100)" else "\(v | round) \(.unit)" end;
    (.providers[$p].resources // {}) as $r
    | ($r.session // ([$r[] | select(.kind == "consumption")][0])) as $u
    | ([$r[] | select(.kind == "balance")][0]) as $b
    | if $u then
        "\($u | amount($u.used))\(if $u.resetsAt then " · " + ($u.resetsAt | left) else "" end)\t\($u.utilization // 0)\t\($r.weekly.utilization // 0)"
      elif $b then $b | amount($b.available)
      else "No data yet" end'
  sleep 30
done

#!/bin/sh
# Shows this Mac's network details in a list that stays open until Close; Copy puts the picked row's value
# on the clipboard and shows the list again. $1 is "public" to also look up the public IP.
rows=""
row() { [ -n "$2" ] && rows="$rows$1: $2
"; }

# Hardware ports (Wi-Fi, Ethernet, Thunderbolt Bridge...) that have an address, then VPN tunnels.
ports=$(networksetup -listallhardwareports | awk '/^Hardware Port:/ { sub(/^Hardware Port: /, ""); p = $0 } /^Device:/ { print $2 "\t" p }')
tab=$(printf '\t')
while IFS="$tab" read -r dev name; do
  ip=$(ipconfig getifaddr "$dev" 2>/dev/null) || continue
  [ -n "$ip" ] || continue
  row "$name IP" "$ip"
  ssid=$(ipconfig getsummary "$dev" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / { print $2; exit }')
  [ "$ssid" = "<redacted>" ] || row "$name Network" "$ssid"
  row "$name Subnet" "$(ipconfig getoption "$dev" subnet_mask 2>/dev/null)"
  row "$name IPv6" "$(ifconfig "$dev" | awk '/inet6 / && $2 !~ /^fe80/ { print $2; exit }')"
  row "$name MAC" "$(ifconfig "$dev" | awk '/ether / { print $2; exit }')"
done <<PORTS
$ports
PORTS
for dev in $(ifconfig -l); do
  case $dev in utun*|ppp*|ipsec*) ;; *) continue ;; esac
  row "VPN ($dev) IP" "$(ifconfig "$dev" | awk '/inet / { print $2; exit }')"
done

route=$(route -n get default 2>/dev/null)
row "Router" "$(echo "$route" | awk '/gateway:/ { print $2 }')"
row "Default Interface" "$(echo "$route" | awk '/interface:/ { print $2 }')"
row "DNS" "$(scutil --dns | awk '/nameserver\[[0-9]+\]/ && !seen[$3]++ { s = s (s ? ", " : "") $3 } END { print s }')"
[ "$1" = public ] && row "Public IP" "$(curl -fsS -m 3 https://api.ipify.org 2>/dev/null)"
row "Computer Name" "$(scutil --get ComputerName 2>/dev/null)"
host=$(scutil --get LocalHostName 2>/dev/null) && row "Local Hostname" "$host.local"
[ -n "$rows" ] || rows="Network: not connected
"

osascript - "$rows" <<'AS'
on run argv
  set rows to paragraphs of item 1 of argv
  if last item of rows is "" then set rows to items 1 thru -2 of rows
  set msg to "Pick one and Copy."
  set picked to {item 1 of rows}
  repeat
    tell application "System Events"
      activate
      set picked to choose from list rows with title "Network Info" with prompt msg default items picked OK button name "Copy" cancel button name "Close"
    end tell
    if picked is false then return
    set r to item 1 of picked
    set v to text ((offset of ": " in r) + 2) thru -1 of r
    set the clipboard to v
    set msg to "Copied " & v & ". Pick another, or Close."
  end repeat
end run
AS

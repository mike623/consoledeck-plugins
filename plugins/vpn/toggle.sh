#!/bin/bash
# Connects the named Tunnelblick configuration, or disconnects it when it's already up.
osascript - "$1" <<'AS'
on run argv
  set n to item 1 of argv
  tell application "Tunnelblick"
    if (get state of first configuration where name = n) is "CONNECTED" then
      disconnect n
    else
      connect n
    end if
  end tell
end run
AS

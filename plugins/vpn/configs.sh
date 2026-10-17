#!/bin/bash
# Tunnelblick's configuration names, one per line. Nothing when Tunnelblick isn't installed
# (asking it anyway would pop up a "Where is Tunnelblick?" dialog).
[ -d /Applications/Tunnelblick.app ] || exit 0
osascript <<'AS'
tell application "Tunnelblick" to set n to name of configurations
set AppleScript's text item delimiters to linefeed
n as text
AS

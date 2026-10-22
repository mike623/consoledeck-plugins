#!/bin/sh
# Enabled OpenUsage providers, "id<TAB>name" per line.
curl -s -m 3 http://127.0.0.1:6736/v1/limits | /usr/bin/jq -r '.providers | to_entries[] | "\(.key)\t\(.value.displayName)"'

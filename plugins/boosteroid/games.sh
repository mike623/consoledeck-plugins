#!/bin/sh
# Games streamed before, newest first, from Boosteroid's logs ("Stream IDs WxH: 2560 1440 app: Last Epoch"),
# so the editor can offer them when adding a game's profile ahead of streaming it.
DIR="$HOME/Library/Application Support/Boosteroid Games S.R.L."
cat "$DIR/bstr_client.1.log" "$DIR/bstr_client.log" 2>/dev/null | grep -a 'Stream IDs WxH: .* app: ' |
  sed 's/.* app: //' | tail -r | awk 'NF && !seen[$0]++'

#!/bin/sh
# One "NN%" line per second: 100 minus top's idle share.
top -l 0 -s 1 -n 0 | awk '/CPU usage/ { gsub("%", "", $7); printf "%d%%\n", 100 - $7; fflush() }'

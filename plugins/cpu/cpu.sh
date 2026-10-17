#!/bin/sh
# One "NN%<TAB>0.NN" line per second (the fraction is for the phone's chart): 100 minus top's idle share.
top -l 0 -s 1 -n 0 | awk '/CPU usage/ { gsub("%", "", $7); printf "%d%%\t%.2f\n", 100 - $7, (100 - $7) / 100; fflush() }'

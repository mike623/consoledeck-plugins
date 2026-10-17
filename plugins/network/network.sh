# One "↓80K ↑12K" line per second (bytes per second, all interfaces). top -d prints
# the change since the last sample, so the first line is always zero.
top -l 0 -s 1 -n 0 -d | awk '/^Networks:/ { split($3, i, "/"); split($5, o, "/"); printf "↓%s ↑%s\n", i[2], o[2]; fflush() }'

# One "↓80K ↑12K<TAB>81920<TAB>12288" line per second: bytes per second over all interfaces, then the same
# as plain numbers for the phone's chart (down green, up red). top -d prints the change since the last
# sample, so the first line is always zero.
top -l 0 -s 1 -n 0 -d | awk '
  function bytes(s,  n, u) { n = s + 0; u = substr(s, length(s)); return n * (u == "K" ? 1024 : u == "M" ? 1048576 : u == "G" ? 1073741824 : 1) }
  /^Networks:/ { split($3, i, "/"); split($5, o, "/"); printf "↓%s ↑%s\t%d\t%d\n", i[2], o[2], bytes(i[2]), bytes(o[2]); fflush() }'

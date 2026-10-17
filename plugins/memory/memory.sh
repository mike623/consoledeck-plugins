# One "NN%" line every two seconds. Counts what Activity Monitor calls Memory Used
# (app + wired + compressed); top's "used" also counts file cache, so it sits near 100%.
total=$(sysctl -n hw.memsize)
while :; do
  vm_stat | awk -v total="$total" '
    /page size of/ { size = $8 }
    /Anonymous pages/ { anon = $3 }
    /Pages purgeable/ { purge = $3 }
    /Pages wired down/ { wired = $4 }
    /Pages occupied by compressor/ { comp = $5 }
    END { printf "%d%%\n", (anon - purge + wired + comp) * size * 100 / total }' || exit
  sleep 2
done

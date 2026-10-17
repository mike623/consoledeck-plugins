# One "18.7 GB<TAB>0.78" line every two seconds (the fraction of RAM is for the phone's chart): Activity Monitor's Memory Used (app + wired + compressed),
# in GiB like Activity Monitor, which labels them GB. top's "used" also counts file cache.
total=$(sysctl -n hw.memsize)
while :; do
  vm_stat | awk -v total="$total" '
    /page size of/ { size = $8 }
    /Anonymous pages/ { anon = $3 }
    /Pages purgeable/ { purge = $3 }
    /Pages wired down/ { wired = $4 }
    /Pages occupied by compressor/ { comp = $5 }
    END { used = (anon - purge + wired + comp) * size; printf "%.1f GB\t%.3f\n", used / 1073741824, used / total }' || exit
  sleep 2
done

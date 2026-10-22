# One "95.5 GB free<TAB>0.80" line every 30 seconds (the fraction used is for the phone's chart). The Data volume, as its
# size minus what's available, covers every volume sharing the APFS container; GB are 10^9 bytes, like Finder.
while :; do
  df -k /System/Volumes/Data | awk 'NR == 2 { printf "%.1f GB free\t%.3f\n", $4 * 1024 / 1e9, ($2 - $4) / $2 }' || exit
  sleep 30
done

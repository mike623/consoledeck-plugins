# One line per second like "(down)80K (up)12K": bytes per second over all adapters.
function Size($b) {
  if ($b -ge 1GB) { return "{0:0.#}G" -f ($b / 1GB) }
  if ($b -ge 1MB) { return "{0:0.#}M" -f ($b / 1MB) }
  if ($b -ge 1KB) { return "{0:0}K" -f ($b / 1KB) }
  return "$([int]$b)B"
}
function Totals { Get-NetAdapterStatistics | Measure-Object ReceivedBytes, SentBytes -Sum }
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$last = Totals
while ($true) {
  Start-Sleep -Seconds 1
  $now = Totals
  $down = $now[0].Sum - $last[0].Sum
  $up = $now[1].Sum - $last[1].Sum
  $last = $now
  [Console]::Out.WriteLine("$([char]0x2193)$(Size $down) $([char]0x2191)$(Size $up)")
  [Console]::Out.Flush()
}

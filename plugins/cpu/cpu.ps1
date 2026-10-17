# One "NN%" line per second, averaged over every processor. WMI, so counter names don't depend on the Windows language.
while ($true) {
  $load = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
  [Console]::Out.WriteLine("$([int]$load)%")
  [Console]::Out.Flush()
  Start-Sleep -Seconds 1
}

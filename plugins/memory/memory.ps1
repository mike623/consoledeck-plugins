# One "NN%" line every two seconds. WMI, so it doesn't depend on the Windows language.
while ($true) {
  $os = Get-CimInstance Win32_OperatingSystem
  $used = 100 * (1 - $os.FreePhysicalMemory / $os.TotalVisibleMemorySize)
  [Console]::Out.WriteLine("$([int]$used)%")
  [Console]::Out.Flush()
  Start-Sleep -Seconds 2
}

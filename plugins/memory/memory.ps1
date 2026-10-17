# One "18.7 GB<TAB>0.78" line every two seconds (the fraction of RAM is for the phone's chart): physical memory in use. WMI, so it doesn't depend on the Windows language.
while ($true) {
  $os = Get-CimInstance Win32_OperatingSystem
  $used = $os.TotalVisibleMemorySize - $os.FreePhysicalMemory  # in KB
  [Console]::Out.WriteLine([string]::Format([cultureinfo]::InvariantCulture, "{0:0.0} GB`t{1:0.000}", $used / 1MB, $used / $os.TotalVisibleMemorySize))
  [Console]::Out.Flush()
  Start-Sleep -Seconds 2
}

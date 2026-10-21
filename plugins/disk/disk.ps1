# One "95.5 GB free<TAB>0.80" line every 30 seconds (the fraction used is for the phone's chart): the Windows drive, GB as 10^9 bytes.
while ($true) {
  $d = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"
  [Console]::Out.WriteLine([string]::Format([cultureinfo]::InvariantCulture, "{0:0.0} GB free`t{1:0.000}", $d.FreeSpace / 1e9, 1 - $d.FreeSpace / $d.Size))
  [Console]::Out.Flush()
  Start-Sleep -Seconds 30
}

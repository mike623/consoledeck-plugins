# One "NN%<TAB>0.NN" line per second (the fraction is for the phone's chart), averaged over every processor. WMI, so counter names don't depend on the Windows language.
while ($true) {
  $load = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
  [Console]::Out.WriteLine([string]::Format([cultureinfo]::InvariantCulture, "{0}%`t{1:0.00}", [int]$load, $load / 100))
  [Console]::Out.Flush()
  Start-Sleep -Seconds 1
}

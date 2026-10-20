# Shows this PC's network details in a window that stays open until Close; Copy (or a double-click)
# puts the picked row's value on the clipboard. $args[0] is "public" to also look up the public IP.
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$rows = New-Object System.Collections.Generic.List[object]
function Row($label, $value) { if ("$value") { $rows.Add(@($label, "$value")) } }

$ssid = netsh wlan show interfaces 2>$null | Select-String '^\s*SSID\s*:\s*(.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() } | Select-Object -First 1
foreach ($c in Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq 'Up' }) {
  $n = $c.InterfaceAlias
  $v4 = @($c.IPv4Address)
  Row "$n IP" (($v4 | ForEach-Object IPAddress) -join ', ')
  if ($c.NetAdapter.PhysicalMediaType -match '802\.11') { Row "$n Network" $ssid }
  if ($v4[0]) { Row "$n Subnet" "/$($v4[0].PrefixLength)" }
  Row "$n IPv6" ((@($c.IPv6Address) | ForEach-Object IPAddress) -join ', ')
  Row "$n Router" ((@($c.IPv4DefaultGateway) | ForEach-Object NextHop) -join ', ')
  Row "$n DNS" ((@($c.DNSServer) | Where-Object AddressFamily -eq 2 | ForEach-Object ServerAddresses) -join ', ')
  Row "$n MAC" $c.NetAdapter.MacAddress
}
if ($args[0] -eq 'public') {
  try { Row 'Public IP' (Invoke-RestMethod -Uri 'https://api.ipify.org' -TimeoutSec 3) } catch {}
}
Row 'Computer Name' $env:COMPUTERNAME
if ($rows.Count -eq 0) { Row 'Network' 'not connected' }

$form = New-Object Windows.Forms.Form -Property @{
  Text = 'Network Info'; Size = New-Object Drawing.Size(480, 400); StartPosition = 'CenterScreen'; TopMost = $true
  MinimizeBox = $false; MaximizeBox = $false
}
$list = New-Object Windows.Forms.ListView -Property @{ View = 'Details'; FullRowSelect = $true; MultiSelect = $false; Dock = 'Fill' }
[void]$list.Columns.Add('', 170)
[void]$list.Columns.Add('', 270)
$list.HeaderStyle = 'None'
foreach ($r in $rows) { [void]$list.Items.Add((New-Object Windows.Forms.ListViewItem(,[string[]]$r))) }
$list.Items[0].Selected = $true
$status = New-Object Windows.Forms.Label -Property @{ Text = 'Pick one and Copy.'; AutoSize = $true; Anchor = 'Left'; Margin = '6,8,6,0' }
$copy = New-Object Windows.Forms.Button -Property @{ Text = 'Copy' }
$close = New-Object Windows.Forms.Button -Property @{ Text = 'Close' }
$copyIt = {
  if ($list.SelectedItems.Count) {
    $v = $list.SelectedItems[0].SubItems[1].Text
    [Windows.Forms.Clipboard]::SetText($v)
    $status.Text = "Copied $v"
  }
}
$copy.Add_Click($copyIt)
$list.Add_DoubleClick($copyIt)
$close.Add_Click({ $form.Close() })
$bar = New-Object Windows.Forms.FlowLayoutPanel -Property @{ Dock = 'Bottom'; FlowDirection = 'RightToLeft'; AutoSize = $true; Padding = '4' }
$bar.Controls.AddRange(@($close, $copy, $status))
$form.Controls.AddRange(@($list, $bar))
$form.AcceptButton = $copy
$form.CancelButton = $close
$form.Add_Shown({ $form.Activate(); $list.Focus() })
[void]$form.ShowDialog()

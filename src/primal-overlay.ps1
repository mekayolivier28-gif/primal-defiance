# Primal Defiance - in-game companion overlay
# Windows PowerShell 5.1+
# External companion overlay only: it does not inject into, modify, or read game memory.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$StateFile = Join-Path $env:LOCALAPPDATA 'PrimalDefiance\state.json'
$PrototypePath = Join-Path $PSScriptRoot 'prototype-v4.html'

function Read-BridgeState {
    if (Test-Path $StateFile) {
        try { return (Get-Content $StateFile -Raw | ConvertFrom-Json) } catch {}
    }
    return [pscustomobject]@{ materials=0; hunts=0; toolCrafted=$false; evolutionPoints=0; upgrades=@() }
}

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = 'None'
$form.ShowInTaskbar = $false
$form.TopMost = $true
$form.StartPosition = 'Manual'
$form.Size = New-Object System.Drawing.Size(360,205)
$form.Location = New-Object System.Drawing.Point(([System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - 380),30)
$form.BackColor = [System.Drawing.Color]::FromArgb(18,22,18)
$form.Opacity = 0.92

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PRIMAL DEFIANCE  •  COMPANION'
$title.ForeColor = [System.Drawing.Color]::FromArgb(225,205,130)
$title.Font = New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(14,10)
$title.AutoSize = $true
$form.Controls.Add($title)

$status = New-Object System.Windows.Forms.Label
$status.ForeColor = [System.Drawing.Color]::White
$status.Font = New-Object System.Drawing.Font('Segoe UI',9)
$status.Location = New-Object System.Drawing.Point(14,38)
$status.Size = New-Object System.Drawing.Size(330,95)
$form.Controls.Add($status)

$hint = New-Object System.Windows.Forms.Label
$hint.Text = 'F8 hide/show  •  F9 open full tribe interface  •  Esc hide'
$hint.ForeColor = [System.Drawing.Color]::FromArgb(160,170,158)
$hint.Font = New-Object System.Drawing.Font('Segoe UI',8)
$hint.Location = New-Object System.Drawing.Point(14,174)
$hint.AutoSize = $true
$form.Controls.Add($hint)

function Get-SenseReport {
    $minute = [int][DateTime]::Now.Minute
    $reports = @(
        @('Sight: movement on the ridge.','Hearing: birds went quiet nearby.','Scent: fresh water and crushed leaves.'),
        @('Sight: a safe route crosses the valley.','Hearing: distant animal calls east.','Scent: predator trace, less than a day old.'),
        @('Sight: edible plants near the rocks.','Hearing: running water downhill.','Scent: another group may be nearby.'),
        @('Sight: your territory is open ahead.','Hearing: wind and insects only.','Scent: stone, vegetation and camp smoke.')
    )
    return $reports[$minute % $reports.Count]
}

function Refresh-Overlay {
    $s = Read-BridgeState
    $upgrades = @($s.upgrades) -join ', '
    if (-not $upgrades) { $upgrades = 'None' }
    $r = Get-SenseReport
    $status.Text = "SENSES`n  👁 $($r[0].Substring(8))`n  👂 $($r[1].Substring(10))`n  👃 $($r[2].Substring(8))`n`nTRIBE BRIDGE`n  Materials: $($s.materials)   Hunts: $($s.hunts)   Evolution XP: $($s.evolutionPoints)`n  Upgrades: $upgrades"
}

# Register global hotkeys through a small native helper. The overlay is non-activating/click-through.
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class PDNative {
  [DllImport("user32.dll")] public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
  [DllImport("user32.dll")] public static extern bool UnregisterHotKey(IntPtr hWnd, int id);
  [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
  [DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
  public const int GWL_EXSTYLE=-20; public const int WS_EX_TRANSPARENT=0x20; public const int WS_EX_LAYERED=0x80000; public const int WS_EX_NOACTIVATE=0x08000000;
  public const uint MOD_NOREPEAT=0x4000; public const uint VK_F8=0x77; public const uint VK_F9=0x78;
}
"@

$form.Add_Shown({
    $h = $form.Handle
    $style = [PDNative]::GetWindowLong($h,[PDNative]::GWL_EXSTYLE)
    [PDNative]::SetWindowLong($h,[PDNative]::GWL_EXSTYLE,($style -bor [PDNative]::WS_EX_TRANSPARENT -bor [PDNative]::WS_EX_LAYERED -bor [PDNative]::WS_EX_NOACTIVATE)) | Out-Null
    [PDNative]::RegisterHotKey($h,100,[PDNative]::MOD_NOREPEAT,[PDNative]::VK_F8) | Out-Null
    [PDNative]::RegisterHotKey($h,101,[PDNative]::MOD_NOREPEAT,[PDNative]::VK_F9) | Out-Null
    Refresh-Overlay
})

$form.Add_KeyDown({ if ($_.KeyCode -eq 'Escape') { $form.Hide() } })
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2500
$timer.Add_Tick({ if ($form.Visible) { Refresh-Overlay } })
$timer.Start()

# Process Windows messages for the hotkeys.
$nativeWindow = New-Object System.Windows.Forms.NativeWindow
$nativeWindow.AssignHandle($form.Handle)
[System.Windows.Forms.Application]::AddMessageFilter((New-Object PSMessageFilter($form)))

class PSMessageFilter : System.Windows.Forms.IMessageFilter {
    [System.Windows.Forms.Form] $Form
    PSMessageFilter([System.Windows.Forms.Form] $f) { $this.Form=$f }
    [bool] PreFilterMessage([ref] [System.Windows.Forms.Message] $m) {
        if ($m.Msg -eq 0x0312) {
            if ($m.WParam.ToInt32() -eq 100) { if ($this.Form.Visible) { $this.Form.Hide() } else { $this.Form.Show() } ; return $true }
            if ($m.WParam.ToInt32() -eq 101) { if (Test-Path $PrototypePath) { Start-Process -FilePath $PrototypePath }; return $true }
        }
        return $false
    }
}

Refresh-Overlay
[void]$form.ShowDialog()

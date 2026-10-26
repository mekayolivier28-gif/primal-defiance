# Primal Defiance - local bridge prototype
# Windows PowerShell 5.1+
# This prototype does NOT redistribute or modify either game. It detects local installs,
# stores mashup progression locally, and can launch the owned host game.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppDir = Join-Path $env:LOCALAPPDATA 'PrimalDefiance'
$StateFile = Join-Path $AppDir 'state.json'
$ConfigFile = Join-Path $AppDir 'config.json'
New-Item -ItemType Directory -Force -Path $AppDir | Out-Null

function Read-State {
    if (Test-Path $StateFile) {
        try { return (Get-Content $StateFile -Raw | ConvertFrom-Json) } catch {}
    }
    return [pscustomobject]@{ materials = 0; hunts = 0; toolCrafted = $false; evolutionPoints = 0; upgrades = @() }
}
function Save-State($s) { $s | ConvertTo-Json -Depth 5 | Set-Content -Encoding UTF8 $StateFile }

function Get-SteamLibraries {
    $roots = @()
    $steamRoots = @(
        'HKCU:\Software\Valve\Steam',
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
        'HKLM:\SOFTWARE\Valve\Steam'
    )
    foreach ($r in $steamRoots) {
        try {
            $p = Get-ItemProperty $r -ErrorAction Stop
            foreach ($v in @($p.SteamPath, $p.InstallPath)) { if ($v -and (Test-Path $v)) { $roots += $v } }
        } catch {}
    }
    $roots += @('C:\Program Files (x86)\Steam','C:\Program Files\Steam')
    $libs = New-Object System.Collections.Generic.List[string]
    foreach ($root in ($roots | Select-Object -Unique)) {
        if (Test-Path $root) {
            $libs.Add((Join-Path $root 'steamapps'))
            $vdf = Join-Path $root 'steamapps\libraryfolders.vdf'
            if (Test-Path $vdf) {
                $text = Get-Content $vdf -Raw
                foreach ($m in [regex]::Matches($text, '"path"\s*"([^"]+)"')) {
                    $path = $m.Groups[1].Value -replace '\\\\','\'
                    if (Test-Path $path) { $libs.Add((Join-Path $path 'steamapps')) }
                }
            }
        }
    }
    return $libs | Select-Object -Unique
}

function Find-Game($patterns) {
    foreach ($steamapps in Get-SteamLibraries) {
        if (-not (Test-Path $steamapps)) { continue }
        $common = Join-Path $steamapps 'common'
        if (-not (Test-Path $common)) { continue }
        foreach ($pattern in $patterns) {
            $dirs = Get-ChildItem $common -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $pattern }
            foreach ($d in $dirs) {
                $exe = Get-ChildItem $d.FullName -Filter *.exe -File -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -notmatch 'Crash|Prereq|EasyAntiCheat|Uninstall|Launcher' } |
                    Select-Object -First 1
                if ($exe) { return [pscustomobject]@{ Root=$d.FullName; Exe=$exe.FullName } }
            }
        }
    }
    return $null
}

function Find-Installations {
    $dawn = Find-Game @('*Dawn of Defiance*')
    $anc = Find-Game @('*Ancestors*Humankind*','*Ancestors*')
    return [pscustomobject]@{ Dawn=$dawn; Ancestors=$anc }
}

$state = Read-State
$installs = Find-Installations

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Primal Defiance — Prototype'
$form.Size = New-Object System.Drawing.Size(720,520)
$form.StartPosition = 'CenterScreen'

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PRIMAL DEFIANCE'
$title.Font = New-Object System.Drawing.Font('Segoe UI',22,[System.Drawing.FontStyle]::Bold)
$title.Location = New-Object System.Drawing.Point(24,18)
$title.AutoSize = $true
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = 'Dawn of Defiance host + Ancestors-inspired evolution progression'
$sub.Location = New-Object System.Drawing.Point(27,58)
$sub.AutoSize = $true
$form.Controls.Add($sub)

$status = New-Object System.Windows.Forms.TextBox
$status.Multiline = $true
$status.ReadOnly = $true
$status.ScrollBars = 'Vertical'
$status.Location = New-Object System.Drawing.Point(24,90)
$status.Size = New-Object System.Drawing.Size(650,175)
$form.Controls.Add($status)

function Refresh-Status {
    $script:installs = Find-Installations
    $dawnText = if ($script:installs.Dawn) { "FOUND`n$($script:installs.Dawn.Exe)" } else { 'NOT FOUND' }
    $ancText = if ($script:installs.Ancestors) { "FOUND`n$($script:installs.Ancestors.Root)" } else { 'NOT FOUND' }
    $status.Text = @"
Host — Dawn of Defiance: $dawnText

Companion — Ancestors: The Humankind Odyssey: $ancText

Local progression
Materials: $($script:state.materials)    Hunts: $($script:state.hunts)    Tool crafted: $($script:state.toolCrafted)
Evolution points: $($script:state.evolutionPoints)
Upgrades: $((@($script:state.upgrades) -join ', '))

No game assets are included. This prototype only inspects local installation paths and stores its own state.
"@
}

function Add-Button($text,$x,$y,$action) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Location = New-Object System.Drawing.Point($x,$y)
    $b.Size = New-Object System.Drawing.Size(200,42)
    $b.Add_Click($action)
    $form.Controls.Add($b)
}

Add-Button 'Rescan installed games' 24 285 { Refresh-Status }
Add-Button 'Gather starter resources' 240 285 {
    $script:state.materials += 3; Save-State $script:state; Refresh-Status
}
Add-Button 'Craft primitive tool' 456 285 {
    if ($script:state.materials -ge 3) { $script:state.materials -= 3; $script:state.toolCrafted = $true; Save-State $script:state; Refresh-Status }
    else { [System.Windows.Forms.MessageBox]::Show('Gather at least 3 materials first.') }
}
Add-Button 'Complete hunt / combat' 24 345 {
    if ($script:state.toolCrafted) { $script:state.hunts += 1; $script:state.evolutionPoints += 1; Save-State $script:state; Refresh-Status }
    else { [System.Windows.Forms.MessageBox]::Show('Craft the primitive tool first.') }
}
Add-Button 'Unlock evolution upgrade' 240 345 {
    if ($script:state.evolutionPoints -gt 0) {
        $script:state.evolutionPoints -= 1
        $script:state.upgrades = @($script:state.upgrades) + 'Primal Adaptation'
        Save-State $script:state; Refresh-Status
    } else { [System.Windows.Forms.MessageBox]::Show('Complete a hunt / combat encounter first.') }
}
Add-Button 'Launch Dawn of Defiance' 456 345 {
    if ($script:installs.Dawn -and (Test-Path $script:installs.Dawn.Exe)) {
        Start-Process -FilePath $script:installs.Dawn.Exe -WorkingDirectory $script:installs.Dawn.Root
    } else { [System.Windows.Forms.MessageBox]::Show('Dawn of Defiance was not detected in your Steam libraries.') }
}

$reset = New-Object System.Windows.Forms.Button
$reset.Text = 'Reset prototype progression'
$reset.Location = New-Object System.Drawing.Point(24,415)
$reset.Size = New-Object System.Drawing.Size(200,36)
$reset.Add_Click({ $script:state = [pscustomobject]@{ materials=0; hunts=0; toolCrafted=$false; evolutionPoints=0; upgrades=@() }; Save-State $script:state; Refresh-Status })
$form.Controls.Add($reset)

Refresh-Status
[void]$form.ShowDialog()

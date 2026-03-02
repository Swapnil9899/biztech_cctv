# PowerShell script to create Desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell

# Try different Desktop locations
$desktopPaths = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\OneDrive\Desktop"
)

$shortcutPath = $null
foreach ($path in $desktopPaths) {
    if (Test-Path $path) {
        $shortcutPath = Join-Path $path "Docker Desktop.lnk"
        break
    }
}

if ($null -eq $shortcutPath) {
    Write-Host "Could not find Desktop folder!"
    exit 1
}

$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "$env:USERPROFILE\OneDrive\Desktop\CCTV\start-dashboard.bat"
$Shortcut.WorkingDirectory = "$env:USERPROFILE\OneDrive\Desktop\CCTV"
$Shortcut.Description = "CCTV Productivity Dashboard Launcher"

try {
    $Shortcut.Save()
    Write-Host "Shortcut created successfully!"
    Write-Host "Location: $shortcutPath"
} catch {
    Write-Host "Error saving shortcut: $_"
    
    # Try alternative path
    $altPath = "$env:USERPROFILE\OneDrive\Desktop\Docker Desktop.lnk"
    $Shortcut = $WshShell.CreateShortcut($altPath)
    $Shortcut.TargetPath = "$env:USERPROFILE\OneDrive\Desktop\CCTV\start-dashboard.bat"
    $Shortcut.WorkingDirectory = "$env:USERPROFILE\OneDrive\Desktop\CCTV"
    $Shortcut.Description = "CCTV Productivity Dashboard Launcher"
    $Shortcut.Save()
    Write-Host "Shortcut created at alternative location: $altPath"
}

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("C:\Users\Swapnil\OneDrive\Desktop\Docker Desktop.lnk")
Write-Host "Target: $($Shortcut.TargetPath)"
Write-Host "WorkingDirectory: $($Shortcut.WorkingDirectory)"
Write-Host "Description: $($Shortcut.Description)"

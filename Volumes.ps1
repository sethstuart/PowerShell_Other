#Here yea go Seth
Get-Volume | where { $_.driveType -like "Fixed" -and $_.FileSystemLabel -notlike "System Reserved" }

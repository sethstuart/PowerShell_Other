#Here yea go Seth
Invoke-Command -ComputerName localhost -ScriptBlock{
  (Get-Volume | where { $_.driveType -like "Fixed" -and $_.FileSystemLabel -notlike "System Reserved" })
  }

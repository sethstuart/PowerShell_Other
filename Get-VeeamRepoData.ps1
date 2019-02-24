Param(
     [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
     [Array] $Computers,
     [Parameter(ValueFromPipeline=$true, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
     [ValidateNotNullOrEmpty()]
     [System.String] $Drive
)

Function Class-Size($size){

IF($size -ge 1TB)
	{
	"{0:n2}" -f  ($size / 1TB) + " TB"
	}
ELSEIF($size -ge 1GB)
	{
	"{0:n2}" -f  ($size / 1GB) + " GB"
	}
ELSEIF($size -ge 1MB)
	{
	"{0:n2}" -f  ($size / 1MB) + " MB"
	}
ELSE
	{
	"{0:n2}" -f  ($size / 1KB) + " KB"
	}
} 

function Get-DirFreeSize {
Param(
     $Drive,
     [Array]$Computers
) 
$RepoData = @()
$Path = $Drive + ":\Backups"
Foreach($Computer in $Computers){
	 $ErrorActionPreference = "SilentlyContinue"
	 #My current issue is that I need to be able to specify X number of drives and have each system output its information for the drives it owns out of the provided list. If a drive's Size, Free Space, and Used space are all == 0, do not include

     $VolumeInfo = Invoke-Command -ComputerName $Computer -ScriptBlock {
      #Here ya go Seth
	  (Get-Volume | where { $_.driveType -like "Fixed" -and $_.FileSystemLabel -notlike "System Reserved" }) #Thanks to Nick Hill to helping me with the sorting and selection logic!!
      }
	  
	  $Length = Invoke-Command -ComputerName $Computer -ScriptBlock {
      (Get-ChildItem $args[0] -Recurse | Measure-Object -Property Length -Sum).Sum
      } -ArgumentList $Path
     
	 $Result = "" | Select Computer,Drive,'Volume Label',Size,'Free Space','Used Space'
     $Result.Computer = $Computer
     $Result.Drive = $Drive + ':'
     $Result.'Volume Label' = $VolumeInfo.FileSystemLabel
     $Result.Size = Class-Size $VolumeInfo.Size
	 $Result.'Free Space' = Class-Size $VolumeInfo.SizeRemaining
     $Result.'Used Space' = Class-Size $Length
     $RepoData += $Result
	}
     
return $RepoData
}

$SystemList = get-content file.txt
$Computers = $SystemList.Split(',')
Get-DirFreeSize -Computers $Computers -Drive $Drive

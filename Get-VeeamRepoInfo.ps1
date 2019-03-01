Param(
     [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
     [Array] $Computers
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
     [Array]$Computers
) 
$RepoData = @()
Foreach($Computer in $Computers){
	 $ErrorActionPreference = "SilentlyContinue"

     $VolumeInfo = Invoke-Command -ComputerName $Computer -ScriptBlock {
      #Here ya go Seth
	  (Get-Volume | where { $_.driveType -like "Fixed" -and $_.FileSystemLabel -notlike "System Reserved" }) #Thanks to Nick Hill to helping me with the sorting and selection logic!!
         }
		$Computer 
	   for($a = 0; $a -lt $VolumeInfo.Count; $a++){
		  $TempRepoData = @()
		  $Result = "" | Select DriveLetter,FSLabel,Size,FreeSpace
	      $Result.DriveLetter = $VolumeInfo[$a].DriveLetter
	      $Result.FSLabel = $VolumeInfo[$a].FileSystemLabel
	      $Result.Size = Class-Size $VolumeInfo[$a].Size
	      $Result.FreeSpace = Class-Size $VolumeInfo[$a].SizeRemaining
	      $TempRepoData += $Result
		  
		  $TempRepoData
		   }
	 }
}

$SystemList = get-content file.txt
$Computers = $SystemList.Split(',')
Get-DirFreeSize -Computers $Computers
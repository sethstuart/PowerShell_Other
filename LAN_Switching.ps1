<#
.SYNOPSIS
Disable Wifi adapter when Ethernet is also connected.
.DESCRIPTION
Script checks if more than one active connection is present. If it finds more than one, it will disable the wireless connection. NOTE: Script ignores VMware 
.FUNCTIONALITY
Checkes for active physical ethernet connections. If it finds more than one, It will disable the wireless NIC.
.EXAMPLE
Scheduled task, or run manually.
#>


[boolean]$EthNICFound = $false
[boolean]$wifiNICFound = $false
for($i = 1; $i -lt 101; $i++ ) {for($j=0;$j -lt 100;$j++) {} write-progress "Enumerating networtk connections." -perc $i;
if(!$PhyConnectedNICs){
$PhyConnectedNICs = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.NetConnectionStatus -eq "2") -and ($_.Name -notLike "*virtual*") -and ($_.Name -like "*Intel(R)*")}
}}
    if ($PhyConnectedNICs.count -ge "2")
    {
        Write-Host "Identifying connected interfaces."
        for($i = 15; $i -lt 101; $i++ ) {for($j=0;$j -lt 100;$j++) {} write-progress "Identifying wired and wirelss connections." "% Complete:" -perc $i;
        if((!$EthNICFound) -and (!$EthNICFound)){
       $PhyConnectedNICs | %{
            if($_.NetConnectionID -eq "Local Area Connection"){
                $EthNICFound = $true
                Write-Host "Found Local Area Connection!"
                Start-Sleep -Milliseconds 1200
            }
            if($_.NetConnectionID -eq "Wireless Network Connection"){
                $wifiNICFound = $true
                $wifiNIC = $_
                Write-Host "Found Wireless Network Connection!"
                Start-Sleep -Milliseconds 1200
            }
       }
    }
}
    if(($EthNICFound) -and ($wifiNICFound)){
        for($i = 30; $i -lt 101; $i++ ) {for($j=0;$j -lt 100;$j++) {} write-progress "Disabling wireless connection." "% Complete:" -perc $i;
        if(!$WifiOff){
                
       $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.GUID -eq $wifiNIC.GUID)}
        
       $WifiOff = $wifiNIC.disable()
        }
        }
        if($WifiOff){
            write-host "Done!"
        }
    }
}

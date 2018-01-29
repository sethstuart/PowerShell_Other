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
$PhyConnectedNICs = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.NetConnectionStatus -eq "2") -and ($_.Name -notLike "*virtual*") -and ($_.Name -like "*Intel(R)*")}

    if ($PhyConnectedNICs.count -ge "2")
    {
       $PhyConnectedNICs | %{
            if($_.NetConnectionID -eq "Local Area Connection"){
                $EthNICFound = $true
            }
            if($_.NetConnectionID -eq "Wireless Network Connection"){
                $wifiNICFound = $true
                $wifiNIC = $_

            }
       }
    if(($EthNICFound) -and ($wifiNICFound)){
       $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.GUID -eq $wifiNIC.GUID)}
        $wifiNIC.disable()     
    }
}

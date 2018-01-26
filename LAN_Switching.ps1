[boolean]$EthNICFound = $false
[boolean]$wifiNICFound = $false
$PhyConnectedNICs = Get-WmiObject -Class win32_networkadapter -computer . | where{($_.NetConnectionStatus -eq "2") -and ($_.Name -notLike "vmware*") -and ($_.Name -like "*Intel*")}

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
    if(($EthNIC) -and ($wifiNIC)){
       $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | where{($_.GUID -eq $wifiNIC.GUID)}
        $wifiNIC.disable()     
    }
}
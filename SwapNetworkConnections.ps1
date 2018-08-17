<#
.SYNOPSIS
    Changes active network adapter on the system from ethernet to wifi or vice versa.
.DESCRIPTION
    Version:        1.0
    Creation Date:  08/17/2018
    Author:         Nick Hill
    Email:          ndhill@gmail.com
    https://github.com/ndhill84
.FUNCTIONALITY
The functionality that best describes this cmdlet
.EXAMPLE
.\lan_wan_switching.ps1

#>



#Set windows size
    $pshost = get-host
    $pswindow = $pshost.ui.rawui
    $newsize = $pswindow.buffersize
    $newsize.height = 3000
    $newsize.width = 150
    $pswindow.buffersize = $newsize

    $newsize = $pswindow.windowsize
    $newsize.height = 50
    $newsize.width = 150
    $pswindow.windowsize = $newsize

$MOTD = @"

 ____ ____ ____ ____ ____ ____ ____ ____ _______ ____ ____ ____ ____ ____ ____ ____ _______ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ ____ 
||S |||w |||a |||p |||p |||i |||n |||g |||     |||N |||e |||t |||w |||o |||r |||k |||     |||C |||o |||n |||n |||e |||c |||t |||i |||o |||n |||s ||
||__|||__|||__|||__|||__|||__|||__|||__|||_____|||__|||__|||__|||__|||__|||__|||__|||_____|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__|||__||
|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_____\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/_____\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|/__\|
"@
#ASCII Art from http://patorjk.com/software/taag/

function ActiveAdapter ()
{
        $Connected = Get-WmiObject -Class win32_networkadapterconfiguration -filter IPEnabled=TRUE -computer . | Where-Object{($_.DHCPEnabled -eq "TRUE") -and ($_.IPAddress)}
        
        Write-Host -ForegroundColor red ":::Active Network Adapter:::"
        write-host -ForegroundColor white "      Using: " -NoNewline
        write-host -ForegroundColor White $connected.Description
        write-host -ForegroundColor white " IP Address: " -NoNewline
        write-host -ForegroundColor white $Connected.IPAddress
        write-host -ForegroundColor white "     Domain: " -NoNewline
        write-host -ForegroundColor White $connected.DNSDomain
}
function Disable-wifi {
    [boolean]$EthNICFound = $false
    [boolean]$wifiNICFound = $false
    
    
    $PhyConnectedNICs = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object {($_.NetConnectionStatus -eq "2") -and ($_.Name -notLike "vmware*") -and ($_.Name -like "*Intel*")}
    
        if ($PhyConnectedNICs.count -ge "2")
        {
           $PhyConnectedNICs | ForEach-Object{
                if($_.NetConnectionID -eq "Local Area Connection"){
                    $EthNICFound = $true
                }
                if($_.NetConnectionID -eq "Wireless Network Connection"){
                    $wifiNICFound = $true
                    $wifiNIC = $_
    
                }
           }
        } else {
            write-host "Only one Connected NIC found. Nothing to do."
            write-host "Exiting."
            exit
        }
    
        if(($EthNICFound) -and ($wifiNICFound))
        {
            $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.GUID -eq $wifiNIC.GUID)}
            write-host "Found two connected physical NICs..." 
            write-host "Disabling " -NoNewLine
            write-host -ForegroundColor Red $WifiNIC.Name  -NoNewline
            write-host " Wifi Adapter "
    
            $disabled = $wifiNIC.disable()
    
            $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object{($_.GUID -eq $wifiNIC.GUID)}
            if ($WifiNIC.NetConnectionStatus -eq "0")
            {
                write-host "Successfully Disabled " -NoNewline
                write-host -ForegroundColor Red $WifiNIC.NetConnectionID -NoNewline
                write-host -ForegroundColor White " (" $WifiNIC.Name ")"
            }
            ActiveAdapter
        }

}

function Enable-wifi {

    $WifiNIC = Get-WmiObject -Class win32_networkadapter -computer . | where {($_.Name -Like "*Wireless*")}

    if ($WifiNIC.NetConnectionStatus -eq "2") {
        write-host "Wifi network adapter " -NoNewline
        write-host -ForegroundColor Red $WifiNIC.Name  -NoNewline
        write-host " is already connected. Nothing to do."
        Write-Host "Exiting..."
        exit
    }
    else {
        write-host "Enabling " -NoNewline
        write-host -ForegroundColor Red $WifiNIC.Name
        $enabled = $wifinic.Enable()
        start-sleep -Seconds 2
        Write-host "Searchingh for Wireless Networks...."
        $ssidoutput = netsh.exe wlan show all
        $RawSSID = $ssidoutput | select-string -Pattern "SSID 1 : "
        $ssid = ($RawSSID -split ": ")[-1]
        Write-host "Connecting to " -NoNewline; write-host -ForegroundColor red $ssid
        start-sleep -Seconds 4
        $enabledNic = Get-WmiObject -Class win32_networkadapter -computer . | Where-Object {($_.GUID -eq $wifiNIC.GUID)}
        if ($enabledNic.NetConnectionStatus -eq "2") {
            write-host "Adapter successfully enabled and connected!"
        }
        else {
            write-host "Something didn't go write. Check your adapter and try again."
        }
    }

}


Write-Host $MOTD

$NICs = Get-WmiObject -Class win32_networkadapter -computer .
$wlan = $NICs | Where-Object{$_.name -like "Intel(R)*Wireless*" }
$lan = $NICs | Where-Object {$_.name -like "Intel(R) Ethernet Connection*"}

If (($wlan.NetConnectionStatus -eq 0 -and $wlan.PhysicalAdapter -eq $true) -or ($wlan.NetConnectionStatus -eq 4 -and $lan.NetConnectionStatus -eq 7)){
    Enable-wifi

}
if($wlan.NetConnectionStatus -eq 2) {
    Disable-Wifi

}
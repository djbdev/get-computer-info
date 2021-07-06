<#
    Use this script to get quick info on a computer using wmi cmdlets 
    Just specify the comp name and run script.
#>
#---------------------------------------------------------------------------------------------------#
    # Request the computer to check
    $comp = Read-Host "Enter device name to check"

    # Get details
    $manufacturer = Get-WmiObject -ComputerName $comp -class win32_computersystem | Select-Object -ExpandProperty manufacturer
    $model = Get-WmiObject -class win32_computersystem -ComputerName $comp | Select-Object -ExpandProperty model
    $serial = Get-WmiObject -class win32_bios -ComputerName $comp | Select-Object -ExpandProperty SerialNumber
    $os = Get-WmiObject -class Win32_OperatingSystem -ComputerName $comp | Select-Object CSName,Caption,Version,OSArchitecture,LastBootUptime
    $cpu = Get-WmiObject -class Win32_Processor -ComputerName $comp | Select-Object -ExpandProperty DataWidth
    $memory = Get-WmiObject -class cim_physicalmemory -ComputerName $comp | Select-Object Capacity | ForEach-Object{($_.Capacity / 1024kb)}
    $distName = Get-ADComputer -Filter "Name -like '$comp'" | Select-Object -ExpandProperty DistinguishedName
    $boot=[System.DateTime]::ParseExact($($os.LastBootUpTime).Split(".")[0],'yyyyMMddHHmmss',$null)
    [TimeSpan]$uptime = New-TimeSpan $boot $(get-date)
    
    # Pass the retrieved os version, depending on version, format as build number
    switch($os.Version){
        '10.0.10240'{$osbuild="1507"}
        '10.0.10586'{$osbuild="1511"}
        '10.0.14393'{$osbuild="1607"}
        '10.0.15063'{$osbuild="1703"}
        '10.0.16299'{$osbuild="1709"}
        '10.0.17134'{$osbuild="1803"}
        '10.0.17686'{$osbuild="1809"}
        '10.0.17763'{$osbuild="1809"}
        '10.0.18363'{$osbuild="1909"}
        }

    # Write results to console
    Write-Host "`n************ Info for Computer: $comp ************`r"
    Write-Host "* Hostname from WMI`: $($os.CSName)"
    Write-Host "* $distName"
    Write-Host "* $manufacturer $model SN`:$serial"
    Write-Host "* $($os.Caption) $osbuild $($os.OSArchitecture) $($os.Version)"
    Write-Host "* CPU Architecture: $cpu"
    Write-Host "* Memory: $memory"
    Write-Host "* Uptime`: $($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
    Write-Host "***********************************************`n"

#---------------------------------------------------------------------------------------------------#
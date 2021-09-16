Function Get-VolumeInfoOnPipeline
{
    <#
        .Synopsis
            Adds Volume Info Columns to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an iput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input so that it can be piped
            to the next function to add another column

            Columns returned are a subset of Win32_Volume

            Adds rows as needed. One per drive after the first (usually c:)

            By default, each new row gets a copy of all the data in the non Volume columns. This allows
            for filtering with Where-Object.
        .EXAMPLE
            Get-ServerCollection |
                Test-ServerConnectionOnPipeline |
                Get-ProcInfoOnPipeline |
                Get-VolumeInfoOnPipeline |
                Select-Object ComputerName,TotalProcs,ProcName,Cores,Volumes,DriveType,Capacity,PctFree |
                Format-Table -autosize

            A Sampling of Functions and Columns
        .EXAMPLE
            Get-ServerCollection |
                Test-ServerConnectionOnPipeline |
                Get-ProcInfoOnPipeline |
                Get-VolumeInfoOnPipeline |
                Select-Object ComputerName,TotalProcs,Cores,Volumes,DriveType,Capacity,PctFree |
                Where-Object PctFree -gt 95 |
                Format-Table -autosize

            Gets all of the drives either over or under a threshold. IN this case % free greater than 95%
        .EXAMPLE
            Get-ServerCollection |
                Test-ServerConnectionOnPipeline |
                Get-OSCaptionOnPipeline |
                Get-TimeZoneOnPipeline |
                Get-TotalMemoryOnPipeline |
                Get-MachineModelOnPipeline |
                Get-ProcInfoOnPipeline |
                Get-VolumeInfoOnPipeline |
                Select-Object ComputerName,OSVersion,TotalMemory,MachineModel,TotalProcs,ProcName,Cores,Volumes,DriveType,Capacity,PctFree |
                Where-Object DriveType -eq 3 |
                Export-Csv -path .\ServerSpecs.csv -NoTypeInformation

            Gets a nice specs report and outputs it to a CSV file in the working directory
    #>
    [CmdletBinding()]

    Param (
        [parameter(
        Mandatory=$true,
        ValueFromPipeline= $true)]
        $ComputerProperties,
        [switch]
        $NoErrorCheck
    )

    Process {
        $ComputerProperties | Out-Null
        $NoErrorCheck | Out-Null
        $PSItem | Select-Object *, Volumes, DriveType, Capacity, PctFree | ForEach-Object {
            If (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.WMI))) {
                $Volumes = Get-CimInstance -ComputerName $PSItem.ComputerName -Query "Select DriveLetter,DriveType,Capacity,FreeSpace from Win32_Volume"
                $PSItem.Volumes = $PSItem.DriveType = $PSItem.Capacity = $PSItem.PctFree = $null
                $PSItem.Volumes = $Volumes[0].DriveLetter
                $PSItem.DriveType = $Volumes[0].DriveType
                $PSItem.Capacity = [Math]::Round(($Volumes[0].Capacity / 1GB), 0)
                If (($null -eq $Volumes[0].Capacity) -or ($Volumes[0].Capacity -eq 0)) {
                    $PSItem.PctFree = $null
                } else {
                    $PSItem.PctFree = [Math]::Round($Volumes[0].FreeSpace/$Volumes[0].Capacity*100,1)
                }
                $PSItem

                $Count = ($Volumes | Measure-Object).Count

                If ($Count -gt 1){
                    For ($i=1; $i -le $Count-1; $i++) {
                        $PSItem.Volumes = $PSItem.DriveType = $PSItem.Capacity = $PSItem.PctFree = $null
                        $PSItem.Volumes = $Volumes[$i].DriveLetter
                        $PSItem.DriveType = $Volumes[$i].DriveType
                        $PSItem.Capacity = [Math]::Round(($Volumes[$i].Capacity / 1GB), 0)
                        If (($null -eq $Volumes[$i].Capacity) -or ($Volumes[$i].Capacity -eq 0)) {
                            $PSItem.PctFree = $null
                        } else {
                            $PSItem.PctFree = [Math]::Round($Volumes[$i].FreeSpace/$Volumes[$i].Capacity*100,1)
                        }
                        New-Object PsObject $PSItem
                    }
                }
            } Else {
                $PSItem.Volumes = 'No Try'
                $PSItem.Capacity = 'No Try'
                $PSItem.DriveType = 'No Try'
                $PSItem.PctFree = 'No Try'
                $PSItem
            }
        }
    }
}
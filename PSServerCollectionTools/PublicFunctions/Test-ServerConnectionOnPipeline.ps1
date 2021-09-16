Function Test-ServerConnectionOnPipeline
{
    <#
        .Synopsis
            Runs availability checks on servers
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an imput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input so that it can be piped
            to the next function to add another column.
            Makes both a WMI and PS Remote call

            This takes an object with .ComputerName as one of its properties because it is adding
            columns to that object and then passing it along to the next cmdlet. If the most
            convenient input is a list of stings such as from a text file or the output of an AD Call
            then use Get-ServerObjectCollection to create an object from the list.

            The data gathering cmdlets in this module assume by default that this cmdlet will be called
            and will not return information if the required protocol test fails. That is, if the server
            fails to ping, the cmdlet to get the OS version will not even try. Each cmdlet has a
            -NoError switch that can be used to omit the availability check
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | ft

            Will test network, WMI and PSRemote availability of each server in the collection.
        .EXAMPLE
            ('Server2','Server4') | Get-ServerObjectCollection | Test-ServerConnectionOnPipeline | ft

            See Get-Help Get-ServerObjectCollection -examples for more
        .EXAMPLE
            Get-ServerCollection | Get-TimeZoneOnPipeline -NoErrorCheck

            Gets the Timezone for all servers in the collection, but does not check the server
            availability first.
    #>

    [CmdletBinding()]

    Param (
        [parameter(
        Mandatory=$true,
        ValueFromPipeline=$true)]
        $ComputerProperties
    )
    Begin
        {}
    Process {
        $ComputerProperties | Select-Object *, Ping, WMI, PSRemote, BootTime | ForEach-Object {
            # Test Ping
            $PSItem.Ping = Test-Connection -ComputerName $ComputerProperties.ComputerName -Quiet -Count 1

            If ($PSItem.Ping) {
                # Calling WMI in a wrapper in order to isolate the error condition if it occurs
                $os = Get-WMI_OS -ComputerName $ComputerProperties.ComputerName
                # $os = Get-Wmiobject -ComputerName $ComputerProperties.ComputerName -Class Win32_OperatingSystem -ErrorAction Stop

                If ($null -ne $os)
                    {
                    # This conversion not necessare with ciminstance?
                    # $PSItem.BootTime = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
                    $PSItem.BootTime = $os.LastBootUpTime
                    $PSItem.WMI = $true
                    }
                Else
                    {
                    $PSItem.WMI = $false
                    $PSItem.BootTime = 'No Try'
                    }

                # Test PS Remoting
                $ps = Get-PSRemoteComputerName -ComputerName $ComputerProperties.ComputerName
                # $Result = Invoke-Command -ComputerName $ComputerProperties.ComputerName -ScriptBlock {$env:COMPUTERNAME} -ErrorAction Stop

                If ($null -ne $ps)
                    {$PSItem.PSRemote = $true}
                Else
                    {$PSItem.PSRemote = $false}
            }
        $PSItem
        }
    }
}
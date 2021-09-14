Function Get-TimeZoneOnPipeline
{
    <#
        .Synopsis
             Adds a TimeZone Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an imput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input (hopefully) so that it can be piped
            to the next function to add another column

            Uses PowerShell Remoting

            Requires Input object with Boolean Ping and PSRemote properties. Will only try to get value
            if both are true
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-TimeZoneOnPipeline | ft
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-TimeZoneOnPipeline | Select ComputerName,TimeZone | ft -AutoSize
        .EXAMPLE
            $env:COMPUTERNAME | Get-RCServerObjectCollection | Get-RCTimeZoneOnPipeline -NoErrorCheck

            Since it is checking the local server, there is no need to test the connection
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
        $NoErrorCheck | Out-Null

        $ComputerProperties | Select-Object *, TimeZone | ForEach-Object {
            If ($PSItem.ComputerName -eq $Env:COMPUTERNAME)
            {
                # "Localhost!"
                $PSItem.TimeZone = (Get-ItemProperty -Path 'HKLM:\system\CurrentControlSet\control\TimeZoneInformation'`
                     -Name TimeZoneKeyName).TimeZoneKeyName
            }

            elseIf (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.PSRemote)))
                {
                $PSItem.TimeZone = $null

                $sb = {(Get-ItemProperty -Path 'HKLM:\system\CurrentControlSet\control\TimeZoneInformation'`
                     -Name TimeZoneKeyName).TimeZoneKeyName}
                $PSItem.TimeZone = Invoke-Command -ComputerName $PSItem.ComputerName -ScriptBlock $sb
                }
            else {$PSItem.TimeZone = 'No Try'}
            $PSItem
        }
    }
}
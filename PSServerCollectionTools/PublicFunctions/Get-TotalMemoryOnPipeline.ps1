Function Get-TotalMemoryOnPipeline {
    <#
        .Synopsis
            Adds a TotalMemory Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an imput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input (hopefully) so that it can be piped
            to the next function to add another column
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-TimeZoneOnPipeline | Get-TotalMemoryOnPipeline | ft
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
        $ComputerProperties | Select-Object *, TotalMemory | ForEach-Object {
            If (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.WMI)))
                {
                $PSItem.TotalMemory = [string](Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $PSItem.ComputerName |
                    Measure-Object -Property capacity -Sum |
                    ForEach-Object {[Math]::Round(($PSItem.sum / 1GB),2)}) + ' GB'
                }
            Else{$PSItem.TotalMemory = 'No Try'}
            $PSItem
        }
    }
}
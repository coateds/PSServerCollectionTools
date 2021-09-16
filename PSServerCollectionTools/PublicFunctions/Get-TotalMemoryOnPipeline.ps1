Function Get-TotalMemoryOnPipeline {
    <#
        .Synopsis
            Adds a TotalMemory Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an input object
            but just about any collection of objects that exposes .ComputerName should work. Alternately,
            A simple list of stings can be converted to the appropriate object with the
            Get-ServerObjectCollection cmdlet.

            The output is the same type of object as the input so that it can be piped to the next
            function to add another column. The output can also filtered and selected using Where-Object
            and Select-Object. Out-GridView also makes a very useful output.
        .EXAMPLE
            Get-ServerCollection |
                Test-ServerConnectionOnPipeline |
                Get-TimeZoneOnPipeline |
                Get-TotalMemoryOnPipeline |
                Format-Table
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
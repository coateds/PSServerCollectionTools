Function Get-MachineModelOnPipeline
{
    <#
        .Synopsis
            Adds a MachineModel Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an input object
            but just about any collection of objects that exposes .ComputerName should work. Alternately,
            A simple list of stings can be converted to the appropriate object with the
            Get-ServerObjectCollection cmdlet.

            The output is the same type of object as the input so that it can be piped to the next
            function to add another column. The output can also filtered and selected using Where-Object
            and Select-Object. Out-GridView also makes a very useful output.

            Makes a call to WMI and requires the an input object with Boolean Ping and WMI properties.
            Will only try to get value if both are true or if the -NoErrorCheck switch is used.
        .EXAMPLE
            Get-ServerCollection |
                Test-ServerConnectionOnPipeline |
                Get-TimeZoneOnPipeline |
                Get-TotalMemoryOnPipeline |
                Get-MachineModelOnPipeline | ft
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

    Begin
        {}
    Process {
        $NoErrorCheck | Out-Null
        $ComputerProperties | Select-Object *, MachineModel | ForEach-Object {
            If (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.WMI)))
                {
                $PSItem.MachineModel = [string](Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $PSItem.ComputerName).Model
                }
            Else{$PSItem.MachineModel = 'No Try'}
            $PSItem
        }
    }
}
Function Get-WMI_OS
{
    <#
        .Synopsis
            Simple Private Function to test WMI connectivity on a remote machine
        .DESCRIPTION
            Simple Private Function to test WMI connectivity on a remote machine
            moving the Try...Catch block into isolation helps prevent any errors on the console
            Return is the WMI OS object when sucessfully connects, Null when it does not
        .EXAMPLE
            Get-WMI_OS -ComputerName "Server1"
    #>

    [CmdletBinding()]

    Param (
        [string]$ComputerName
    )

    Try {
        # Get-Wmiobject -ComputerName $ComputerName -Class Win32_OperatingSystem -ErrorAction Stop
        Get-CimInstance -ComputerName $ComputerName -ClassName Win32_OperatingSystem -ErrorAction Stop
    }
    Catch {$null}
}

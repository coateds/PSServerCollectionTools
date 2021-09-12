Function Get-PSRemoteComputerName
{
    <#
        .Synopsis
            Simple Private Function to test PS Remote connectivity
        .DESCRIPTION
            Simple Private Function to test PS Remote connectivity on a remote machine
            moving the Try...Catch block into isolation helps prevent any errors on the console
            Return is the the remote computer's name when sucessfully connects, Null when it does not.
        .EXAMPLE
            Get-PSRemoteComputerName "Server1"
    #>

    [CmdletBinding()]

    Param (
        [string]$ComputerName
    )

    Try {Invoke-Command -ComputerName $ComputerName -ScriptBlock {1} -ErrorAction Stop}
    Catch {$null}
}
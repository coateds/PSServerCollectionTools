Function Get-ServerCollection
{
    <#
        .Synopsis
            Gets a (filtered) list of servers from a CSV File
        .DESCRIPTION
            This is the primary cmdlet for this module. It imports a .csv file
            and uses the resultant PS Custom Object as a starting point for adding
            new columns. Often the next cmdlet in the pipe line will be
            Test-ServerConnectionOnPipeline to verify the server (ComputerName)
            in on the network and can be contacted by various protocols

            The parameters are both optional.
            Leaving one blank applies no filter for that parameter.
            Parameter validation is used to provide tab completion for rapid Ad Hoc use

            If there is another collection of ComputerNames available more convenient
            than a .csv file such as Active Directory or a .txt file, use
            Get-ServerObjectCollection

            After that call any one of the cmdlets that return information about each server
        .EXAMPLE
            Get-MyServerCollection
            Returns everything
        .EXAMPLE
            Get-MyServerCollection -Role Web
            Returns all of the Web Servers
        .EXAMPLE
            Get-MyServerCollection -Role SQL -Location WA
            Returns the SQL Servers in Washington
        .EXAMPLE
            Get-MyServerCollection -Role SQL | Test-ServerConnectionOnPipeline
            Returns all of the SQL servers and their availability on the network
        .EXAMPLE
            Get-MyServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline
            Gets OS Version of all servers
    #>

    [CmdletBinding()]

    Param (
        [ValidateSet("Web", "SQL", "DC")]
        [string]$Role,
        [ValidateSet("AZ", "WA")]
        [string]$Location
    )

    $ScriptPath = $PSScriptRoot
    $ComputerNames = '..\Servers.csv'

    If ($Role -ne "")  {$ModRole = $Role}
       Else {$ModRole = "*"}
    If ($Location -ne "")  {$ModLocation = $Location}
       Else {$ModLocation = "*"}

    $Return = Import-Csv -Path "$ScriptPath\$ComputerNames"  |
        Where-Object {($_.Role -like $ModRole) -and ($_.Location -like $ModLocation)}

    Return $Return
}
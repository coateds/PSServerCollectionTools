Function Get-ServerCollection
{
    <#
        .Synopsis
            Gets a (filtered) list of servers from a CSV File
        .DESCRIPTION
            The parameters are both optional.
            Leaving one blank applies no filter for that parameter.
        .EXAMPLE
            Get-MyServerCollection
            Returns everything
        .EXAMPLE
            Get-MyServerCollection -Role Web
            Returns all of the Web Servers
        .EXAMPLE
            Get-MyServerCollection -Role SQL -Location WA
            Returns the SQL Servers in Washington
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
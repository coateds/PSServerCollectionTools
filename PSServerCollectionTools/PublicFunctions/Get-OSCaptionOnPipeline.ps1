Function Get-OSCaptionOnPipeline
{
    <#
        .Synopsis
            Adds an OSVersion Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an input object
            but just about any collection of objects that exposes .ComputerName should work. Alternately,
            A simple list of stings can be converted to the appropriate object with the
            Get-ServerObjectCollection cmdlet.

            The output is the same type of object as the input so that it can be piped to the next
            function to add another column. The output can also filtered and selected using Where-Object
            and Select-Object. Out-GridView also makes a very useful output.

            Makes a call to WMI and requires the an input object with Boolean Ping and WMI properties.
            Will only try to get value if both are true or if the -NoErrorCheck switch is used
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline | Out-GridView

            Returns OS Version for all servers in the list that are available in a GUI output.
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline | Select-Object ComputerName, OSVersion | ft -AutoSize

            For a more concise output
        .EXAMPLE
            Get-ServerCollection | Get-OSCaptionOnPipeline -NoErrorCheck

            Omits the availability check, attempts to get OS Version even if the server does not respond to
            ping or WMI.
    #>
    [CmdletBinding()]

    Param (
        [parameter(
        Mandatory=$true,
        ValueFromPipeline=$true)]
        $ComputerProperties,

        [switch]
        $NoErrorCheck
    )
    Begin
        {}
    Process {
        $NoErrorCheck | Out-Null
        $ComputerProperties | Select-Object *, OSVersion | ForEach-Object {
            If (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.WMI))) {
                $ArrOSCaption = $OSCaption = $PSItem.OSVersion = $Version = $R2 = $null

                $OSCaption = (Get-CimInstance -ComputerName $PSItem.ComputerName -ClassName Win32_OperatingSystem).Caption
                $ArrOSCaption = $OSCaption.Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries)

                Foreach ($Item in $ArrOSCaption)
                    {
                    If ($Item -eq 'R2'){$R2 = 'R2'}

                    Try
                        {$Version = [int]$Item}
                    Catch{''}
                    }

                $PSItem.OSVersion = "$Version $R2"
                }
            Else{$PSItem.OSVersion = 'No Try'}
            $PSItem
        }
    }
}


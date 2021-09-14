Function Get-OSCaptionOnPipeline
{
    <#
        .Synopsis
            Adds an OSVersion Column to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an imput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input (hopefully) so that it can be piped
            to the next function to add another column
            Makes a call to WMI
            Requires Input object with Boolean Ping and WMI properties. Will only try to get value
            if both are true
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline | Out-GridView
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline | Select ComputerName, OSVersion | ft -AutoSize
            For a more concise output
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


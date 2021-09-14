Function Get-ProcInfoOnPipeline
{
    <#
        .Synopsis
            Adds ProcInfo (Physical) Columns to an object
        .DESCRIPTION
            This typically takes an imported csv file with a ComputerName Column as an imput object
            but just about any collection of objects that exposes .ComputerName should work
            The output is the same type of object as the input (hopefully) so that it can be piped
            to the next function to add another column
            Columns returned are a subset of Win32_Processor
        .EXAMPLE
            Get-ServerCollection | Test-ServerConnectionOnPipeline | Get-OSCaptionOnPipeline | Get-TimeZoneOnPipeline | Get-TotalMemoryOnPipeline | Get-MachineModelOnPipeline | Get-ProcInfoOnPipeline | Select ComputerName,BootTime,OSVersion,TimeZone,TotalMemory,MachineModel,TotalProcs,ProcName,Cores,DataWidth | ft
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
        $ComputerProperties | Select-Object *, TotalProcs, ProcName, Cores, DataWidth | ForEach-Object {
            If (($NoErrorCheck) -or (($PSItem.Ping) -and ($PSItem.WMI))) {
                # Note forcing $Proc to an array solves the problem of
                # only one processor returns a single object and not an
                # array with a single element
                $Proc = @(Get-CimInstance -computername $PSItem.ComputerName -ClassName win32_Processor)
                $PSItem.TotalProcs = $Proc.count
                $PSItem.ProcName = $Proc[0].Name
                $PSItem.Cores = $Proc[0].NumberOfCores
                $PSItem.DataWidth = $Proc[0].DataWidth
            }
            Else {
                $PSItem.TotalProcs = 'No Try'
                $PSItem.ProcName = 'No Try'
                $PSItem.Cores = 'No Try'
                $PSItem.DataWidth = 'No Try'
            }
            $PSItem
        }
    }
}
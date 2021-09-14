# No Content Yet

Set-StrictMode -Version Latest

$PublicFunctions = Get-ChildItem -Path $PSScriptRoot\PublicFunctions\*.ps1

foreach ($import in $PublicFunctions) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

$PrivateFunctions = Get-ChildItem -Path $PSScriptRoot\PrivateFunctions\*.ps1

foreach ($import in $PrivateFunctions) {
    try {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    } catch {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

foreach ($file in $PublicFunctions) {
    Export-ModuleMember -Function $file.BaseName
}
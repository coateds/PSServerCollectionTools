Describe 'Get-MyServerCollection Tests' {
    Context 'Output Tests' {
        BeforeAll {
            Import-Module "$PSScriptRoot\..\PSServerCollectionTools\PSServerCollectionTools.psm1" -Force
            
            $Actual = Get-ServerCollection -Role SQL -Location WA

            $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Out-Null
        }

        It 'Should return a custom object' {
            $Actual | Should -BeOfType PSCustomObject
        }

        It 'Should have ComputerName Property' {
            $MemberArray | Should -Contain 'ComputerName'
            $MemberArray | Should -Contain 'Role'
            $MemberArray | Should -Contain 'Location'
        }
    }
}
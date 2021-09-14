Describe 'Get-RCTotalMemoryOnPipeline.Tests' {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\PSServerCollectionTools\PSServerCollectionTools.psm1" -Force
        Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
            return (
                [PSCustomObject]@{capacity = 21610102784},
                [PSCustomObject]@{capacity = 4160749568}
            )
        }
    }

    Context 'Output Test - No Error Checking' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
            }
            $obj | Out-Null
        }

        It 'Should have 24 GB of Memory' {
            ($obj | Get-TotalMemoryOnPipeline -NoErrorCheck).TotalMemory | Should -Be '24 GB'
        }

        It 'Should return a custom object' {
            $obj | Get-TotalMemoryOnPipeline -NoErrorCheck | Should -BeOfType PSCustomObject
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TotalMemoryOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalMemory'
        }
    }

    Context 'Output Test - Conn Test Pass' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $true
                WMI = $true
            }
            $obj | Out-Null
        }

        It 'Should have 24 GB of Memory' {
            ($obj | Get-TotalMemoryOnPipeline).TotalMemory | Should -Be '24 GB'
        }

        It 'Should return a custom object' {
            $obj | Get-TotalMemoryOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TotalMemoryOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalMemory'
        }
    }

    Context 'Output Test - Conn Test Fail (Ping)' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $false
                WMI = $true
            }
            $obj | Out-Null
        }

        It 'Should have 24 GB of Memory' {
            ($obj | Get-TotalMemoryOnPipeline).TotalMemory | Should -Be 'No Try'
        }

        It 'Should return a custom object' {
            $obj | Get-TotalMemoryOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TotalMemoryOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalMemory'
        }
    }

    Context 'Output Test - Conn Test Fail (WMI)' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $true
                WMI = $false
            }
            $obj | Out-Null
        }

        It 'Should have 24 GB of Memory' {
            ($obj | Get-TotalMemoryOnPipeline).TotalMemory | Should -Be 'No Try'
        }

        It 'Should return a custom object' {
            $obj | Get-TotalMemoryOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TotalMemoryOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalMemory'
        }
    }
}
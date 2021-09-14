Describe 'Get-ProcInfoOnPipeline.Tests Single Proc' {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\PSServerCollectionTools\PSServerCollectionTools.psm1" -Force
    
        Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
            return (
                [PSCustomObject]@{
                    TotalProcs = $null
                    Name = 'MyProcName'
                    NumberOfCores = 16
                    Datawidth = 64
                }
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

        It 'Should have 1 proc' {
            ($obj | Get-ProcInfoOnPipeline -NoErrorCheck).TotalProcs | Should -Be 1
        }

        It 'Should be of ProcName MyProcName' {
            ($obj | Get-ProcInfoOnPipeline -NoErrorCheck).ProcName | Should -Be 'MyProcName'
        }

        It 'Should have 16 cores' {
            ($obj | Get-ProcInfoOnPipeline -NoErrorCheck).Cores | Should -Be 16
        }

        It 'Should be 64 bit' {
            ($obj | Get-ProcInfoOnPipeline -NoErrorCheck).DataWidth | Should -Be 64
        }

        It 'Should return a custom object' {
            $obj | Get-ProcInfoOnPipeline -NoErrorCheck | Should -BeOfType PSCustomObject
        }

        It 'Should have 4 new properties' {
            $MemberArray = $obj | Get-ProcInfoOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalProcs'
            $MemberArray | Should -Contain 'ProcName'
            $MemberArray | Should -Contain 'Cores'
            $MemberArray | Should -Contain 'DataWidth'
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
        
        It 'Should have 1 proc' {
            ($obj | Get-ProcInfoOnPipeline).TotalProcs | Should -Be 1
        }
        
        It 'Should be of ProcName MyProcName' {
            ($obj | Get-ProcInfoOnPipeline).ProcName | Should -Be 'MyProcName'
        }

        It 'Should have 16 cores' {
            ($obj | Get-ProcInfoOnPipeline).Cores | Should -Be 16
        }

        It 'Should be 64 bit' {
            ($obj | Get-ProcInfoOnPipeline).DataWidth | Should -Be 64
        }

        It 'Should return a custom object' {
            $obj | Get-ProcInfoOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 4 new properties' {
            $MemberArray = $obj | Get-ProcInfoOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalProcs'
            $MemberArray | Should -Contain 'ProcName'
            $MemberArray | Should -Contain 'Cores'
            $MemberArray | Should -Contain 'DataWidth'
        }
    }

    Context 'Output Test - Conn Test Fail (Ping)'  {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $false
                WMI = $true
            }
            $obj | Out-Null
        }

        It 'Should have not tried TotalProcs' {
            ($obj | Get-ProcInfoOnPipeline).TotalProcs | Should -Be 'No Try'
        }

        It 'Should have not tried ProcName' {
            ($obj | Get-ProcInfoOnPipeline).ProcName | Should -Be 'No Try'
        }

        It 'Should have not tried cores' {
            ($obj | Get-ProcInfoOnPipeline).Cores | Should -Be 'No Try'
        }

        It 'Should have not tried DataWidth' {
            ($obj | Get-ProcInfoOnPipeline).DataWidth | Should -Be 'No Try'
        }

        It 'Should return a custom object' {
            $obj | Get-ProcInfoOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 4 new properties' {
            $MemberArray = $obj | Get-ProcInfoOnPipeline | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalProcs'
            $MemberArray | Should -Contain 'ProcName'
            $MemberArray | Should -Contain 'Cores'
            $MemberArray | Should -Contain 'DataWidth'
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

        It 'Should have not tried TotalProcs' {
            ($obj | Get-ProcInfoOnPipeline).TotalProcs | Should -Be 'No Try'
        }

        It 'Should have not tried ProcName' {
            ($obj | Get-ProcInfoOnPipeline).ProcName | Should -Be 'No Try'
        }

        It 'Should have not tried cores' {
            ($obj | Get-ProcInfoOnPipeline).Cores | Should -Be 'No Try'
        }

        It 'Should have not tried DataWidth' {
            ($obj | Get-ProcInfoOnPipeline).DataWidth | Should -Be 'No Try'
        }

        It 'Should return a custom object' {
            $obj | Get-ProcInfoOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 4 new properties' {
            $MemberArray = $obj | Get-ProcInfoOnPipeline | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TotalProcs'
            $MemberArray | Should -Contain 'ProcName'
            $MemberArray | Should -Contain 'Cores'
            $MemberArray | Should -Contain 'DataWidth'
        }
    }
}

Describe 'Get-ProcInfoOnPipeline.Tests Multi Proc' {
    BeforeAll {
        Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
            return (
                [PSCustomObject]@{
                    TotalProcs = $null
                    Name = 'MyProcName'
                    NumberOfCores = 16
                    Datawidth = 64
                },
                [PSCustomObject]@{
                    TotalProcs = $null
                    Name = 'MySecondProcName'
                    NumberOfCores = 16
                    Datawidth = 64
                }
            )
        }
    }

    Context 'Output Test - No Error Checking - Two Procs'  {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
            }
            $obj | Out-Null
        }

        It 'Should have 2 Procs' {
            ($obj | Get-ProcInfoOnPipeline -NoErrorCheck).TotalProcs | Should -Be 2
        }
    }
}
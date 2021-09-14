Describe 'Get-TimeZoneOnPipeline.Tests' {
    BeforeAll {
        Import-Module "$PSScriptRoot\..\PSServerCollectionTools\PSServerCollectionTools.psm1" -Force
        #Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
        #    return [PSCustomObject]@{
        #        TimeZoneKeyName = 'Pacific Standard Time'
        #    }
        #}

        Mock -CommandName Invoke-Command -ModuleName PSServerCollectionTools -MockWith {
            return [PSCustomObject]@{
                TimeZoneKeyName = 'Pacific Standard Time'
            }
        }
    }

    Context 'Output Test - Localhost' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = $Env:COMPUTERNAME
                Ping = $true
                WMI = $true
                PSRemote = $true
            }
            $obj | Out-Null
        }

        It 'Should return a custom object' {
            $obj | Get-TimeZoneOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TimeZoneOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TimeZone'
        }
    }

    Context 'Output Test - No Error Checking' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
            }
            $obj | Out-Null
        }
        It 'Should return a custom object' {
            $obj | Get-TimeZoneOnPipeline -NoErrorCheck | Should -BeOfType PSCustomObject
        }

        It 'Should return Pacific Timezone' {
            (($obj | Get-TimeZoneOnPipeline -NoErrorCheck).TimeZone).TimeZoneKeyName | Should -Be 'Pacific Standard Time'
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TimeZoneOnPipeline -NoErrorCheck | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TimeZone'
        }
    }
    
    Context 'Output Test - Remote Host' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $true
                WMI = $true
                PSRemote = $true
            }
            $obj | Out-Null
        }

        It 'Should return a custom object' {
            $obj | Get-TimeZoneOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should return Pacific Timezone' {
            (($obj | Get-TimeZoneOnPipeline).TimeZone).TimeZoneKeyName | Should -Be 'Pacific Standard Time'
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TimeZoneOnPipeline| Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TimeZone'
        }
    }

    Context 'Output Test - Ping Fail' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $false
                WMI = $true
                PSRemote = $true
            }
            $obj | Out-Null
        }

        It 'Should return a custom object' {
            $obj | Get-TimeZoneOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should return No Try' {
            ($obj | Get-TimeZoneOnPipeline).TimeZone | Should -Be 'No Try'
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TimeZoneOnPipeline | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TimeZone'
        }
    }

    Context 'Output Test - Ping Success, PSRemote Fail' {
        BeforeAll {
            $obj = [PSCustomObject]@{
                ComputerName = 'AnyServer'
                Ping = $true
                WMI = $true
                PSRemote = $false
            }
            $obj | Out-Null
        }
        
        It 'Should return a custom object' {
            $obj | Get-TimeZoneOnPipeline | Should -BeOfType PSCustomObject
        }

        It 'Should return No Try' {
            ($obj | Get-TimeZoneOnPipeline).TimeZone | Should -Be 'No Try'
        }

        It 'Should have 1 new property' {
            $MemberArray = $obj | Get-TimeZoneOnPipeline | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $MemberArray | Should -Contain 'TimeZone'
        }
    }
}
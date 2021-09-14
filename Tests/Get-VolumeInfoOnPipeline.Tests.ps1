<#
This must be the last item in the pipeline. It would not
make sense to gather further data as the server would be
interrogated for multiple times once for each drive.

This will only test the last object injected into the
pipeline when the Get-VolumeInfo call is complete. It is
possible to test the count of objects on the pipeline and
test the properties of the last item in the pipeline.

What cannot be tested are the properties of each item in 
the pipeline where there are more than one returned. To
do so would require a redesign of VolumeInfo function
itself to break it into multiple functions each of which
would then be tested. That does not seem necessary at this
time.
#>

Describe 'FunctionGet-VolumeInfoOnPipeline.Tests - Returns one drive only' {
    Context 'Returns one drive only' {
        BeforeAll {
            Import-Module "$PSScriptRoot\..\PSServerCollectionTools\PSServerCollectionTools.psm1" -Force
    
            Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
                return (
                    @(
                        [PSCustomObject]@{
                            freespace=314892288
                            capacity=366997504
                            drivetype=3
                            driveletter='C:'
                        }
                    )
                )
            }
        }

        Context 'Output Test - No Error Checking' {
            BeforeAll {
                $obj = [PSCustomObject]@{
                    ComputerName = 'AnyServer'
                }
                $obj | Out-Null

                $Actual = ($obj | Get-VolumeInfoOnPipeline -NoErrorCheck)
                $Actual = $Actual[0]
            }

            It 'Should return a custom object' {
                $Actual | Should -BeOfType PSCustomObject
            }

            It 'Should have a C: drive' {
                $Actual.Volumes | Should -Be 'C:'
            }

            It 'Should have drive type 3' {
                $Actual.DriveType | Should -Be 3
            }

            It 'Should have capacity less than 1 GB' {
                $Actual.Capacity | Should -Be 0
            }

            It 'Should have percent free of 85.8' {
                $Actual.PctFree | Should -Be 85.8
            }

            It 'Should have 4 new properties' {
                $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                $MemberArray | Should -Contain 'Volumes'
                $MemberArray | Should -Contain 'DriveType'
                $MemberArray | Should -Contain 'Capacity'
                $MemberArray | Should -Contain 'PctFree'
            }
        }

        Context 'Output Test - Conn Test Pass' {
            BeforeAll {
                $obj = [PSCustomObject]@{
                    ComputerName = 'AnyServer'
                    Ping = $true
                    WMI = $true
                }
                $Actual = ($obj | Get-VolumeInfoOnPipeline)
                $Actual = $Actual[0]
            }

            It 'Should return a custom object' {
                $Actual | Should -BeOfType PSCustomObject
            }

            It 'Should have a C: drive' {
                $Actual.Volumes | Should -Be 'C:'
            }

            It 'Should have drive type 3' {
                $Actual.DriveType | Should -Be 3
            }

            It 'Should have capacity less than 1 GB' {
                $Actual.Capacity | Should -Be 0
            }

            It 'Should have percent free of 85.8' {
                $Actual.PctFree | Should -Be 85.8
            }

            It 'Should have 4 new properties' {
                $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                $MemberArray | Should -Contain 'Volumes'
                $MemberArray | Should -Contain 'DriveType'
                $MemberArray | Should -Contain 'Capacity'
                $MemberArray | Should -Contain 'PctFree'
            }
        }

        Context 'Output Test - Conn Test Fail (Ping)' {
            BeforeAll {
                $obj = [PSCustomObject]@{
                    ComputerName = 'AnyServer'
                    Ping = $false
                    WMI = $true
                }
                $Actual = ($obj | Get-VolumeInfoOnPipeline)
                $Actual = $Actual[0]
            }

            It 'Should return a custom object' {
                $Actual | Should -BeOfType PSCustomObject
            }

            It 'Should have a C: drive' {
                $Actual.Volumes | Should -Be 'No Try'
            }

            It 'Should have drive type 3' {
                $Actual.DriveType | Should -Be 'No Try'
            }

            It 'Should have capacity less than 1 GB' {
                $Actual.Capacity | Should -Be 'No Try'
            }

            It 'Should have percent free of 85.8' {
                $Actual.PctFree | Should -Be 'No Try'
            }

            It 'Should have 4 new properties' {
                $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                $MemberArray | Should -Contain 'Volumes'
                $MemberArray | Should -Contain 'DriveType'
                $MemberArray | Should -Contain 'Capacity'
                $MemberArray | Should -Contain 'PctFree'
            }
        }

        Context 'Output Test - Conn Test Fail (WMI)' {
            BeforeAll{
                $obj = [PSCustomObject]@{
                    ComputerName = 'AnyServer'
                    Ping = $true
                    WMI = $false
                }
                $Actual = ($obj | Get-VolumeInfoOnPipeline)
                $Actual = $Actual[0]
            }

            It 'Should return a custom object' {
                $Actual | Should -BeOfType PSCustomObject
            }

            It 'Should have a C: drive' {
                $Actual.Volumes | Should -Be 'No Try'
            }

            It 'Should have drive type 3' {
                $Actual.DriveType | Should -Be 'No Try'
            }

            It 'Should have capacity less than 1 GB' {
                $Actual.Capacity | Should -Be 'No Try'
            }

            It 'Should have percent free of 85.8' {
                $Actual.PctFree | Should -Be 'No Try'
            }

            It 'Should have 4 new properties' {
                $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                $MemberArray | Should -Contain 'Volumes'
                $MemberArray | Should -Contain 'DriveType'
                $MemberArray | Should -Contain 'Capacity'
                $MemberArray | Should -Contain 'PctFree'
            }
        }
    }

    Context 'FunctionGet-VolumeInfoOnPipeline.Tests - Returns multiple drives' {
        BeforeAll {

            Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
                return (
                    @(
                        [PSCustomObject]@{
                            freespace=314892288
                            capacity=366997504
                            drivetype=3
                            driveletter='C:'
                        },
                        [PSCustomObject]@{
                            freespace=314892288
                            capacity=366997504
                            drivetype=3
                            driveletter='D:'
                        }
                    )
                )
            }
        }

        Context 'Output Test - No Error Checking' {
            BeforeAll {
                $obj = [PSCustomObject]@{
                    ComputerName = 'AnyServer'
                }
                $obj | Out-Null
            
                $Actual = ($obj | Get-VolumeInfoOnPipeline -NoErrorCheck)
                $Actual = $Actual[0]
            }

            It 'Should return a custom object' {
                $Actual | Should -BeOfType PSCustomObject
            }
            
            It 'Should have a D: drive (last drive on pipeline)' {
                $Actual.Volumes | Should -Be 'D:'
            }

            It 'Should have drive type 3' {
                $Actual.DriveType | Should -Be 3
            }
            
            It 'Should have capacity less than 1 GB' {
                $Actual.Capacity | Should -Be 0
            }
        
            It 'Should have percent free of 85.8' {
                $Actual.PctFree | Should -Be 85.8
            }

            It 'Should have 4 new properties' {
                $MemberArray = $Actual | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
                $MemberArray | Should -Contain 'Volumes'
                $MemberArray | Should -Contain 'DriveType'
                $MemberArray | Should -Contain 'Capacity'
                $MemberArray | Should -Contain 'PctFree'
            }
        }
    }

    Context 'FunctionGet-VolumeInfoOnPipeline.Tests - Drive with zero capacity' {
        Context 'Returns one drive only' {
            BeforeAll {
                Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
                    return (
                        @(
                            [PSCustomObject]@{
                                freespace=314892288
                                capacity=0
                                drivetype=3
                                driveletter='C:'
                            }
                        )
                    )
                }
            }

            Context 'Output Test - No Error Checking' {
                BeforeAll {
                    $obj = [PSCustomObject]@{
                        ComputerName = 'AnyServer'
                    }
                    $obj | Out-Null
                
                    $Actual = ($obj | Get-VolumeInfoOnPipeline -NoErrorCheck)
                    $Actual = $Actual[0]
                }

                It 'Should return a custom object' {
                    $Actual | Should -BeOfType PSCustomObject
                }

                It 'Should have capacity less than 1 GB' {
                    $Actual.Capacity | Should -Be 0
                }
            }
        }
    }

    Context 'FunctionGet-VolumeInfoOnPipeline.Tests - Drive with null capacity' {
        Context 'Returns one drive only' {
            BeforeAll {
                Mock -CommandName Get-CimInstance -ModuleName PSServerCollectionTools -MockWith {
                    return (
                        @(
                            [PSCustomObject]@{
                                freespace=314892288
                                capacity=$null
                                drivetype=3
                                driveletter='C:'
                            }
                        )
                    )
                }
            }

            Context 'Output Test - No Error Checking' {
                BeforeAll {
                    $obj = [PSCustomObject]@{
                        ComputerName = 'AnyServer'
                    }
                    $obj | Out-Null
                
                    $Actual = ($obj | Get-VolumeInfoOnPipeline -NoErrorCheck)
                    $Actual = $Actual[0]
                }

                It 'Should return a custom object' {
                    $Actual | Should -BeOfType PSCustomObject
                }

                It 'Should have capacity less than 1 GB' {
                    $Actual.Capacity | Should -Be 0
                }
            }
        }
    }
}
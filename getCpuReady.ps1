# filename getCpuReady.ps1
# by Anthony Hook
# usage: .\getCpuReady.ps1 $vCenter $ClusterName $CSVOutput.csv
# Super informal, assuming you're running this from a PowerCLI shell with modules loaded already


Param (
 $vCenterServer,
 $clusterName,
 $CSV
 )

$intervalseconds = 20 # Realtime CPU stats

$VC = Connect-VIServer $vCenterServer

$vms = Get-Cluster -Name $clusterName | Get-VM | Where {$_.PowerState -eq "PoweredOn"}
$vmStats = @()
$vms | % {
	$summation = $_ | Get-Stat -Stat cpu.ready.summation -MaxSamples 1 -IntervalSecs $intervalSeconds

	$vmName = $_.Name
	$vmCPU = $_.NumCPU
	$summation | Where {$_.Instance -eq ""} | % {
		$instanceStats = New-Object -TypeName PSObject
		$instanceStats | Add-Member -Name VM_Name -MemberType NoteProperty -Value $vmName
		$instanceStats | Add-Member -Name CPUReady -MemberType NoteProperty -Value (($_.Value / ($intervalSeconds * 1000)) * 100)
		$instanceStats | Add-Member -Name Cores -MemberType NoteProperty -Value $vmCPU
		$instanceStats | Add-Member -Name msDelay -MemberType NoteProperty -Value ("{0:N2}" -f ($_.Value / $intervalseconds))
		$vmStats += $instanceStats
	}
}

$vmStats | Out-GridView
$vmStats | Export-Csv $CSV -NoTypeInformation -Force

# short and sweet, thanks to @davidstamen (http://davidstamen.com/vmware/disconnected-vnics/)
Get-VM|Get-NetworkAdapter|Set-NetworkAdapter -StartConnected $true -Connected $true -Confirm:$false

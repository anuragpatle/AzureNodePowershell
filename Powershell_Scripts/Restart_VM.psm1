function RestartVM ($VMName, $RGName) {
    Restart-AzureRmVM -ResourceGroupName $RGName -Name $VMName
}

function StopVM ($VMName, $RGName) {
    Stop-AzureRmVM -ResourceGroupName $RGName -Name $VMName -Force
}

Export-ModuleMember -Function RestartVM
Export-ModuleMember -Function StopVM
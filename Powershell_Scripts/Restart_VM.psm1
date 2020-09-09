function RestartVM ($ResourceId) {
    $Resource = Get-AzureRmResource -ResourceId $ResourceId

    Restart-AzureRmVM -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.Name 
}

function StartVM ($ResourceId) {
    $Resource = Get-AzureRmResource -ResourceId $ResourceId

    Start-AzureRmVM -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.Name 
}

# function StopVM ($VMName, $RGName) {
#     Stop-AzureRmVM -ResourceGroupName $RGName -Name $VMName -Force
# }
function StopVM ($ResourceId) {
    
    $Resource = Get-AzureRmResource -ResourceId $ResourceId
    
    Write-Output "PS: Called StopVM for resource id: " $Resource.Name

    Stop-AzureRmVM -ResourceGroupName $Resource.ResourceGroupName -Name $Resource.Name -Force

}



Export-ModuleMember -Function RestartVM
Export-ModuleMember -Function StopVM
Export-ModuleMember -Function StartVM
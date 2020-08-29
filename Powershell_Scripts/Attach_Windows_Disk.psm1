Function ExecuteDiskAttachment ($VMName, $RGName) {
    
    Write-Host "`n**********Disk Attachment Process Starts...**********" -ForegroundColor DarkGray 

    $rgName = $rgName
    $vmName = $VMName
    $location = 'westeurope' 
    $storageType = 'Premium_LRS'
    $dataDiskName = $VMName + '_datadisk2'

    Write-Host "`nCreating Disk Configuration..." -ForegroundColor Green 
    $diskConfig = New-AzureRmDiskConfig -SkuName $storageType -Location $location -CreateOption Empty -DiskSizeGB 128
   
    Write-Host "`nCreating Data Disk with name=$dataDiskName..." -ForegroundColor Green 
    $dataDisk1 = New-AzureRmDisk -DiskName $dataDiskName -Disk $diskConfig -ResourceGroupName $rgName

    $vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName 

    Write-Host "`nAttaching Data Disk with name=$dataDiskName..." -ForegroundColor Green 
    $vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 2

    Write-Host "`nUpdating VM named $VMName..." -ForegroundColor Green 
    Update-AzureRmVM -VM $vm -ResourceGroupName $rgName

    Write-Host "`n**********Disk Attachment Process Ends.**********" -ForegroundColor DarkGray 



    # $location = "westeurope"
    # $scriptName = "InitializeWindowsDisk"
    # $fileName = ".\InitializeWindowsDisk.ps1"

    # Set-AzureRmVMCustomScriptExtension `
    #     -ResourceGroupName 'TSI-TEST-RG' `
    #     -Location $location `
    #     -VMName 'MyVM2' `
    #     -Name $scriptName `
    #     -TypeHandlerVersion "1.4" `
    #     -StorageAccountName "entertsitemyvm071218440" `
    #     -StorageAccountKey "primary-key" `
    #     -FileName $fileName `
    #     -ContainerName "scripts"
}

Export-ModuleMember -Function ExecuteDiskAttachment

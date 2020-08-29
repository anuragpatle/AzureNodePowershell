Function EnableVMBackup ($VMName, $RGName, $VaultName) {

    Write-Host "`n**********Process For Enabling Backup Service Starts...**********" -ForegroundColor DarkGray 

    Write-Host "`nSetting up Backup Vault Context..." -ForegroundColor Green 
    Get-AzureRmRecoveryServicesVault -Name $VaultName | Set-AzureRmRecoveryServicesVaultContext
    
    Write-Host "`nSetting up Backup Protection Policy (as default)..." -ForegroundColor Green 
    $policy = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"

    Write-Host "`nEnabling Recovery Service..." -ForegroundColor Green 
    Enable-AzureRmRecoveryServicesBackupProtection `
        -ResourceGroupName $RGName `
        -Name $VMName `
        -Policy $policy


    ## Start a backup job
    # $backupcontainer = Get-AzureRmRecoveryServicesBackupContainer `
    #     -ContainerType "AzureVM" `
    #     -FriendlyName "MyVM1"

    # $item = Get-AzureRmRecoveryServicesBackupItem `
    #     -Container $backupcontainer `
    #     -WorkloadType "AzureVM"

    # Backup-AzureRmRecoveryServicesBackupItem -Item $item
    ##

    ## Monitor in-progress backup jobs
    # Get-AzureRMRecoveryservicesBackupJob

    Write-Host "`n**********Process For Enabling Backup Service Ends.**********" -ForegroundColor DarkGray 
}
    
Export-ModuleMember -Function EnableVMBackup
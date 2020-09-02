using namespace Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels 
using namespace Microsoft.Azure.Commands.Network.Models

Import-Module .\Common.psm1
Import-Module .\VM_Creation.psm1
Import-Module .\Alert_Creation.psm1
Import-Module .\VM_Backup.psm1
Import-Module .\Attach_Windows_Disk.psm1
Import-Module .\Restart_VM.psm1

Write-Output 'Main.ps1 called'

# What Script Does?
# 1. Creates a VM.
# 2. Creates alerts to monitor VM.
# 3. Attaches a disk.
# 4. Enables backup.

## Use below commands to unload the old modules during development
# Remove-Module -FullyQualifiedName VM_Creation
# Remove-Module -FullyQualifiedName Alert_Creation
# Remove-Module -FullyQualifiedName VM_Backup
# Remove-Module -FullyQualifiedName Attach_Windows_Disk


# . ".\common.ps1"
# or
# Get-ChildItem -Path $PSScriptRoot\Public\ *.ps1,$PSScriptRoot\Private\*.ps1 | ForEach-Object {. $_.FullName}


# Login-AzureAccount

# ExucuteCreateVM
# $global:RGName = GetSelectedResourceGroupName
# $global:VMName = GetCreatedVMName


# $globalVaultName = 'MyVault1' 

# ExecuteDiskAttachment $global:VMName $global:RGName

# EnableVMBackup $global:VMName $global:RGName $globalVaultName
# # EnableVMBackup $global:VMName TSI-TEST-RG $globalVaultName

# ExecuteAlertCreation $global:VMName $global:RGName
# # ExecuteAlertCreation 'D1VM3' 'TSI-TEST-RG'

# RestartVM $global:VMName $global:RGName
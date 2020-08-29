using namespace Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels
using namespace Microsoft.Azure.Commands.Network.Models

# To list all the VMs
# Get-AzureRmVM

#UPDATE THIS 
# $username = "apatle@tsystemsin.onmicrosoft.com" 
# $myPassword = ""

#Subscription and Directory IDs
# $subscriptionID = "8efc1d1b-ff8c-4646-8b64-027cd8f131fc"
# $tenantId = "4edb18f4-a601-4435-a917-4888f28170ec" 
# $subscriptionID = (Get-AzureRmSubscription).Id
# $tenantId = (Get-AzureRmSubscription).Id

#Login to the portal
# $SecurePassword = $myPassword | ConvertTo-SecureString -AsPlainText -Force 
# $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $SecurePassword 
# $SubscriptionName = "Enterprise Dev/Test"
# $SubscriptionName = (Get-AzureRmSubscription).Name
# Login-AzureRmAccount -Credential $cred -Tenant $tenantId -SubscriptionName $SubscriptionName
# Connect-AzureRmAccount

#Resource Group
Function SelectResourceGroup {
    
    [PSResourceGroup[]] $ResourceGroups = Get-AzureRmResourceGroup

    Write-Host "`n===Resource Group Selection===`nThese are the existing resource groups." -ForegroundColor Green 
    for ($i = 0; $i -lt $ResourceGroups.length; $i++) { 
        $rgName = $ResourceGroups[$i].ResourceGroupName
        $userFamilierIndex = $i + 1
        Write-Output "Enter $userFamilierIndex to select $rgName"
    }

    $RsChoice = Read-Host -Prompt 'Enter your choice'

    $global:selectedRG = $ResourceGroups[$RsChoice - 1]
    $rsgName = $selectedRG.ResourceGroupName
    Write-Output "You have selected: $rsgName"


    

} # End Function SelectResourceGroup


function selectActionGroup {
    
    Write-Host "`n===Action Group Selection===`nThese are the existing action groups." -ForegroundColor Green 

    $actionGroups = Get-AzureRmActionGroup -WarningAction Ignore
    for ($i = 0; $i -lt $actionGroups.length; $i++) { 
        Write-Host "Enter $($i + 1) to select $($actionGroups[$i].Name)"
    }

    $choice = Read-Host "Enter your choice:"

    $global:selectedActionGroup = $actionGroups[$choice - 1]

}

<#
.SYNOPSIS
Cerete alert for an individual VM
 

.DESCRIPTION
Long description

.PARAMETER selectedRG
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function ExecuteAlertCreation ($VMName, $RGName) {

    Write-Host "`n**********Alert Creation Starts...**********" -ForegroundColor DarkGray 

    selectActionGroup

    # ARM Templates File Paths
    $templateFilePath = "template.json"
    $parametersFilePath = "parameters.json"

    # Get Resources
    #$VMColl = Get-AzureRmResource -ResourceType "Microsoft.Compute/VirtualMachines" | Select-Object -Property ResourceId, Name


    Write-Host "`nSelecting the VM ..." -ForegroundColor Green 
    $selectedVM = Get-AzureRmVM -Name $VMName -ResourceGroupName $RGName
    
    # CPU percentage for vritual machines
    
    #Parameters
    $strVMID = $selectedVM.Id
    $strVMName = $selectedVM.Name
    
    
    Write-Host "`nCreating Metric Alerts for Virtual Machines..." -ForegroundColor Green 
    Write-Host "Performing operations for VM: " $strVMName

    $alertName = "CPU Performance " + $strVMName
    $metricName = "Percentage CPU"
    $threshold = "0.2"
    # $actionGroupId = "/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/microsoft.insights/actionGroups/AnuActionGrp1Name"
    $actionGroupId = $global:selectedActionGroup.Id

    Write-Host "ActionGroup id: $($global:selectedActionGroup.Id)"

    $timeAggregation = "Maximum" # Average, Minimum, Maximum, Total
    $alertDescription = "The percentage of allocated compute units that are currently in use by the Virtual Machine(s)"
    $operator = "GreaterThan" # Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual
    $alertSeverity = 3 # 0,1,2,3,4

    #Get JSON
    $paramFile = Get-Content $parametersFilePath -Raw | ConvertFrom-Json

    #Update Values
    $paramFile.parameters.alertName.value = $alertName
    $paramFile.parameters.metricName.value = $metricName
    $paramFile.parameters.resourceId.value = $strVMID
    $paramFile.parameters.threshold.value = $threshold
    $paramFile.parameters.actionGroupId.value = $actionGroupId
    $paramFile.parameters.timeAggregation.value = $timeAggregation
    $paramFile.parameters.alertDescription.value = $alertDescription
    $paramFile.parameters.operator.value = $operator
    $paramFile.parameters.alertSeverity.value = $alertSeverity

    #Update JSON
    $UpdatedJSON = $paramFile | ConvertTo-Json
    $UpdatedJSON > $parametersFilePath

    #Deploy Template
    $DeploymentName = "CPUPerformanceAlerts-$strVMName"
    # $AlertDeployment = New-AzureRmResourceGroupDeployment -Name $DeploymentName `
    #     -ResourceGroupName $RGName `
    #     -TemplateFile $templateFilePath `
    #     -TemplateParameterFile $parametersFilePath `
    #     -AsJob

    $AlertDeployment = New-AzureRmResourceGroupDeployment -Name $DeploymentName `
        -ResourceGroupName $RGName `
        -TemplateFile $templateFilePath `
        -TemplateParameterFile $parametersFilePath

    Write-Host "`n**********Alert Creation Ends.**********" -ForegroundColor DarkGray 

}


## Use this function when you want to create alert for each VM in a resource group
# function ExecuteAlertCreation ($selectedRG) {

#     Write-Host "`n**********Alert Creation Starts...**********" -ForegroundColor DarkGray 

#     # SelectResourceGroup
#     $global:selectedRG = $selectedRG

#     selectActionGroup

#     # ARM Templates File Paths
#     $templateFilePath = "template.json"
#     $parametersFilePath = "parameters.json"

#     # Get Resources
#     $VMColl = Get-AzureRmResource -ResourceType "Microsoft.Compute/VirtualMachines" | Select-Object -Property ResourceId, Name

#     Write-Host "Creating Metric Alerts for Virtual Machines"

#     # CPU percentage for vritual machines

#     foreach ($VMID in $VMColl) {
    
#         #Parameters
#         $strVMID = $VMID.ResourceId
#         $strVMName = $VMID.Name

#         Write-Host "Performing operations for VM: " $strVMName

#         $alertName = "CPU Performance " + $strVMName
#         $metricName = "Percentage CPU"
#         $threshold = "1"
#         # $actionGroupId = "/subscriptions/8efc1d1b-ff8c-4646-8b64-027cd8f131fc/resourceGroups/TSI-Test-RG/providers/microsoft.insights/actionGroups/AnuActionGrp1Name"
#         $actionGroupId = $global:selectedActionGroup.Id

#         Write-Host "ActionGroup id: $($global:selectedActionGroup.Id)"

#         $timeAggregation = "Maximum" # Average, Minimum, Maximum, Total
#         $alertDescription = "The percentage of allocated compute units that are currently in use by the Virtual Machine(s)"
#         $operator = "GreaterThan" # Equals, NotEquals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual
#         $alertSeverity = 3 # 0,1,2,3,4

#         #Get JSON
#         $paramFile = Get-Content $parametersFilePath -Raw | ConvertFrom-Json

#         #Update Values
#         $paramFile.parameters.alertName.value = $alertName
#         $paramFile.parameters.metricName.value = $metricName
#         $paramFile.parameters.resourceId.value = $strVMID
#         $paramFile.parameters.threshold.value = $threshold
#         $paramFile.parameters.actionGroupId.value = $actionGroupId
#         $paramFile.parameters.timeAggregation.value = $timeAggregation
#         $paramFile.parameters.alertDescription.value = $alertDescription
#         $paramFile.parameters.operator.value = $operator
#         $paramFile.parameters.alertSeverity.value = $alertSeverity

#         #Update JSON
#         $UpdatedJSON = $paramFile | ConvertTo-Json
#         $UpdatedJSON > $parametersFilePath

#         #Deploy Template
#         $DeploymentName = "CPUPerformanceAlerts-$strVMName"
#         $AlertDeployment = New-AzureRmResourceGroupDeployment -Name $DeploymentName `
#             -ResourceGroupName $global:selectedRG.ResourceGroupName `
#             -TemplateFile $templateFilePath `
#             -TemplateParameterFile $parametersFilePath `
#             -AsJob


#     } 
    
# }

Export-ModuleMember -Function ExecuteAlertCreation
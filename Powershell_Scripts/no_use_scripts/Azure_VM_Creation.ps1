
using namespace Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels
using namespace Microsoft.Azure.Commands.Network.Models



$vmName

Function Login-AzureAccount {

    ### Way 1. --Does not work-- Reason: Azure Policies 
    ### (Azure does not allow you login by typing your username & pass into the command prompt)
    # Param($UserEmailAddress, $UserPassword)
    # Write-Output "user: $UserEmailAddress $UserPassword"
    # $UserCredential = new-object -typename System.Management.Automation.PSCredential -ArgumentList $UserEmailAddress, $UserPassword
    # Login-AzureRmAccount -Credential $UserCredential


    ### Way 2. Hard coded login
    # $UserEmailAddress = Read-Host -Prompt 'Enter your email address' 
    # $UserPassword = Read-Host -Prompt 'Enter your Azure password' -AsSecureString
    # $realPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($VMPassword))
    # Login-AzureAccount -UserEmailAddress $UserEmailAddress -UserPassword $UserPassword



    ### Way 3. A window appears and asks for user login
    # Connect-AzureRmAccount

    ### Way 4. When you want store credentials into a variable.
    ### A window appears and asks for user login (Recomended)
    $cred = Get-Credential -Message "Enter a username and password for the virtual machine."

}

# Create or Select a resource group
Function CreateOrSelectResourceGroup {
    
    $selectedRG
    
    # To get type
    # $type = (Get-AzureRmResourceGroup)[0].GetType()
    [PSResourceGroup[]] $ResourceGroups = Get-AzureRmResourceGroup


    Write-Output "`v===Resource Group Selection===`n`nThese are the existing resource groups."
    for ($i = 0; $i -lt $ResourceGroups.length; $i++) { 
        $rgName = $ResourceGroups[$i].ResourceGroupName
        $userFamilierIndex = $i + 1
        Write-Output "Enter $userFamilierIndex to select $rgName"
    }

    Write-Output "[OR] Enter 0 to create a new Resource group`n"

    $RsChoice = Read-Host -Prompt 'Enter your choice'
   

    if ($RsChoice -eq 0) {

        $rsgName = Read-Host -Prompt 'Enter a new name for your resource group'

        $rsgLocation = Read-Host -Prompt 'Enter a location for your Resource Group'

        New-AzureRMResourceGroup -Name $rsgName -Location $rsgLocation

    }
    else {

        $selectedRG = $ResourceGroups[$RsChoice - 1].ResourceGroupName
    
        Write-Output "You have selected: $selectedRG"
    }  
} # End Function CreateOrSelectResourceGroup

# Create a subnet configuration
function CreateOrSelectVirtualNetwork {
    param ()

    
    [PSVirtualNetwork[]] $vNets = Get-AzureRmVirtualNetwork -WarningAction Ignore
    
    Write-Output "`vTo select from the existing virtual networks.`n"
    for ($i = 0; $i -lt $vNets.Count; $i++) {
        $vNetName = $vNets[$i].Name
        $vNetResGrpName = $vNets[$i].ResourceGroupName
        $userFriendlyIndex = $i + 1
        Write-Output "Enter $userFriendlyIndex to select $vNetName of Resource Group $vNetResGrpName"
    }

    Write-Output "`n[OR] Enter 0 to create a new virtual network`n"

    $choice = Read-Host 

    
    if ($choice -eq 0) {
        # Create a subnet configuration
        #$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name mySubnet -AddressPrefix 192.168.1.0/24

        # Create a virtual network
        #$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
        #    -Name MYvNET -AddressPrefix 192.168.0.0/16 -Subnet $subnetConfig     
    }
    else {
        $choosenVNet = $vNets[$choice - 1].Name
        Write-Host "You have selected $choosenVNet"
    }

   


}



# Login-AzureAccount

#$vmName = Read-Host -Prompt "`nEnter a name for VM"


#CreateOrSelectResourceGroup

CreateOrSelectVirtualNetwork
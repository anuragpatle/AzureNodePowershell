using namespace Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels 
using namespace Microsoft.Azure.Commands.Network.Models

$global:timestamp

try {
    [PSResourceGroup] $global:selectedRG = $null
    [PSVirtualNetwork]$global:choosenVNet
}
catch [System.Net.WebException], [System.IO.IOException] {
     
}
catch {
     
}

function showInvalidArgumentError {
    Write-Error "You have entered an invalid choice"  -Category InvalidArgument
}

# Create or Select a resource group
Function CreateOrSelectResourceGroup {
    
    # To get type
    # $type = (Get-AzureRmResourceGroup)[0].GetType()
    [PSResourceGroup[]] $ResourceGroups = Get-AzureRmResourceGroup

    Write-Host "`n===Resource Group Selection===`nThese are the existing resource groups." -ForegroundColor Green 
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
        $global:selectedRG = New-AzureRMResourceGroup -Name $rsgName -Location $rsgLocation
    }
    else {

        $global:selectedRG = $ResourceGroups[$RsChoice - 1]
        $rsgName = $selectedRG.ResourceGroupName
        Write-Output "You have selected: $rsgName"
    }  
} # End Function CreateOrSelectResourceGroup

Function GetSelectedResourceGroupName {
    
    # $RGName = (Get-AzureRmResourceGroup -Name TSI-TEST-RG).ResourceGroupName
    $RGName = $global:selectedRG.ResourceGroupName
    return $RGName

}

function GetCreatedVMName {
    return $global:vmName
}


# Create a subnet configuration
function CreateOrSelectVirtualNetwork {
    
    [PSVirtualNetwork[]] $vNets = Get-AzureRmVirtualNetwork -WarningAction Ignore
    
    Write-Host "`n ====Virtual Network Section===`nSelect from the existing virtual networks." -ForegroundColor Green 
    
    for ($i = 0; $i -lt $vNets.Count; $i++) {
        $vNetName = $vNets[$i].Name
        $vNetResGrpName = $vNets[$i].ResourceGroupName
        $userFriendlyIndex = $i + 1
        Write-Output "Enter $userFriendlyIndex to select $vNetName of Resource Group $vNetResGrpName"
    }

    Write-Output "`n[OR] Enter 0 to create a new virtual network`n"

    [int32]$choice = Read-Host 
    
    if (($choice.GetType() -ne [int32]) -or ($choice -gt $vNets.count) -or $choice -lt 0 ) {
        showInvalidArgumentError
        CreateOrSelectVirtualNetwork
    }
    
    # Create a new Subnet and then virtual network.
    if ($choice -eq 0) {
        
        $subnetName = Read-Host -Prompt "Enter a name for subnet"
        $vNetName = Read-Host -Prompt "Enter a name for virtual network"
        $subnetAddressPrefix = Read-Host -Prompt "Enter address prefix for subnet (Eg. 192.168.1.0/24)"
        $vnetAddressPrefix = Read-Host -Prompt "Enter address prefix for virtual network(Eg. 192.168.0.0/16)"
        
        # Create a subnet configuration
        $subnetConfig = New-AzureRMVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddressPrefix

        # Create a virtual network
        $global:choosenVNet = New-AzureRMVirtualNetwork -ResourceGroupName $global:selectedRG.ResourceGroupName `
            -Location $global:selectedRG.Location `
            -Name $vNetName -AddressPrefix $vnetAddressPrefix -Subnet $subnetConfig `
            -WarningAction Ignore    
        
        Write-Output "created vnet is: " $global:choosenVNet
        
    }
    else {
        
        if ($null -eq $choice -or '' -eq $choice) {
            Write-Output "You have entered an invalid value."
        }
        else {
            $global:choosenVNet = $vNets[$choice - 1]
            $choosenVNetName = $global:choosenVNet.Name
            Write-Host "You have selected $choosenVNetName"
        }
    }
}

# Create a public IP address and specify a DNS name
$global:pip
Function CreatePublicIP {
    
    # Write-Output "dnsname mypublicdns$(Get-Random)" 
    
    # $dnsName = Read-Host -Prompt "Enter a name for your public dns"
    $dnsName = "DNS$(Get-Date -Format yyyyMMddTHHmmss)"
    
    Write-Host "`nCreating Public IP with DNS name $dnsName ..." -ForegroundColor Green 
    
    $global:pip = New-AzureRMPublicIpAddress -ResourceGroupName $global:selectedRG.ResourceGroupName `
        -Location $global:selectedRG.Location `
        -Name $dnsName `
        -AllocationMethod Static -IdleTimeoutInMinutes 4
   
}
  
# Create an inbound network security group rule for port 3389
Function CreateOrSelectNtwrkSecGrpRule {


    $selectedRGName = $global:selectedRG.ResourceGroupName

    Write-Host "`n===Network Security Group Rule Creation===" -ForegroundColor Green 

    Write-Host "These are the existing Secutity Group Rule Configuration for the ResourceGroup: $selectedRGName"

    Get-AzureRmNetworkSecurityGroup -ResourceGroupName $selectedRGName `
    | Get-AzureRmNetworkSecurityRuleConfig `
    | Select-Object -Property Protocol, Name, Access, Proority, Direction

    # Write-Host $NetworkSecurityRuleConf

    $newRuleChoice = Read-Host -P "`nPress 's' to skip to be with the present configuration.`nPress 'n' to create a new rule."

    if ($newRuleChoice -eq 's') {

    }
    elseif ($newRuleChoice -eq 'n') {

        $ruleName = Read-Host -Prompt "Enter a name for your Network Security Group Rule for RDP"
        $inboundPriority = Read-Host -Prompt "Enter inbound priority(e.g. 1000)"
        $sourceAddressPrefix = Read-Host -Prompt "Enter source address prefix(e.g. *)"
        $destinationAddressPrefix = Read-Host -Prompt "Enter destination address prefix(e.g. *)"
        $sourcePortRange = Read-Host -Prompt "Enter source port range(e.g. *)"
        $destinationPortRange = Read-Host -Prompt "Enter destination port range(e.g. 3389)"
        $access = Read-Host -Prompt "Enter accessible(e.g. Allow)" 
        
        $global:nsgRuleRDP = New-AzureRMNetworkSecurityRuleConfig -Name $ruleName  -Protocol Tcp `
            -Direction Inbound `
            -Priority $inboundPriority `
            -SourceAddressPrefix $sourceAddressPrefix `
            -SourcePortRange $sourcePortRange `
            -DestinationAddressPrefix $destinationAddressPrefix `
            -DestinationPortRange $destinationPortRange `
            -Access $access

        CreateNetworkSecurityGroup
    }
    else {
        showInvalidArgumentError
        CreateOrSelectNtwrkSecGrpRule
    }

   
}

# Create a network security group
Function CreateNetworkSecurityGroup {
    
    # $nwSecurityGroupName = Read-Host -Prompt "Enter a name for Network Security Group"
    $nwSecurityGroupName = "NSG$(Get-Date -Format yyyyMMddTHHmmss)"
    
    Write-Host "`nCreating Network Security Group with name $nwSecurityGroupName ..." -ForegroundColor Green 

    $global:nsg = New-AzureRMNetworkSecurityGroup -ResourceGroupName $global:selectedRG.ResourceGroupName `
        -Location $global:selectedRG.Location `
        -Name $nwSecurityGroupName `
        -SecurityRules $global:nsgRuleRDP
}

# Create a virtual network card and associate with public IP address and NSG
$global:nic
Function CreateVirtualNetworkCard {
    
    
    
    # $nicName = Read-Host -Prompt "Enter a name for virtual network interface"
    $nicName = "NIC$(Get-Date -Format yyyyMMddTHHmmss)"

    Write-Host "`nCreating Virtual Network Card with name $nicName ..." -ForegroundColor Green 
    
    $global:nic = New-AzureRMNetworkInterface -Name $nicName `
        -ResourceGroupName $global:selectedRG.ResourceGroupName `
        -Location $global:selectedRG.Location `
        -SubnetId $global:choosenVNet.Subnets[0].Id `
        -PublicIpAddressId $global:pip.Id `
        -NetworkSecurityGroupId $nsg.Id

}

# Create a virtual machine configuration
Function CreateVirtualNetworkConfiguration {
    
    Write-Host "`n===Virtual Machine configuration===" -ForegroundColor Green 
    
    $global:vmName = Read-Host -Prompt "`nEnter a name for VM"
    # $vmSize = Read-Host -Prompt "Enter vm size(e.g. Standard_B1s)"
    $vmSize = 'Standard_B1ls'

    # Define a credential object
    # $UserName = Read-Host -Prompt 'Enter a username for the VM.'
    # #$VMPassword = Read-Host -Prompt 'Enter a password for the VM.' -AsSecureString
    # $VMPassword = 'AFakePassword#1'
    # $securePassword = ConvertTo-SecureString $VMPassword -AsPlainText -Force
    # $cred = "New-Object System.Management.Automation.PSCredential ($UserName, $securePassword)"

    $cred = Get-Credential -Message "Enter a username and password for the virtual machine."  

    $cmddNewVMConf = New-AzureRMVMConfig -VMName $vmName -VMSize $vmSize
    $cmdOSConf
    $VMSrcImg

    # $osType = Read-Host -P "`nEnter 'w' if it is windows OS.`nEnter 'l' if it is Linux OS."
    $osType = 'w'

    if ($osType -eq 'w') {
        $cmdOSConf = $cmddNewVMConf | Set-AzureRMVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred 

        $VMSrcImg = $cmdOSConf | Set-AzureRMVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest
    }
    elseif ($osType -eq 'l') {
        $cmdOSConf = $cmddNewVMConf | Set-AzureRMVMOperatingSystem -Linux -ComputerName $vmName -Credential $cred 

        $VMSrcImg = $cmdOSConf | Set-AzureRmVMSourceImage  -PublisherName Canonical -Offer UbuntuServer -Skus 16.04-LTS -Version latest
    }
    else {
        showInvalidArgumentError
        CreateVirtualNetworkConfiguration
    }


    # $global:nic = Get-AzureRmNetworkInterface -ResourceGroupName RGUbuntu18

    $global:vmConfig = $VMSrcImg | Add-AzureRMVMNetworkInterface -Id $global:nic.Id

    # $global:vmConfig = Invoke-Expression -Command $configCommand 

    # $global:vmConfig = New-AzureRMVMConfig -VMName $vmName `
    #     -VMSize $vmSize | `
    #     Set-AzureRMVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
    #     Set-AzureRMVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest | `
    #     Add-AzureRMVMNetworkInterface -Id $global:nic.Id
}

# Create a virtual machine
Function CreateVM {
    Write-Host "`nCreating your VM..." -ForegroundColor DarkMagenta 

    # New-AzureRMVm `
    # -ResourceGroupName "TSI-TEST-RG" `
    # -Name "D1VM10" `
    # -Location "West Europe" `
    # -VirtualNetworkName "myVnet" `
    # -SubnetName "Subnet10Aug2020" `
    # -SecurityGroupName "NSG10Aug2020" `
    # -PublicIpAddressName "PIPD1VM10" `
    # -OpenPorts 80,3389

    # New-AzureRMVm `
    # -ResourceGroupName "TSI-TEST-RG" `
    # -Name "D1VM10" `
    # -Location $global:selectedRG.Location `
    # -VirtualNetworkName $global:choosenVNet.Name `
    # -SubnetName "Subnet10Aug2020" `
    # -SecurityGroupName "NSG10Aug2020" `
    # -PublicIpAddressName "PIP_$(GetUniqueName)" `
    # -OpenPorts 80,3389

    New-AzureRMVM -ResourceGroupName $global:selectedRG.ResourceGroupName -Location $global:selectedRG.Location -VM  $global:vmConfig 

    
    
}

Function GetUniqueName {

    if ([string]::IsNullOrEmpty($global:timestamp)) {
        $global:timestamp = "$global:vmName_$(Get-Date -Format yyyyMMddTHHmmss)"
    }

}

Function GetVMName {
    $global:vmName
}

function ExucuteCreateVM {
    Write-Host "`n**********VM Creation Starts...**********" -ForegroundColor DarkGray 
     
    CreateOrSelectResourceGroup

    CreateOrSelectVirtualNetwork

    CreatePublicIP

    CreateOrSelectNtwrkSecGrpRule

    CreateVirtualNetworkCard

    CreateVirtualNetworkConfiguration

    CreateVM

    Write-Host "`n**********VM Creation Ends.**********" -ForegroundColor DarkGray 

    
}




Export-ModuleMember -Function ExucuteCreateVM
Export-ModuleMember -Function GetSelectedResourceGroupName
Export-ModuleMember -Function GetCreatedVMName
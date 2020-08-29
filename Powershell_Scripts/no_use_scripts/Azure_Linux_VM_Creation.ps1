New-AzureRMResourceGroup -Name "myResourceGroup" -Location "EastUS"

# # Create a subnet configuration
# $subnetConfig = New-AzureRMVirtualNetworkSubnetConfig `
#   -Name "mySubnet" `
#   -AddressPrefix 192.168.1.0/24

# # Create a virtual network
# $vnet = New-AzureRMVirtualNetwork `
#   -ResourceGroupName "myResourceGroup" `
#   -Location "EastUS" `
#   -Name "myVNET" `
#   -AddressPrefix 192.168.0.0/16 `
#   -Subnet $subnetConfig

# # Create a public IP address and specify a DNS name
# $pip = New-AzureRMPublicIpAddress `
#   -ResourceGroupName "myResourceGroup" `
#   -Location "EastUS" `
#   -AllocationMethod Static `
#   -IdleTimeoutInMinutes 4 `
#   -Name "mypublicdns$(Get-Random)"
  
  
  # Create an inbound network security group rule for port 22
# $nsgRuleSSH = New-AzureRMNetworkSecurityRuleConfig `
# -Name "myNetworkSecurityGroupRuleSSH"  `
# -Protocol "Tcp" `
# -Direction "Inbound" `
# -Priority 1000 `
# -SourceAddressPrefix * `
# -SourcePortRange * `
# -DestinationAddressPrefix * `
# -DestinationPortRange 22 `
# -Access "Allow"

# # Create an inbound network security group rule for port 80
# $nsgRuleWeb = New-AzureRMNetworkSecurityRuleConfig `
# -Name "myNetworkSecurityGroupRuleWWW"  `
# -Protocol "Tcp" `
# -Direction "Inbound" `
# -Priority 1001 `
# -SourceAddressPrefix * `
# -SourcePortRange * `
# -DestinationAddressPrefix * `
# -DestinationPortRange 80 `
# -Access "Allow"

# # Create a network security group
# $nsg = New-AzureRMNetworkSecurityGroup `
# -ResourceGroupName "myResourceGroup" `
# -Location "EastUS" `
# -Name "myNetworkSecurityGroup" `
# -SecurityRules $nsgRuleSSH,$nsgRuleWeb


# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRMNetworkInterface `
  -Name "myNic" `
  -ResourceGroupName "myResourceGroup" `
  -Location "EastUS" `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id
  
  
  
  # Define a credential object
$securePassword = ConvertTo-SecureString 'AFakePassword#1' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("apatle", $securePassword)

# Create a virtual machine configuration
$vmConfig = New-AzureRMVMConfig `
  -VMName "myVM" `
  -VMSize "Standard_B1s" | `
Set-AzureRMVMOperatingSystem `
  -Linux `
  -ComputerName "myVM" `
  -Credential $cred `
  -DisablePasswordAuthentication | `
Set-AzureRMVMSourceImage `
  -PublisherName "Canonical" `
  -Offer "UbuntuServer" `
  -Skus "16.04-LTS" `
  -Version "latest" | `
Add-AzureRMVMNetworkInterface `
  -Id $nic.Id

# Configure the SSH key
$sshPublicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAhCNgxPrUd0Wa1ENpGINt0vob+/cGY3ol4TF9Zl1Xq6o4pH5hg/MYtkV6naht6rJefR4ao/RGVBGjA3N8j2PvPC4w2HFzkvpMICg6Cm+WaG2woj8OVroZJds+i/CnjV1c+x3YkePLR96K9F620qkhCrexzXttSkVsyT66sF7dHRUG5IFJyIgHoChsIe20+Ec8LKHutbnQG5xk1BlXgsMHNCg3gss48uHAPNGllhnT9DgQHKtBF7EDGa9DqUWHqe0cudl1KdsCin/XZTcvomqLRiWNjbStR+ZeqmJXFvLUDREhaa5oC9SejjyKAT3MtogHsbbgD9Ysw1jNLBYmnKbVNQ== rsa-key-20200624"


Add-AzureRMVMSshPublicKey `
  -VM $vmconfig `
  -KeyData $sshPublicKey `
  -Path "/home/apatle/.ssh/authorized_keys"
  
  
  
  New-AzureRMVM `
  -ResourceGroupName "myResourceGroup" `
  -Location eastus -VM $vmConfig
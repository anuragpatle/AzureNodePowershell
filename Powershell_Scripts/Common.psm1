
function Login-AzureAccount {

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
    Connect-AzureRmAccount
    


}


Export-ModuleMember -Function Login-AzureAccount
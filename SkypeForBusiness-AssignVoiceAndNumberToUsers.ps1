# Routing policy assigned to the users
$policyName = "Global"
# Get Administrator Credential
$adminCredential = Get-Credential
# Microsoft 365 connection
Connect-MsolService -Credential $adminCredential
# SkypeForBusiness connection
Import-Module SkypeOnlineConnector
$sfboSession = New-CsOnlineSession -Credential $adminCredential
Import-PSSession $sfboSession
$phoneSystemUser = Get-MsolUser | Where-Object {($_.licenses).AccountSkuId -match "MCOEV"} | Select-Object UserPrincipalName,PhoneNumber
foreach ($item in $phoneSystemUser){
	$phoneNumerInE164 = $item.PhoneNumber -replace '[ ()-]',''
	Write-Host "Assigning Voice to $($item.userPrincipalName) using $phoneNumerInE164"
	Set-CsUser -Identity $($item.userPrincipalName) -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI tel:$($phoneNumerInE164)
	Grant-CsOnlineVoiceRoutingPolicy -Identity $($item.userPrincipalName) -PolicyName $($policyName)
}

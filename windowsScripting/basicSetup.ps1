# This script is intended for use before joining a domain
# It sets up networking, makes a local user, and changes the hostname


# Conditional to see if you would like to make a new local user
echo "Would you like to make a LOCAL admin user account? (y or n): "
$newUser = Read-Host
if($newUser -eq 'y') {

# Makes a local user, requesting a username and password
echo "Please enter a username for a new local user: "
$username = Read-Host
echo "Please enter a password for the user '$username': "
$password = Read-Host -AsSecureString
echo " "
echo "If the script freezes, please hit enter"
New-LocalUser -Name $username -Password $password -confirm:$false
Add-LocalGroupMember -Group "Administrators" -Member $username -confirm:$false 
}

# For some reason, the script freezes here sometimes
# The read-host ensures that the user will still be able to answer the next question
$test = Read-Host

# check to see if you would like to make a new DOMAIN user
echo "Would you like to make a DOMAIN user account? (y or n): "
$domainUser = Read-Host
if($domainUser -eq 'y') {
echo "Would you like this account to be an admin account? (y or n): "
$domainAdmin = Read-Host
	if($domainAdmin -eq 'y') {
	echo "Please enter a username for the new domain admin account: "
	$adminUsername = Read-Host
	echo "Please enter a password for the user '$adminUsername': "
	$adminPassword = Read-Host -AsSecureString
	New-ADUser -Name $adminUsername -AccountPassword $adminPassword -enabled:$true -confirm:$false
	Add-ADGroupMember -Identity "Domain Admins" -Members $adminUsername -confirm:$false
	}
	else {
	echo "Please enter a username for the new domain standard account: "
	$standardUsername = Read-Host
	echo "Please enter a password for the user '$standardUsername': "
	$standardPassword = Read-Host -AsSecureString
	New-ADUser -Name $standardUsername -AccountPassword $standardPassword -enabled:$true -confirm:$false
	} 
}


# check if the user wants to set up networking
echo " "
echo "Would you like to set up networking? (y or n): "
$networking = Read-Host
if ($networking -eq 'y') {

# Networking! Prompts user for each component
echo "Please enter the host IP address: "
$hostIP = Read-Host
echo "Please enter the prefix length (ex. 24): "
$prefixLength = Read-Host 
echo "Please enter the default gateway: "
$defaultGateway = Read-Host
echo "Please enter the DNS server address: "
$DNSAddress = Read-Host
$displayIntID = Get-NetAdapter | Select-Object InterfaceIndex
echo " "
Write-Host $displayIntID
echo " "
echo "Please enter the InterfaceIndex number displayed on the screen: "
$intID = Read-Host

# Removes existing IP configurations to prevent errors
Remove-NetIPAddress -InterfaceIndex $intID -Confirm:$false
# This removes the default gateway, but will throw an error if there are no routes set, so I have set it to 
# ignore errors
Remove-NetRoute -InterfaceIndex $intID -confirm:$false -erroraction 'silentlycontinue'
Set-DNSClientServerAddress -InterfaceIndex $intID -ResetServerAddresses

# Sets IP and netmask using user inputs
New-NetIPAddress -InterfaceIndex $intID -IPAddress $hostIP -PrefixLength $prefixLength -DefaultGateway $defaultGateway
Set-DNSClientServerAddress -InterfaceIndex $intID -ServerAddresses ("$DNSAddress")
}


# Conditional to see if you would like to change the hostname
echo " "
echo "Would you like to change the hostname? Only select yes if not yet domain joined. (y or n): "
$changeName = Read-Host
if($changeName -eq 'y') {
# Collects required variables
echo "Enter the new hostname: "
$newHostname = Read-Host
echo "Enter a LOCAL username with permissions to change the hostname: "
$userAccount = Read-Host
rename-computer -NewName $newHostname -force -LocalCredential $userAccount
echo "Please restart your computer for this change to take effect."
}


# Conditional to join domain
echo " "
echo "Would you like to join a domain? (y or n): "
$domainJoin = Read-Host
if($domainJoin -eq 'y') {

# Queries user for all variables
echo "Enter the name of the domain you are joining: "
$domainName = Read-Host
echo "Enter a DOMAIN admin account name to use when joining the domain: "
$adminName = Read-Host
echo "You must restart the computer after this operation."
# Actual command to join domain
Add-Computer -DomainName $domainName -Credential $adminName -Force

}


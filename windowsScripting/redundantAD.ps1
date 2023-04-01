# Redundant ADDS
# 
# This script:
#
# 1. Installs ADDS on Windows Servers
# 2. Prompts for domain creation
# 3. Creates secondary domain controllers

# Prompts user to install ADDS on DC
$hostname = hostname
echo "Would you like to install Active Directory Domain Services on the server: '$hostname'? (y/n)"
$installAD = Read-Host
if ($installAD -eq 'y') {
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
}

# Prompts user to promote server to a primary domain controller
echo "Will this machine be a primary domain controller? (y/n)"
$ifPrimary = Read-Host
if ($ifPrimary -eq 'y') {
    echo "What is the full name of the domain you wish to create?"
    $domainName = Read-Host
    Install-ADDSForest -DomainName $domainName
} 
elseif ($ifPrimary -eq 'n') {
    # Prompts user to promote server to a secondary domain controller
    echo "Will this machine be a secondary domain controller for redundancy? (y/n)"
    $ifSecondary = Read-Host
    if ($ifSecondary -eq 'y') {
        echo "What is the full name of the domain you wish this DC to join?"
        $domainName = Read-Host

	# Set DNS server address of secondary DC to the primary DC address
	echo "What is the IP of the primary DC?"
	$DNSAddress = Read-Host

	# Sets DNS
    $displayIntID = Get-NetAdapter | Select-Object InterfaceIndex
    echo " "
    Write-Host $displayIntID
    echo " "
    echo "Please enter the InterfaceIndex number displayed on the screen: "
    $intID = Read-Host

	Set-DNSClientServerAddress -InterfaceIndex "intID" -ServerAddresses "$DNSAddress, 127.0.0.1"

	# Ask for domain admin creds
	echo "What are the credentials of the the domain admin on the primary DC? Ex: 'bestteam\Administrator'"
	$domainCreds = Read-Host
	echo "What is the password for the account: '$domainCreds'?"
	$domainPass = Read-Host -AsSecureString

    # Promotes to DC
    Install-ADDSDomainController -InstallDns -Credential (Get-Credential $domainCreds) -DomainName $domainName -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "$domainPass" -Force)
        }
}


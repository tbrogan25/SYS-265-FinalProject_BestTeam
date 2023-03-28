# This script is intended for use before joining a domain
# It sets up networking, makes a local user, and changes the hostname


# Makes a local user, requesting a username and password
echo "Please enter a username for a new local user: "
$username = Read-Host
echo "Please enter a password for the user '$username': "
$password = Read-Host -AsSecureString
New-LocalUser -Name $username -Password $password
Add-LocalGroupMember -Group "Administrators" -Member $username

# Networking! Prompts user for each component
echo "Please enter the host IP address: "
$hostIP = Read-Host
echo "Please enter the prefix length (ex. 24): "
$prefixLength = Read-Host 
echo "Please enter the default gateway: "
$defaultGateway = Read-Host
echo "Please enter the DNS server address: "
$DNSAddress = Read-Host
Get-NetAdapter | Select-Object InterfaceIndex
echo "Please enter the InterfaceIndex number displayed on the screen: "
$intID = Read-Host
# Sets IP and netmask using user inputs
Set-NetIPAddress -InterfaceIndex $intID -IPAddress $hostIP -PrefixLength $prefixLength -DefaultGateway
Set-DNSClientServerAddress -InterfaceIndex $intID -ServerAddresses ("\$DNSAddress")

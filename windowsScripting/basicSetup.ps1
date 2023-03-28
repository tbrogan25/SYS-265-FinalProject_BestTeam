# This script is intended for use before joining a domain
# It sets up networking, makes a local user, and changes the hostname

# Conditional to see if you would like to make a new user
echo "Would you like to make a local admin user account? (y or n): "
$newUser = Read-Host
if($newUser -eq 'y') {
# Makes a local user, requesting a username and password
echo "Please enter a username for a new local user: "
$username = Read-Host
echo "Please enter a password for the user '$username': "
$password = Read-Host -AsSecureString
New-LocalUser -Name $username -Password $password
Add-LocalGroupMember -Group "Administrators" -Member $username
}
# check if the user wants to set up networking
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
Write-Host $displayIntID
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
Set-DNSClientServerAddress -InterfaceIndex $intID -ServerAddresses ("\$DNSAddress")
}

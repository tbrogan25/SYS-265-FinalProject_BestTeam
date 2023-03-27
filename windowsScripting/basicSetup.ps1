# This script is intended for use before joining a domain
# It sets up networking, makes a local user, and changes the hostname


# Makes a local user, requesting a username and password
echo "Please enter a username for a new local user: "
$username = Read-Host
echo "Please enter a password for the user '$username': "
$password = Read-Host -AsSecureString
New-LocalUser -Name $username -Password $password
Add-LocalGroupMember -Group "Administrators" -Member $username 

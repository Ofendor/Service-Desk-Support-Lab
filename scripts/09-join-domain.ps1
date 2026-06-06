# This step is used to join the local computer WIND11-01 to the servicedesk.lab domain.
# It prompts the user for credentials and then uses those credentials to add the
# computer to the specified domain. After joining the domain,
# the computer will automatically restart to apply the changes.

$domain = "servicedesk.lab"
$credential = Get-Credential "SERVICEDESK\Administrator"

Add-Computer -DomainName $domain -Credential $credential -Restart

# By the end of this step, you will be able to log in to the computer using
# domain credentials, and the computer will be part of the servicedesk.lab domain.
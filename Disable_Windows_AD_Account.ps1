trap [Exception] {
	write-error $("TRAPPED: " + $_)
	exit 1
	}

function Get-LDAPUser([string]$UserName)
{
if ($TargetDomain -eq $NULL) {
$domain = [ADSI]""
}

else {
$domain = New-Object DirectoryServices.DirectoryEntry("LDAP://$DCip","$TargetDomain\$AdminLogin", "$AdminPassword")
}
$searcher = New-Object DirectoryServices.DirectorySearcher($domain)
$searcher.filter = "(&(objectClass=user)(sAMAccountName=$UserName))"
$searcher.CacheResults = $true
$searcher.SearchScope = "SubTree"
$searcher.PageSize = 1000
$searcher.findall()
}




$TargetAccount = $args[0]
$TargetDomain = $args[1]
$DCip = $args[2]
$AdminLogin = $args[3]
$AdminPassword = $args[4]



$search = Get-LDAPUser $TargetAccount
if(-not $?)	{
		Write-Error "Problem accessing target user's LDAP record."
		exit 1
		}
$account = $search.GetDirectoryEntry()
if(-not $?)	{
		Write-Error "Problem accessing target user's LDAP record."
		exit 1
		}
$account.psbase.InvokeSet("AccountDisabled", "True")
if(-not $?)	{
		Write-Error "Could not disable account, check permissions."
		exit 1
		}
$account.SetInfo()
if(-not $?)	{
		Write-Error "Could not disable account, check permissions."
		exit 1
		}




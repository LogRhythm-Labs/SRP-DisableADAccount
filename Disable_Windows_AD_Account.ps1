# Copyright 2016 LogRhythm Inc.   
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at;
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.

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




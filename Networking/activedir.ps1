param(	
	[Parameter(
	Mandatory=$true,
	HelpMessage="Operation type: all, allUsers, allGroups, user, group, service")] 
	[String]$operation = "all",
	[Parameter( ValueFromPipeline=$true,
	ValueFromPipelineByPropertyName=$true,
	Mandatory=$false,
	HelpMessage="User, group or service to looking for")]
	[String]$arg
)


Function getDomain(){
	try{
		return [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	}
	catch{
		Write-Error -Message 'Current security context is not associated with an Active Directory domain or forest' -ErrorAction Stop
	}
}

Function Search($filter){
	$domainObj = getDomain
	$PDC = ($domainObj.PdcRoleOwner).Name
	$SearchString = "LDAP://"
	$SearchString += $PDC + "/"
	$DistinguishedName = "DC=$($domainObj.Name.Replace('.', ',DC='))"
	$SearchString += $DistinguishedName
	$Searcher = New-Object System.DirectoryServices.DirectorySearcher([ADSI]$SearchString)
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry
	$Searcher.SearchRoot = $objDomain
	$Searcher.filter=$filter
	$Result = $Searcher.FindAll()
	return $Result

}

Function getProperties($query,$name){
	switch($query){
		"user" {
			$filter = "name=$name"
		}
		"service" {
			$filter = "serviceprincipalname=*$name*"
		}
		"group" {
			$filter = "(name=$name)"
		}
		default {
			Write-Error -Message "Error in query type" -ErrorAction Stop
		}
	}

	$Result = Search $filter
	Foreach($obj in $Result){
		Write-Host "------------------------"$obj.properties.name"-------------------------"
		Foreach($opt in $obj.properties){
			$opt
		}
		if($query -eq "group") {
			Write-Host "-----------------------------Nested groups-----------------------------"
			$obj.properties.member
			Write-Host "-----------------------------------------------------------------------`n`n"
		}
		Write-Host "-----------------------------------------------------------------------`n`n"
	}

}

Function listAll($query){

	switch($query){
		"user" {
			$title = "USERS"
			$filter = "samAccountType=805306368"
		}
		"group" {
			$title = "GROUPS"
			$filter = "(objectClass=Group)"
		}
		default {
			Write-Error -Message "Error in query type" -ErrorAction Stop
		}
	}

	Write-Host "--------------------------------------" $title "------------------------------------`n`n"
	Foreach($obj in Search($filter)){
		getProperties $query $obj.properties.name
	}
	Write-Host "-------------------------------------------------------------------------------`n`n`n"
}

switch($operation){
	"all" {
		getDomain
		listAll "user"
		listAll "group"
	}
	"allUsers" {
		listAll "user"
	}
	"allGroups" {
		listAll "group" 
	}
	"user"{
		getProperties "user" $arg
	}
	"group"{
		getProperties "group" $arg
	}
	"service" {
		getProperties "service" $arg
	}
	"domain" {
		getDomain
	}
	default {
		echo "Unknown operation"
	}
}

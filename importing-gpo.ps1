#Building a new GPO, importing an existing configuration, and then linking it to the RDS Session Hosts OU.
$LDAPRoot = [ADSI]"LDAP://RootDSE"
$GPLinkTargetDomain = $LDAPRoot.Get("rootDomainNamingContext")
$URI = "http://github.com/rbergertd/azurerds/raw/master/grouppolicy/GPOBackup.zip"
$RDSOU = "RDS Session Hosts"
$GPLinkTarget = "ou=$RDSOU,"+($GPLinkTargetDomain)
#Create Directory
New-Item -ItemType "directory" -Path "C:\GPOBackup\"
#Download GPO backup folder
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -UseBasicparsing -Uri $URI -OutFile "C:\GPOBackup\GPOBackup.zip"
#Unarchive .zip file
Expand-Archive -LiteralPath C:\GPOBackup\GPOBackup.zip -DestinationPath C:\GPOBackup
#Create OU on Domain
New-ADOrganizationalUnit $RDSOU
#Create Security Group, GPO, import policy backup, and link to Domain root.
new-adgroup -Name "RDS Users" -SamAccountName RDSUsers -GroupCategory Security -GroupScope Global -DisplayName "RDS Users" -Description "RDS Users"
new-gpo -name "ConfigureRDSSessionHosts" -Comment "Configure the appropriate GPO's for a default session hosts configuration."
import-gpo -backupid 71D7905A-246C-40DA-9DBC-85293A13D5E9 -TargetName "ConfigureRDSSessionHosts" -Path C:\GPOBackup
new-gplink -name "ConfigureRDSSessionHosts" -Enforced Yes -LinkEnabled Yes -Target $GPLinkTarget
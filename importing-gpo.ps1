#Building a new GPO, importing an existing configuration, and then linking it to the WVD Session Hosts OU.
$LDAPRoot = [ADSI]"LDAP://RootDSE"
$GPLinkTargetDomain = $LDAPRoot.Get("rootDomainNamingContext")
$URI = "http://github.com/rbergertd/rds/raw/master/grouppolicy/GPOBackup.zip"
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
#Create GPO, import policy backup, and link to Domain root.
new-gpo -name "ConfigureRDSGraphics" -Comment "Configure the appropriate GPO's for best graphic performance via RDP"
import-gpo -backupid E802E58D-C478-4AB6-8437-830DF35761AA -TargetName "ConfigureRDSGraphics" -Path C:\GPOBackup
new-gplink -name "ConfigureRDSGraphics" -Enforced Yes -LinkEnabled Yes -Target $GPLinkTarget
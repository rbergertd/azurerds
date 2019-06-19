Import-Module Az
Connect-AzAccount
#Get Rrsource Group name from Vertex configuration
$rgName = "RB-automationAccount"
$rgLocation 
#Parameter OR a variable? We may just want to automatically name the automation account
$autoAcctName = "RBAutomationAcct24812"
#Vertex Parameter for the Automation Account credential username and password
$user = "rberger"
$password = ConvertTo-SecureString "C@Pc0m10" -AsPlainText -Force
#Combine the username and password into a PSCredential
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password
#Set the RunBook tags
$tags = @{"tag01"="value01"; "tag02"="value02"}
#Make the Automation Account - using Resource Group and location that was selected for initial deployment
New-AzAutomationAccount -Name $autoacctname -Location "East US 2" -ResourceGroupName $rgname 
#Create the Automation Account credential using the user/password variables.
New-AzAutomationCredential -AutomationAccountName $autoacctname -Name "Default Credential" -Value $credential -ResourceGroupName $rgname
#Store the runbooks locally on the PowerShell proxy servers - these could be managed via a GitHub Repo and then stored locally. This import cmdlet only allows for a local path.
Import-AzAutomationRunbook -Path .\GraphicalRunbook06.graphrunbook -Tags $Tags -ResourceGroup "ResourceGroup01" -AutomationAccountName "AutomationAccount01" -Type GraphicalPowershell
#Set the Business Hours Schedule - a Vertex Parameter
New-AzAutomationSchedule


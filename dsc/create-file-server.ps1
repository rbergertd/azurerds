Configuration FileServer
{
	Import-DscResource -Module PSDesiredStateConfiguration, xStorage, xSmbShare, cNtfsAccessControl
	
	Node localhost
	{
        
        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            FSLabel = "UserProfileDisks"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        xWaitforDisk Disk3
        {
            DiskNumber = 3
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk AddtlDataDisk {
            DiskNumber = 3
            DriveLetter = "G"
            FSLabel = "Data"
            DependsOn = "[xWaitForDisk]Disk3"
        }
        
        File 'UPD'
		{
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = 'F:\UserProfileDisks'
		}
		
		File 'Data'
		{
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = 'G:\AutoDesk Network Share'
		}
		
		xSmbShare 'Share1'
		{
			Ensure = 'Present'
			Name   = 'UserShare1'
			Path = 'F:\UserProfileDisks'
			FullAccess = 'Everyone'
			DependsOn = '[File]UPD'
		}
		
		xSmbShare 'Share2'
		{
			Ensure = 'Present'
			Name   = 'UserShare2'
			Path = 'G:\AutoDesk Network Share'
			FullAccess = 'Everyone'
			DependsOn = '[File]Data'
		}
		
		cNtfsPermissionEntry 'UPD Permissions' {
			Ensure = 'Present'
			DependsOn = "[File]UPD"
			Principal = 'Authenticated Users'
			Path = 'F:\UserProfileDisks'
			AccessControlInformation = @(
				cNtfsAccessControlInformation
				{
					AccessControlType = 'Allow'
					FileSystemRights = 'Read'
					Inheritance = 'ThisFolderSubfoldersAndFiles'
					NoPropagateInherit = $false
				}
			)
		}
		
		cNtfsPermissionEntry 'Data Permissions' {
			Ensure = 'Present'
			DependsOn = "[File]Data"
			Principal = 'Authenticated Users'
			Path = 'G:\AutoDesk Network Share'
			AccessControlInformation = @(
				cNtfsAccessControlInformation
				{
					AccessControlType = 'Allow'
					FileSystemRights = 'Read'
					Inheritance = 'ThisFolderSubfoldersAndFiles'
					NoPropagateInherit = $false
				}
			)
		}
		
	}
}

FileServer -OutputPath C:\
Start-DscConfiguration -Force -Wait -path C:\ -ComputerName localhost -Verbose
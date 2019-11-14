There are 2 powershell scripts contained in this demo.
1. **BuildWorkspaceEnvironment.ps1**(optional)
	- This script creates a new resource group and Log Analytics work space for for sending test log events <br />
	Example: <br />
	``
.\BuildWorkSpaceEnvironment.ps1 -location <Region> -Name <Workspace Name> 
``

2.  **PostWorkspaceLog.ps1**
	- This is a refactored script taken from a sample provided at: https://docs.microsoft.com/en-us/azure/azure-monitor/platform/data-collector-api
	- This script allows you to imput your workspace information, custom log type as well well as timestamp information. <br /> 
	Example: <br />
	``
.\PostWorkspaceLog.ps1 -workspaceName <LA Workspace Name> 
                                        -ResourceGroupName <Resource Group Name> 
										-LogType <Name of Custome Log type> 
										-UseSampleJson
``

**NOTE:** <br />
	- If creating a logtype for the first time, it can take up to 15 minutes before you see the event in your workspace
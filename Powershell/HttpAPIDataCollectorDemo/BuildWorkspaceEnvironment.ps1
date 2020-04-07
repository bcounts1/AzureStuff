param (
 $location = "East US",
 $Name = "MyWSPDemo",
 [Parameter(Mandatory=$true)]
 $subscription
)
$wspname = $name + "WSP"
Set-AzContext -SubscriptionName $subscription
New-AzResourceGroup -Name $name -Location $location
New-AzOperationalInsightsWorkspace -Name $wspname -Location $location -Sku "Standard" -ResourceGroupName $Name


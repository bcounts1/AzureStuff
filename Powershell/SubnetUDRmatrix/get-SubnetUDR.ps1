param (
    $subscription
)
Set-AzContext -Subscription $subscription
$virtualnetworks = get-azvirtualnetwork 

foreach ($network in $virtualnetworks){
    $network.subnet | %{get-azvirtualnetworksubnetconfig -Name $_.Name -VirtualNetwork $network | `
         select @{n="VNET";e={$network.Name}}, `
                @{n="Subnet";e={$_.Name}}, `
                @{n="RouteTable";e={(get-AzResource -ResourceID $_.routetable.id).Name}}, `
                @{n="NetworkSecurityGroup";e={(Get-AzResource -ResourceId $_.networksecuritygroup.id).Name}}
    
            }
        
}
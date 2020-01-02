param (
    $subscription
)
Set-AzContext -Subscription $subscription
$virtualnetworks = get-azvirtualnetwork 

$obj = foreach ($network in $virtualnetworks){
    $network.subnet | %{get-azvirtualnetworksubnetconfig -Name $_.Name -VirtualNetwork $network | `
         select @{n="VNET Name";e={$network.Name}}, `
                @{n="Subnet Name";e={$_.Name}}, `
                @{n="routetable";e={$_.routetable.id}}, `
                networksecuritygroup}
    
}
Return $obj

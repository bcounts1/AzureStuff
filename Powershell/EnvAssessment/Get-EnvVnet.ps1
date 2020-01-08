param (
    $subscription
)

if ($subscription) {
    Set-AzContext -SubscriptionName $subscription
}

Get-AzVirtualNetwork | select `
@{
    n="Name";
    e={$_.Name}
}, `
@{
    n="Location";
    e={$_.Location}
}, `
@{
    n="AddressPrefixes";
    e={$_.AddressSpace.AddressPrefixes -join ","}
}, `
@{
    n="ProvisioningStatus";
    e={$_.ProvisioningState}
}, `
@{
    n="CustomDNS";
    e={$_.DhcpOptions.DnsServers -join ","}
}, `
@{
    n="Peers";
    e={($_.VirtualNetworkpeerings | select name).Name -join "/"}
}
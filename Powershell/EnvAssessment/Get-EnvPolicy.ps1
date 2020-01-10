param (
    $subscription
)
if ($subscription) {
    Set-AzContext -SubscriptionName $subscription
}

Get-AzPolicyAssignment  | select `
@{
    n = "Name";
    e = {$_.ResourceName}
}, `
@{
    n = "Scope";
    e = {$_.Properties.Scope}
}, `
@{
    n = "Description";
    e = {$_.Properties.description}
}
param (
    $subscription
)
$vaults = Get-AzureRmRecoveryServicesVault
foreach ($vault in $vaults){
    Get-AzureRmRecoveryServicesVault -Name $vault.Name -ResourceGroupName $vault.ResourceGroupName | Set-AzureRmRecoveryServicesVaultContext
    $fnames = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" | select  -ExpandProperty friendlyname
    foreach ($name in $fnames)
    {
    $nameContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType "AzureVM" -Status "Registered" -FriendlyName $name
    Get-AzureRmRecoveryServicesBackupItem -Container $nameContainer -WorkloadType "AzureVM" | select `
     @{n="vmName";e={$name}}, `
     @{n="VaultName";e={$vault.Name}}, `
     ContainerName,LatestRecoveryPoint
    }

}




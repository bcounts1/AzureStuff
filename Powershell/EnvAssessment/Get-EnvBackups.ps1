Param (
    $subscription
)

if ($subscription){
    Set-AzContext -SubscriptionName $subscription
}

$vaults = Get-AzRecoveryServicesVault

Foreach ( $vault in $vaults){
    $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.ID
    $policy | select `
    @{
        n="VaultName";
        e={$vault.Name}
    }, `
    @{
        n="Location";
        e={$vault.Location}
    }, `
    @{
        n="VaultRedundancySetting"
        e={(Get-AzRecoveryServicesBackupProperties -Vault $vault).BackupStorageRedundancy}
    }, `
    @{
        n="PolicyName";
        e={$psitem.Name}
    }, `
    WorkloadType, `
    BackupManagementType, `
    SchedulePolicy, `
    RetentionPolicy
}
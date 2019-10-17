#Change the variable 'VMName'.
# The script will search Virtual Machines across all subscriptions in your tenant

$name = "VMName"      
        If ($name){
        Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' } | ForEach-Object {
        Select-AzSubscription $_ | Out-Null;
        Get-AzVM -name $Name | Select-Object `
            Name, 
            ResourceGroupName, 
            Location, 
            @{Name = "Agent Linux"; Expression = { $_.OSProfile.LinuxConfiguration.ProvisionVMAgent } },
            @{Name = "Agent Windows"; Expression = { $_.OSProfile.WindowsConfiguration.ProvisionVMAgent } },  
            @{Name = "VM Size"; Expression = { $_.HardwareProfile.vmSize } }, 
            @{Name = "Offer"; Expression = { $_.StorageProfile.ImageReference.Offer } },  
            @{Name = "Sku"; Expression = { $_.StorageProfile.ImageReference.Sku } }, 
            @{Name = "OSDisk Size"; Expression = { $_.StorageProfile.OsDisk.DiskSizeGB } }, 
            @{Name = "Attached "; Expression = { $_.StorageProfile.DataDisks.count} } -WarningAction SilentlyContinue | Format-Table
        
} }

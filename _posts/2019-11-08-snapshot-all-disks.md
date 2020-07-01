---
title: Snapshot all Disks for a single Virtual Machine
excerpt: "How to Snapshoot all Disks for a single Virtual Machine"
classes: wide
categories: 
    - PowerShell 
    - Virtual Machines
tags: 
    - PowerShell 
    - Virtual Machines 
    - Snapshots

---

This PowerShell Script will do a snapshot for SO and Data disks.


PowerShell Command:
{% highlight PowerShell %}
New-SnapshotAll -VM [string] -ResourceGroup [string] -ResourceGroupSnapShot [string] -Subscription [string]
New-SnapshotAll -VM 'VM-Name' -ResourceGroup 'RG-Name' -ResourceGroupSnapShot 'Snapshot-RG-Name' -Subscription 'SubscriptionName'
{% endhighlight %}

{% highlight PowerShell %}
function New-SnapshotAll {
param
(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$VM,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]$ResourceGroup,
    [Parameter(Mandatory = $True, ValueFromPipeline = $true)]
    [string]$ResourceGroupSnapShot,
    [Parameter(Mandatory = $false)]
    [string]$Location = "northeurope",
    [Parameter(Mandatory = $False)]
    [string]$Subscription
)
Select-AzSubscription -Subscription $Subscription | Out-Null

$VmStatus = Get-AzVM -Status -Name $VM -ResourceGroupName $ResourceGroup
foreach ($Status in $VmStatus.Statuses)
{
    if ($Status.Code -eq "PowerState/running")
    {
        Write-Host "$VM status: $($Status.Code)" -ForegroundColor Red
        Write-Host "Need to Stop/Deallocate $VM" -ForegroundColor Yellow
        $Continue = Read-Host "Are you sure? Enter yes to continue" 
        if ($Continue.ToLower() -ne 'yes')
        {
            Write-Host "$VM cannot be snapshotted while running" -ForegroundColor Yellow
        }
        "Stopping $VM"
        Stop-AzVM -Name $VM -ResourceGroupName $ResourceGroup -Force | Out-Null
    }
}

Write-Host "$VM Stopped" -ForegroundColor Green

Write-Host "Start creating Snapshot for OS disk" -ForegroundColor Yellow

$OsDiskName = (Get-AzVM -Name $VM -ResourceGroupName $ResourceGroup).StorageProfile.OSDisk.Name 
$OsDiskId = (Get-AzDisk -Name $OsDiskName -ResourceGroupName $ResourceGroup).Id
$OsDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $OsDiskId -Location $Location -CreateOption "Copy"
$SnapshotName = $((Get-Date -Format s).Replace(":", "-") + "-" + $OsDiskName )
If ($SnapshotName.Length -ge 63)
{
    $SnapshotName = $SnapshotName.Substring(0, 63)
}
New-AzSnapshot -Snapshot $OsDiskSnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroupSnapShot | Out-Null

Write-Host "Snapshot for SO disk Completed" -ForegroundColor Green

$DataDisks = (Get-AzVM -Name $VM -ResourceGroupName $ResourceGroup).StorageProfile.DataDisks.Name
foreach ($DataDisk in $DataDisks)
{
    $DataDiskID = (Get-AzDisk -Name $DataDisk -ResourceGroupName $ResourceGroup).Id
    $DataDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri $DataDiskID -Location $Location -CreateOption "Copy"
    $SnapshotName = $((Get-Date -Format s).Replace(":", "-") + "-" + $DataDisk )
    If ($SnapshotName.Length -ge 63)
    {
        $SnapshotName = $SnapshotName.Substring(0, 63)
    }

    Write-Host "Start creating Snapshot for Data disk" -ForegroundColor Yellow
    New-AzSnapshot -Snapshot $DataDiskSnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroupSnapShot -AsJob | Out-Null
}

Write-Host "Snapshot for Data disks Completed" -ForegroundColor Green

        $Continue1 = Read-Host "Enter 'yes' to Start the VM $VM"
        if ($Continue1.ToLower() -ne 'yes')
        {
            Write-Host "$VM will not be started" -ForegroundColor Yellow
        }
        else 
        {
            Write-Host "Starting $VM" -ForegroundColor Yellow
            Start-AzVM -Name $VM -ResourceGroupName $ResourceGroup | Out-Null
            Write-Host "$VM is running" -ForegroundColor Green
        }
}

{% endhighlight %}
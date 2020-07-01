---
title: Remove Snapshots older than 15 days
excerpt: "Automation Account to Start/Stop Virtual Machines at the same time"
#classes: wide
toc: true
toc_sticky: false
categories: 
    - PowerShell 
    - Automation 
    - Snapshots
tags: 
    - PowerShell 
    - Snapshots

---

This PowerShell Script will remove all Snapshots older than 15 days across all your subscriptions


## Create an Automation Account

If you don't already have an automation account, you need to create one.

![img](/assets/images/2019/11/automation.png) 


## PowerShell Script
Create a Runbook with the PowerShell script below.

**Note:**
 To change the days to keep the snapshots, just modify the value 15
 UtcNow.AddDays(**-15**))}
{: .notice--info}

{% highlight PowerShell %}

<#
    .Author
        Bruno Corsino - bruno.corsino@cloudidentity.pt
    .SYNOPSIS
        Script to remove snapshots older than 15 days.
#>

$ConnectionName = "AzureRunAsConnection"
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $ConnectionName
    "Logging in to Azure..."
    Login-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
    -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 


Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' } | ForEach-Object {
    $sub = Select-AzSubscription $_;
Get-AzSnapshot | select Name, ResourceGroupName, TimeCreated , DiskSizeGB | Where-Object {($_.TimeCreated) -lt ([datetime]::UtcNow.AddDays(-15))} | Remove-AzSnapshot
}

{% endhighlight %}


## Create a Schedule

The last step is to create a Schedule for your Automation Account.

In my case i used a schedule that runs every week on monday

![img](/assets/images/2019/11/schedule.png)


**Don't forget to attach it to your Automation Account.**
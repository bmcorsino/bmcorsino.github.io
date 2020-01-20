---
layout: post
title: Start/Stop Virtual Machines at the same time
description: "Automation Account to Start/Stop Virtual Machines at the same time"
modified: 2019-11-07
tags: [PowerShell, Automation, Virtual Machines]
categories: [PowerShell, Automation, Virtual Machines]
image:
    feature: /images/abstracy-2.jpg
    credit: dargadgetz
---
This script will allow you to use an Automation Account to Start and Stop all Virtual Machines selected at the same time.

Pre-Requisits:
 - [Owner Priviledges under the Subscription(s)](#check-your-permisions-under-the-subscription)
 - [Automation Account](#create-an-automation-account)
 - [Configure Virtual Machines Tags](#add-tags-to-virtual-machine)
 - [Add PowerShell script](#powershell-script)
 - [Create a schedule](#create-a-schedule)


### Check your permisions under the Subscription

To be able to create an Automation Account you need the Owner RBAC role under the subscription.

![img](/images/2019/11/subscription.png)

### Create an Automation Account

If you don't already have an automation account, you need to create one.

![img](/images/2019/11/automation.png) 


### Add Tags to Virtual Machine

You need to configure 3 Tags in Virtual Machines :


![img](/images/2019/11/start-stop-tags.png) 


  - `startup : 09:00` 
  - `shutdown : 19:00`  
  - `StartStopRule` - `on` / `off`
    - If the flag is `on`  Will turn on/off 
    - If the flag is `off` the rule will not apply. Meaning that the virtual machine will not Start or Stop.


## PowerShell Script

Create a Runbook with the PowerShell script below.

**_Note_**: You need to change the variables below:

{% highlight PowerShell %}
$AutomationAccount = "AutomationName"
$ResourceGroup = "ResourceGroup"
$ScheduleName = "schedule-Name"
$ConnectionName = "AzureRunAsConnection"
{% endhighlight %}

{% highlight PowerShell %}

$AutomationAccount = "AutomationName"
$ResourceGroup = "ResourceGroup"
$ScheduleName = "schedule-Name"
$ConnectionName = "AzureRunAsConnection"

if ((get-date).DayOfWeek.value__ -in 1..5){
    
    Try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $ConnectionName

        "Logging in to Azure..."
        Login-AzAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 

        #Get the offset of the Schedule because the time in Azure Automation is in UTC
        $Time = ((get-date (Get-AzAutomationSchedule -Name $ScheduleName -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount).NextRun.ToString("HH:mm")).AddHours(-(Get-AzAutomationSchedule -Name $ScheduleName -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount).Interval)).ToString("HH:mm")

        #List all vms filtering by tags startup, shutdown and StartStopRule
        $VMs = Get-AzVM -Status | Where-Object {$_.Tags.Keys -eq "startup" -or $_.Tags.Keys -eq "shutdown" -and $_.Tags.Keys -eq "StartStopRule" }

        #Displays the time used as reference
        Write-Output "Time: $($Time)"
        ForEach ($VM in $VMs) 
        {        
            Write-Output "Processing VM $($VM.Name). StartTime $($VM.tags.startup). ShutdownTime $($VM.tags.shutdown). StartStopRule $($VM.tags.StartStopRule)"
            
            #If is shutdown time and vm is running
            if ($VM.tags.shutdown -eq $Time -and $VM.tags.StartStopRule -eq "on" -and $vm.PowerState -eq "VM running") {
                Write-Output "Shuting down: $($VM.Name)"
                Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
            }
        
            #If is start time and vm is NOT running
            if ($VM.tags.startup -eq $Time -and $VM.tags.StartStopRule -eq "on" -and $vm.PowerState -eq "VM deallocated") {
                Write-Output "Starting: $($VM.Name)"
                Start-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName
            }
        }
    }
    
    Catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
} 

{% endhighlight %}


### Create a Schedule

The last step is to create a Schedule for your Automation Account.

![img](/images/2019/11/schedule.png)

Don't forget to attach it to your Automation Account.
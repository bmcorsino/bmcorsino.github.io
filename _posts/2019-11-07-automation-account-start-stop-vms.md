---
layout: post
title: Start/Stop Virtual Machines at the same time
description: "Automation Account to Start/Stop Virtual Machines at the same time"
modified: 2019-11-07
tags: [PowerShell, Automation, Virtual Machines]
categories: [PowerShell]

---
You need to configure 3 Tags in Virtual Machines :
  - `startup` - startup hour. Ex: 09:00
  - `shutdown`  - shutdown hour. Ex: 18:00
  - `StartStopRule` - `on` / `off`
    - If the flag is `on`  Will turn on/off 
    - If the flag is `off` the rule will not apply Meaning that the virtual machine will not Start or Stop.


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



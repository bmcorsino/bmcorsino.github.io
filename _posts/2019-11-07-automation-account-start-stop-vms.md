---
layout: post
title: Automation Account to Start/Stop Virtual Machines
description: "Automation Account to Start/Stop Virtual Machines"
modified: 2019-11-07
tags: [PowerShell, Automation, Virtual Machines]
categories: [PowerShell]

---



{% highlight PowerShell %}

$AutomationAccount = "automation-account-tech-qua"
$ResourceGroup = "tech-automation-qua-ne-rg"
$ScheduleName = "schedule"
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



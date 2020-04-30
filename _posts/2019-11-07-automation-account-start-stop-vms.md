---
title: Start/Stop Virtual Machines at the same time
excerpt: "Automation Account to Start/Stop Virtual Machines at the same time"
toc: true
toc_sticky: false
categories: 
    - PowerShell 
    - Automation 
    - Virtual Machines
tags: 
    - PowerShell
    - Automation
    - Virtual Machines

---

This script will allow you to use an Automation Account to Start and Stop all Virtual Machines selected at the same time based on tags.


## Subscription Owner Role

To be able to create an Automation Account with a `Run As Account` you need the Owner RBAC role under the subscription.

![img](/assets/images/2019/11/subscription.png)

## Create an Automation Account

If you don't already have an automation account, you need to create one.

![img](/assets/images/2019/11/automation.png) 


## Add Tags to Virtual Machine

You need to configure 3 Tags in Virtual Machines :


![img](/assets/images/2019/11/start-stop-tags.png) 


 **Tip**
  You can use only the `Startup` or the `Shutdown` rule
  {: .notice--success}

  - `startup : 09:00` 
  - `shutdown : 19:00`  
  - `StartStopRule` - `on` / `off`
    - If the flag is `on`  it Will turn on/off the virtual machine
    - If the flag is `off` the rule will not be applied.
  


## PowerShell Script

Create a Runbook with the PowerShell script below.

**Note:**
 Be aware that you need to change the values inside the variables
{: .notice--info}




```powershell
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
```


## Create a Schedule

The last step is to create a Schedule for your Automation Account.

![img](/assets/images/2019/11/schedule.png)


Don't forget to attach it to your Automation Account.

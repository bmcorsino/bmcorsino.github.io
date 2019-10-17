## Automation Account para fazer Start/Stop ás máquinas virtuais com flag On/Off.

- Todas as máquinas para fazerem start e stop devem conter 3 flags:
  - `startup` - indicar a hora de startup. Ex: 09:00
  - `shutdown`  - indicar a hora de shutdown. Ex: 18:00
  - `StartStopRule` - on / off
    - Se a flag estiver `on` a máquina irá ligar e desligar consoante o horario aplicado.
    - Se a flag  estiver `off` quer dizer que o script nao se aplica à máquina.



**_Nota_**: é necessário alterar os parametros em baixo, consoante o ambiente.
````Ps
$AutomationAccount = "automation-account"
$ResourceGroup = "automation-rg"
$ScheduleName = "schedule"
$ConnectionName = "AzureRunAsConnection"
````

**_Script Completo:_**
````Ps
$AutomationAccount = "automation-account"
$ResourceGroup = "automation-rg"
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

````

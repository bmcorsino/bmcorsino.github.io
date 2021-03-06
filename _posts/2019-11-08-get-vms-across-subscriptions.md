---
title: Get Virtual Machines Across Subscriptions
excerpt: "How to Get Virtual MAchines across subscriptions"
classes: wide
categories: 
    - Virtual Machines
tags: 
    - PowerShell
    - Virtual Machines
---

This Script will search all Virtual Machines across your subscriptions that has the state `Enable`.


How to use it:

Command to return a specific Virtual Machine

{% highlight PowerShell %}
Get-MyVM -Name <VMName>
{% endhighlight %}

Command to return all Virtual Machines

{% highlight PowerShell %}
Get-MyVM
{% endhighlight %}

{% highlight PowerShell %}
function Get-MyVm {
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$Name
    )      
        If ($name){
        Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' } | ForEach-Object {
        Select-AzSubscription $_ | Out-Null;
        Get-AzVM -name $Name         
                } }
        else {
        
        Get-AzSubscription | Where-Object { $_.State -eq 'Enabled' } | ForEach-Object {
        Select-AzSubscription $_ | Out-Null;
        Get-AzVM 
            }
      
       }
}
{% endhighlight %}
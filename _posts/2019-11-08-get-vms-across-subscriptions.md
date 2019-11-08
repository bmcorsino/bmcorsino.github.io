---
layout: post
title: Get Virtual Machines Across Subscriptions
description: "How to Get Virtual MAchines across subscriptions"
modified: 2019-11-087
tags: [PowerShell, Subscriptions, Virtual Machines]
categories: [PowerShell, Virtual Machines]

---

This Script will search all Virtual Machines across your subscriptions that has the state `Enable`.


How to use it:

Command to return a specific Virtual Machine

``` Powershell
Get-MyVM -Name <VMName>
```

Command to return all Virtual Machines

``` Powershell
Get-MyVM
```

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
---
layout: post
title: Check if a domain is verified on Azure AD / Office 365
description: "Check if a domain is verified on Azure AD / Office 365"
modified: 2020-01-28
tags: [PowerShell, Domains]
categories: [PowerShell, Domains]
image:
    feature: categories/powershell.jpg
---


This PowerShell will help you to check if a domain is verified on an Azure AD / Office 365 Tenant


**Possible Results:**                                   
    1. Domain is Managed                           
    2. Domain is Federated   
    3. Domain is not verified on Azure AD / Office 365



```powershell
function Test-Domain {

      param(

             [Parameter(mandatory=$true)]

             [string]$DomainName

       )

       $descriptions = @{

              Unknown   = 'Domain does not exist in Office 365/Azure AD'

              Managed   = 'Domain is verified but not federated'

              Federated  = 'Domain is verified and federated'

       }

      $response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/getuserrealm.srf?login=user@$DomainName&xml=1"

     if($response -and $response.StatusCode -eq 200) {

           $namespaceType = ([xml]($response.Content)).RealmInfo.NameSpaceType

           New-Object PSObject -Property @{

                    DomainName = $DomainName

                    NamespaceType = $namespaceType

                    Details = $descriptions[$namespaceType]

           } | Select-Object DomainName, NamespaceType, Details

    } else {

        Write-Error -Message 'Domain could not be verified. Please check your connectivity to login.microsoftonline.com'

    }

} 

cls  
echo "##################################################################"  
echo "#    Check if a domain is verified on Azure AD / Office 365      #"  
echo "#                                                                #"
echo "#    Possible Results:                                           #"
echo "#            1. Domain is Managed                                #"
echo "#            2. Domain is Federated                              #"
echo "#            3. Domain is not verified on Azure AD / Office 365  #" 
echo "#                                                                #"
echo "##################################################################"  
echo ""
echo ""
echo "Command to check a domain"
echo ""
echo "        Test-Domain microsoft.com"
echo ""
```
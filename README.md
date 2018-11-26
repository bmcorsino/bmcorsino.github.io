# Cloud Identity Portugal


Azure B2B PowerShell Tips and Tricks

How to change the invitation language
 

 ```PowerShell
$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$messageInfo.customizedMessageBody = “Hey there! Check this out. I created an invitation through PowerShell”
$messageinfo.MessageLanguage = "it"
New-AzureADMSInvitation -InvitedUserEmailAddress user@contoso.com -InvitedUserDisplayName "UserName" -InviteRedirectUrl https://myapps.microsoft.com -InvitedUserMessageInfo $messageInfo -SendInvitationMessage $true 
```


 
To change the language, we need to define it:
 
$messageinfo.MessageLanguage = "it"
 
 
We can use the languages bellow:
 
	1. 1. de: German
	2. 2. es: Spanish
	3. 3. fr: French
	4. 4. it: Italian
	5. 5. ja: Japanese
	6. 6. ko: Korean
	7. 7. pt-BR: Portuguese (Brazil)
	8. 8. ru: Russian
	9. 9. zh-HANS: Simplified Chinese
	10. 10. zh-HANT: Traditional Chinese

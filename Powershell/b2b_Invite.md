How to change the invitation language
 

 ```powershell
$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$messageInfo.customizedMessageBody = “Hey there! Check this out. I created an invitation through PowerShell”
$messageinfo.MessageLanguage = "it"
New-AzureADMSInvitation -InvitedUserEmailAddress v-brlibe@microsoft.com -InvitedUserDisplayName "Bruno Corsino" -InviteRedirectUrl https://myapps.microsoft.com -InvitedUserMessageInfo $messageInfo -SendInvitationMessage $true 
 ```

 
To change the language, we need to define it:

```powershell
$messageinfo.MessageLanguage = "it"
 ```
 
We can use the languages bellow:
 
	1.  de: German
	2.  es: Spanish
	3.  fr: French
	4.  it: Italian
	5.  ja: Japanese
	6.  ko: Korean
	7.  pt-BR: Portuguese (Brazil)
	8.  ru: Russian
	9.  zh-HANS: Simplified Chinese
	10. zh-HANT: Traditional Chinese

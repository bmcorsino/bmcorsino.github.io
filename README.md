# Cloud Identity Portugal


Azure B2B PowerShell Tips and Tricks

```powershell
$messageInfo = New-Object Microsoft.Open.MSGraph.Model.InvitedUserMessageInfo
$messageInfo.customizedMessageBody = “Hey there! Check this out. I created an invitation through PowerShell”
$messageinfo.MessageLanguage = "it"
New-AzureADMSInvitation -InvitedUserEmailAddress user@contoso.com -InvitedUserDisplayName "UserName" -InviteRedirectUrl https://myapps.microsoft.com -InvitedUserMessageInfo $messageInfo -SendInvitationMessage $true
```

# GetExchangeOnlineMailboxCount.ps1
#
# This script connects to Exchange Online to gather a count of user mailboxes that have been used by an active user in the last 90 days
#
# github.com/jasonsford

# Get the current version of PowerShell
[int]$CheckForPSVersion = $PSVersionTable.PSVersion.Major

# Verify the current version of PowerShell is at least 5.0 or newer in order to run the Install-Module cmdlet
if($CheckForPSVersion -lt 5)
{
    Write-Host "This script requires PowerShell version 5.1 or later. Please update the installed version to continue or run this script from a different machine."
    Exit
}

# Verify that the ExchangeOnlineManagement module is installed and prompt the user to install it if not present
$CheckForExModule = Get-Module -Name ExchangeOnlineManagement -ListAvailable

if($CheckForExModule.Count -eq 0)
{
    Write-Host "The Exchange Online Management v2 PowerShell module is not installed."
    $Dialog = Read-Host -Prompt "Are you sure you want to install the Exchange Online Management v2 PowerShell module? [Y] Yes [N] No"
    If($Dialog -match "[yY]")
    {
        Install-Module -Name ExchangeOnlineManagement -Confirm:$false -AllowClobber -Force
    }
    Else
    {
        Write-Host "The Exchange Online Management v2 PowerShell module is required to run the proper cmdlets in Office 365. Please install the module to continue using this script."
        Exit
    }
}

# Import the ExchangeOnlineManagement module and gather credentials for the user who will authenticate to Office 365
Import-Module ExchangeOnlineManagement
$UserCredential = Get-Credential
Connect-ExchangeOnline -Credential $UserCredential -ShowBanner:$false

(Get-Mailbox -ResultSize Unlimited –RecipientTypeDetails UserMailbox | Where {(Get-MailboxStatistics $_.Identity).LastLogonTime -gt (Get-Date).AddDays(-90)}).count
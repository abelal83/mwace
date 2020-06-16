$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$DebugPreference = 'Continue' # switch to ignore in production mode
$WarningPreference = 'Continue'

# check environment is compatible
if ($PSVersionTable['PSVersion'].Major -lt 7) {
    Write-Warning "This has been tested on Powershell Core 7.0.0 and may not work on $($PSVersionTable['PSVersion'].Major)"
    Write-Warning "Will continue but beware of the bugs :) !"
}

$site = "www.mwam.com" 
$config = Get-Content "$PSScriptRoot\appsettings.json" -Raw |  ConvertFrom-Json

Write-Information "Importing scripts..."
. ./Get-Ssl.ps1
. ./Format-Email.ps1
. ./Start-SslTest.ps1
Write-Information "Import complete"

Write-Information "Starting test againt $site"
$result = Start-SslTest -Config $config -Uri $site
Format-Email -Config $config -Object $result -ReportOnly
Write-Information "Completed test"

# without properly configured email server this won't work
# Send-MailMessage -Attachments "$PSScriptRoot\report.html" -Subject "SSL status of $site" `
#     -BodyAsHtml -To $config.email_to -SmtpServer $config.email_server
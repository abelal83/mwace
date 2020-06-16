
function Format-Email{
    param(
        [psobject] $Config,
        [psobject] $Object,
        [switch] $ReportOnly
    )

    $reportPath = "$PSScriptRoot\report.html"
    Write-Information "Saving report to $reportPath"
    $Object | ConvertTo-Html -Head $Config.email_format | Out-File $reportPath -Force

    if ($ReportOnly.IsPresent) {
        Write-Information "Report only, email won't be sent"
        return 
    }
    
    Send-MailMessage -Attachments "$PSScriptRoot\report.html" -Subject "SSL status of $site" `
    -BodyAsHtml -To $Config.email_to -SmtpServer $Config.email_server
    
}

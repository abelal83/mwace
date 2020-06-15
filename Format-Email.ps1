
function Format-Email{
    param(
        [psobject] $Config,
        [psobject] $object
    )

    $reportPath = "$PSScriptRoot\report.html"
    Write-Information "Saving report to $reportPath"
    $object | ConvertTo-Html -Head $config.email_format | Out-File $reportPath -Force
}

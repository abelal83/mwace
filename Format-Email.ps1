
function Format-Email{
    param(
        [psobject] $Config,
        [psobject] $json
    )

    $json | ConvertTo-Html -Head $config.email_format | Out-File "$PSScriptRoot\report.html" -Force
}

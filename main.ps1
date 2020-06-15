$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'
$DebugPreference = 'Continue' # switch to ignore in production mode

$site = "www.mwam.com" 
$config = Get-Content "$PSScriptRoot\appsettings.json" -Raw |  ConvertFrom-Json

. ./Get-Ssl.ps1
. ./Format-Email.ps1
. ./Start-SslTest.ps1

Start-SslTest -Config $config -Uri $site
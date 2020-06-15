
function Start-SslTest {
    param(
        $Config,
        $Uri
    )
    
    $result = Get-Ssl -Config $config -Uri $site

    $retryCount = 0
    $sleep = 10
    if ($result.status -ne "READY") {
    
        Write-Information "SSL result not ready, retrying in $sleep seconds..."
        while ($retryCount -lt $config.ssl_endpoint_retry_count) {
            Start-Sleep -Seconds ($sleep += $sleep)
            # calls to ssls labs are async
            $result = Get-Ssl -Config $config -StartNew $false -Uri $site 
    
            $retryCount += 1
        }
    }
    
    if ($retryCount -ge $config.ssl_endpoint_retry_count) {
        Write-Information "SSL result not ready. Set ssl_endpoint_startNew to false to use cached version"
        Write-Error "Queried SSL status $($config.ssl_endpoint_retry_count) times in last $sleep seconds with no succees. Please try again later."
    
    }
    
    $result.endpoints | Add-Member -Name site -Value $site -MemberType NoteProperty
    Format-Email -Config $config -Object $result.endpoints
}
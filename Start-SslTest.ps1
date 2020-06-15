
function Start-SslTest {
    param(
        $Config,
        $Uri
    )
    
    Write-Information "Getting SSL report for $site"
    $result = Get-Ssl -Config $config -Uri $site

    $retryCount = 0
    $sleep = $config.sssl_endpoint_retry_sleep
    if ($result.status -ne "READY") {    
        
        while ($retryCount -lt $config.ssl_endpoint_retry_count) {
            Write-Information "SSL result not ready, retrying in $sleep seconds..."
            Start-Sleep -Seconds $sleep
            $sleep += $sleep # increment with previous amount to get a better chance of a succeess
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
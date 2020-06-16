
function Start-SslTest {
    param(
        [Object] $Config,
        [string] $Uri
    )
    
    Write-Information "Getting SSL report for $site"
    $result = Get-Ssl -Config $config -Uri $site

    $retryCount = 0
    $sleep = $config.sssl_endpoint_retry_sleep
    if ($result.status.ToUpper() -ne "READY") {    
        
        # calls to ssl labs are async, using this simple while to get result when ready
        while ($result.status.ToUpper() -ne "READY" -and $retryCount -lt $config.ssl_endpoint_retry_count) {
            Write-Information "SSL result not ready, retrying in $sleep seconds..."
            Start-Sleep -Seconds $sleep
            $sleep += $sleep # increment with previous amount to get a better chance of a success            
            $result = Get-Ssl -Config $config -StartNew $false -Uri $site 
    
            $retryCount += 1
        }
    }
    
    if ($retryCount -ge $config.ssl_endpoint_retry_count) {
        Write-Information "SSL result not ready. Set ssl_endpoint_startNew to false to use cached version"
        Write-Error "Queried SSL status $($config.ssl_endpoint_retry_count) times in last $sleep seconds with no succees. Please try again later or disable ssl_endpoint_startNew. The last returned status was $($result.status)."
    
    }
    
    $result.endpoints | Add-Member -Name site -Value $site -MemberType NoteProperty

    return $result.endpoints
    
}

$startNew = $true
$sslCheckHasRun = $false
function Get-Ssl {
    param (
        [string] $Uri,
        [psobject] $Config
    )
 
    $completePath = $Config.ssl_endpoint_checker + "?host=$($Uri)"

    $currentState = Invoke-RestMethod -Uri $completePath

    # return if in progress else another assessment starts    
    switch ($currentState.status.ToUpper()) {
        "IN_PROGRESS" { 
                        Write-Information "Assesment in progress..." 
                        return $currentState
                    }
        "READY" { # ignore first ready as we want fresh copy
                    if ($script:sslCheckHasRun) {
                        return $currentState 
                    }
        }
    }     
 
    Write-Debug "Current state is $($currentState.status)"

    $completePath = Build-UriPath -Config $Config -Uri $Uri    

    Write-Debug "Invoking call to $completePath"
    $script:sslCheckHasRun = $true
    return Invoke-RestMethod -Uri $completePath

}

function Build-UriPath {
    param (
        [string] $Uri,
        [psobject] $Config
    )

        # api documentation states only 1 can be on
        if ($Config.ssl_endpoint_startNew -and $Config.ssl_endpoint_fromCache) {
            Write-Error "ssl_endpoint_startNew and ssl_endpoint_fromCache can not both be true"
        }
        
        if ($Config.ssl_endpoint_fromCache) {
            $completePath = $completePath + "&fromCache=on"
            Write-Debug "Enabling fromCache"
        }
    
        if ($Script:startNew -and $Config.ssl_endpoint_startNew) {
    
            $completePath = $completePath + "&startNew=on"
    
            Write-Debug "Setting startNew to false as only 1 call should be made to avoid assesment loop"
            $Script:startNew = $false
        }
    
        if ($Config.ssl_endpoint_all) {
            $completePath = $completePath + "&all=on"
            Write-Debug "Enabling all"
        }
    
        if ($Config.ssl_endpoint_publish) {
            $completePath = $completePath + "&publish=on"
            Write-Debug "Enabling publish"
        }
    
        return $completePath
}
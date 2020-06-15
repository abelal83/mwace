

function Get-Ssl {
    param (
        [string] $Uri,
        [psobject] $Config
    )
 
    $completePath = $Config.ssl_endpoint_checker + "?host=$($Uri)"

    # api documentation states only 1 can be on
    if ($Config.ssl_endpoint_startNew -and $Config.ssl_endpoint_fromCache) {
        Write-Error "ssl_endpoint_startNew and ssl_endpoint_fromCache can not both be true"
    }
    
    if ($Config.ssl_endpoint_fromCache) {
        $completePath = $completePath + "&fromCache=on"
        Write-Debug "Enabling fromCache"
    }

    if ($Config.ssl_endpoint_startNew) {
        $completePath = $completePath + "&startNew=on"
        Write-Debug "Enabling startNew"
    }

    if ($Config.ssl_endpoint_all) {
        $completePath = $completePath + "&all=on"
        Write-Debug "Enabling all"
    }

    if ($Config.ssl_endpoint_publish) {
        $completePath = $completePath + "&publish=on"
        Write-Debug "Enabling publish"
    }

    Write-Debug "Invoking call to $completePath"
    return Invoke-RestMethod -Uri $completePath

}
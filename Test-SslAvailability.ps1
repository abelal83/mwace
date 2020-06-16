function Test-SslAvailability {
    param(
        [Object] $Config
    )

    $completePath = $Config.ssl_endpoint_availability

    $result = Invoke-RestMethod -Uri $completePath

    if ($result.currentAssessments -ge $result.maxAssessments)
    {
        Write-Information "Running maximum number of assessments, please retry again later."
        return $false
    }

    return $true
}

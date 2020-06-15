$ErrorActionPreference = 'Stop'
$InformationPreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue' # switch to ignore in production mode

Describe "Get-Ssl" {

    $testJsonResponse = Get-Content "$PSScriptRoot\ssllabs_test.json" -Raw | ConvertFrom-Json
    $config = Get-Content "$PSScriptRoot\appsettings.json" -Raw |  ConvertFrom-Json

    . ./Get-Ssl.ps1
    Context "acceptance tests" {

        Mock -CommandName Invoke-RestMethod -MockWith { 
            return $testJsonResponse
        }

        It "should be a valid config"  {
            $result = Get-Ssl -Config $config -Uri "www.somedomain.com"
            Assert-MockCalled -CommandName Invoke-RestMethod -Scope It
            $result | Should Be $testJsonResponse
        }

        It "should be an invalid config" {
            $result = Get-Ssl -Config $config -Uri "www.somedomain.com"
            Assert-MockCalled -CommandName Invoke-RestMethod -Scope It
            $result | Should Not Be "{empty}"
        }

        It "should pass only when one value is true" {
            $config.ssl_endpoint_fromCache = $true
            $config.ssl_endpoint_startNew = $false
            Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 0
            Get-Ssl -Config $config -Uri "www.somedomain.com"            
        }

        It "should fail only when both values are true" {
            $config.ssl_endpoint_fromCache = $true
            $config.ssl_endpoint_startNew = $true
            Assert-MockCalled -CommandName Invoke-RestMethod -Scope It -Times 0
            try {
                Get-Ssl -Config $config -Uri "www.somedomain.com"
            } 
            catch {
                $_.Exception.Message | should be "ssl_endpoint_startNew and ssl_endpoint_fromCache can not both be true"
            }
        }
    }
}

Describe "Start-SslTest" {

    $testJsonResponse = Get-Content "$PSScriptRoot\ssllabs_test.json" -Raw | ConvertFrom-Json
    $config = Get-Content "$PSScriptRoot\appsettings.json" -Raw |  ConvertFrom-Json

    . ./Get-Ssl.ps1 # import for mock purpose only
    . ./Start-SslTest
    Context "acceptance tests" {

        Mock -CommandName Get-Ssl -MockWith { 
            return $testJsonResponse
        }

        $config.ssl_endpoint_retry_count = 2 # reduce both to improve test speed
        $config.sssl_endpoint_retry_sleep = 1
        
        $testJsonResponse.status = "NOT_READY" # mocking not ready, but can be anything        

        It "should retry twice after not READY status" {           

            try {
                Start-SslTest -Config $config -Uri "www.somedomain.com"
            } 
            catch {
                $_.Exception.Message | should be "Queried SSL status 2 times in last 4 seconds with no succees. Please try again later."
                Assert-MockCalled -CommandName Get-Ssl -Scope It -Times 2
            }
        }
    }
}
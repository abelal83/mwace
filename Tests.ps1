
$testJsonResponse = Get-Content "$PSScriptRoot\ssllabs_test.json" -Raw


Describe "Get-Ssl" {

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

    . ./Start-Test
    Context "acceptance tests" {
        It "ItName" {
            Assertion
        }
    }
}
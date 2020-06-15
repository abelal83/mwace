# SSL test

Simple test for ssl labs with report

## How to use

1. Git clone <https://github.com/abelal83/mwace.git>
2. Use Powershell Core v7 (may work on v6)
3. Modify appsettings.json accordingly
4. Run main.ps1
5. Report should be generated under ~/report.html
6. Email funcitonality not fully tested as no access to smpt server but uses native powershell cmdlet so should be fine

## Tests

Some basic tests created using pester tests, to run simply execute Tests.ps1 from powerhshell core.

If pester is not installed you can fine it here <https://www.powershellgallery.com/packages/Pester/>
Note that tests were created against Pester 3.4.0

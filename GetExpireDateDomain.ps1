####################################
# Set your GleSYS API credentials.
$CLAccount = "cl12345"
$APIKey = "123456789987654321"
####################################

$Date = Get-Date -Format yyyyMMdd
$FileOutput = "$env:TEMP\$CLaccount-$Date.csv"

$Key = ConvertTo-SecureString $APIKey -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($CLAccount, $Key)

$OutPut = @() 

[XML]$GleSYSAPIQuery = Invoke-WebRequest -Uri https://api.glesys.com/domain/list -Credential $Credential
$ListDomains = $GleSYSAPIQuery.response.domains.ChildNodes | Select-Object domainname

$WebRequest = New-WebServiceProxy 'http://www.webservicex.net/whois.asmx?WSDL'

$InternalCounter++
ForEach ($Domain in $ListDomains.domainname) {
    
    Write-Host "Processing domain $InternalCounter of $($ListDomains.Count) : $Domain"
    $RawOutput = $WebRequest.GetWhoIs($Domain)

        $OutPut += [PSCustomObject]@{
        DomainName = ($RawOutput | Select-String -Pattern "Domain: (.*)","Domain Name: (.*)").Matches.Groups[1].Value.Trim()
        ExpirationDate = [datetime]($RawOutput | Select-String -Pattern "expires: (.*)","Registry Expiry Date: (.*)").Matches.Groups[1].Value.Trim()
        DaysLeftUntilExpire = (New-TimeSpan -Start (Get-Date) -End ([datetime]($RawOutput | Select-String -Pattern "expires: (.*)","Registry Expiry Date: (.*)").Matches.Groups[1].Value)).Days
    }
    $InternalCounter++
}
$OutPut | Sort-Object "DaysLeftUntilExpire" | Export-Csv -Path $FileOutput 
$OutPut | Sort-Object "DaysLeftUntilExpire"
Write-Host "Output saved to $FileOutput"
$InternalCounter = $null
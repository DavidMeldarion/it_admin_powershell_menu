function Show-Menu
{
    Clear-Host
    Write-Host "================ IT Powershell Menu ================"
    
    Write-Host "1: Press '1' for AD sync."
    Write-Host "2: Press '2' for Inactive Users (90 days)."
    Write-Host "3: Press '3' for User MFA Status."
    Write-Host "4: Press '4' for User License Status."
    Write-Host "Q: Press 'q' to quit."
}

do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             Start-ADSyncSyncCycle -PolicyType Delta
         } '2' {
#Set default output file path if not passed.
if ([string]::IsNullOrEmpty($OutputFile) -eq $true) 
{ 
    $OutputFile = "C:\Reports\o365-active-users-mfa-status.csv"      
}
Connect-MsolService
$Result=@() 
$users = Get-MsolUser -EnabledFilter EnabledOnly
$users | ForEach-Object {
$user = $_
if ($user.StrongAuthenticationRequirements.State -ne $null){
$mfaStatus = $user.StrongAuthenticationRequirements.State
}else{
$mfaStatus = "Disabled" }
$Result += New-Object PSObject -property @{ 
UserName = $user.DisplayName
UserPrincipalName = $user.UserPrincipalName
MFAStatus = $mfaStatus
}
}
#Export user details to CSV.
$Result | Export-CSV $OutputFile -NoTypeInformation -Encoding UTF8
Write-Host "Report exported successfully" -ForegroundColor Yellow
         } '3' {
             #Set default output file path if not passed.
if ([string]::IsNullOrEmpty($OutputFile) -eq $true) 
{ 
    $OutputFile = "C:\Reports\o365-active-users-mfa-status.csv"      
}
Connect-MsolService
$Result=@() 
$users = Get-MsolUser -EnabledFilter EnabledOnly
$users | ForEach-Object {
$user = $_
if ($user.StrongAuthenticationRequirements.State -ne $null){
$mfaStatus = $user.StrongAuthenticationRequirements.State
}else{
$mfaStatus = "Disabled" }

$Result += New-Object PSObject -property @{ 
UserName = $user.DisplayName
UserPrincipalName = $user.UserPrincipalName
MFAStatus = $mfaStatus
}
}
#Export user details to CSV.
$Result | Export-CSV $OutputFile -NoTypeInformation -Encoding UTF8
Write-Host "Report exported successfully" -ForegroundColor Yellow
         }
'4' {
             Connect-MsolService
$CSVpath = "C:\Reports\UserLicenseReport.csv"
  $licensedUsers = Get-MsolUser -all | Where-Object {$_.isLicensed -eq "True"} 
    foreach ($user in $licensedUsers) {
        Write-Host "$($user.displayname)" -ForegroundColor Yellow  
        $licenses = $user.Licenses
        $licenseArray = $licenses | foreach-Object {$_.AccountSkuId}
        $licenseString = $licenseArray -join ", "
        Write-Host "$($user.displayname) has $licenseString" -ForegroundColor Blue
        $licensedUserProperties = [pscustomobject][ordered]@{
            DisplayName       = $user.DisplayName
            Licenses          = $licenseString
            UserPrincipalName = $user.UserPrincipalName
			FirstName		  = $user.FirstName
			LastName          = $user.LastName
			City			  = $user.City
			BlockCredential   = $user.BlockCredential
        }
        $licensedUserProperties | Export-CSV -Path $CSVpath -Append -NoTypeInformation   
    }
         } 
     }
     pause
 }
 until ($selection -eq 'q')powers
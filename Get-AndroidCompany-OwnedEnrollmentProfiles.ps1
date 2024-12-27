<#
.Synopsis
   This function retrieves all Android company-owned enrollment profiles.
.DESCRIPTION
   This function retrieves all Android company-owned enrollment profiles.

.EXAMPLE
    Update the information on lines 45-47 and run the script. 
    Get-AndroidCompany-OwnedEnrollmentProfiles

.PSModules
    PS Modules are used refer https://github.com/ergautamsharma/PSModules

.NOTES
  Version:             1.0
  Author:              Gautam Sharma @ergautamsharma
  Source:              https://github.com/ergautamsharma/Intune-Bulk-Task
  Creation Date:       December 27, 2024
  Last Update Date:    December 27, 2024
#>

#Function to get token
function Get-Token
{
    param(
        [string]$clientId,
        [string]$clientSecret,
        [string]$tenantId
    )
 
    $body = @{
        grant_type    = "client_credentials"
        scope         = "https://graph.microsoft.com/.default"
        client_id     = $clientId
        client_secret = $clientSecret
    }
 
    $tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method Post -Body $body
    $accessToken = $tokenResponse.access_token
    return $accessToken
 
}

#update the below details
$clientId = "1780x7a4-326x-438a-xxx3-3bf9d9d9d9d9c0"
$clientSecret = "G0000~xikNCcxxxxxxPeEJLZQIWy4qr5r5r-uas2"
$tenantId = "820000c7-b00c-4x84-8004-10dcaa2xxxx7"

#Requesting for access token
$accessToken = Get-Token -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId

#creating header of API
$header = @{
    "Authorization" = "Bearer $($accessToken)"
    "Content-type"  = "application/json"
}

#Exporting All Android Enrollment Profiles to CSV
$uri = "https://graph.microsoft.com/beta/deviceManagement/androidDeviceOwnerEnrollmentProfiles"
$AndroidToken = (Invoke-RestMethod -Uri $uri –Headers $header –Method Get).value
$AndroidToken | Select-Object accountId, id, displayname, enrollmentMode, enrollmentTokenType | Export-Csv -NoTypeInformation -Path "AndroidEnrollmentProfiles.csv" -Encoding UTF8

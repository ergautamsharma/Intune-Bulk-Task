<#
.Synopsis
   This function is designed to perform the enable or disable lost mode of iOS devices in the event of iOS device lost or stolen.
.DESCRIPTION
   This function is specifically designed to perform lost mode enable or disable actions for iOS devices. 
   The lost mode function is incredibly useful in scenarios where a device is lost or stolen. 
   By enabling lost mode, we can remotely lock the device, display a message with contact information, and track its location. 
   Conversely, if the device is found, we can easily disable lost mode to restore normal functionality.
   This function can be adapted to perform the bulk action with minimal changes.

.EXAMPLE
   Enable-LostMode -header $header -deviceid $deviceID -message $EnableLostModeMessage -PhoneNumber $ITPhoneNumber
   Disable-LostMode -header $header -deviceid $deviceID

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

#Function to enable the Lost mode for ios devices
function Enable-LostMode
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$header,
        [Parameter(Mandatory = $true)]
        [string]$deviceid,
        [Parameter(Mandatory = $true)]
        [string]$message,
        [Parameter(Mandatory = $false)]
        [string]$PhoneNumber
    )

    if ($null -eq $PhoneNumber)
    {
        $PhoneNumber = "Phone number is not available"
    }
    $URL="https://graph.microsoft.com/beta/deviceManagement/managedDevices/$deviceid/enableLostMode"

    $BodyJson = @"
    {
        "message": $message,
        "phoneNumber": $PhoneNumber
    }
"@
    $Status = Invoke-RestMethod -Uri $URL -Method POST -header $header -body $BodyJson

    return $Status
}

#Function to Disable the Lost mode for ios devices
function Disable-LostMode
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$header,
        [Parameter(Mandatory = $true)]
        [string]$deviceid
    )
    $URL="https://graph.microsoft.com/beta/deviceManagement/managedDevices/$deviceid/disableLostMode"

    $Status = Invoke-RestMethod -Uri $URL -Method POST -header $header -body $BodyJson

    return $Status
}


#update the below details
$clientId = "1780x7a4-326x-438a-xxx3-3bf9d9d9d9d9c0"
$clientSecret = "G0000~xikNCcxxxxxxPeEJLZQIWy4qr5r5r-uas2"
$tenantId = "820000c7-b00c-4x84-8004-10dcaa2xxxx7"
$accessToken = Get-Token -clientId $clientId -clientSecret $clientSecret -tenantId $tenantId

#creating header of API
$header = @{
    "Authorization" = "Bearer $($accessToken.access_token)"
    "Content-type"  = "application/json"
}

#update the below inputs
$deviceID = 'e4cb9xx7-500c-4x06-axx2-x0000000edb1'
$EnableLostModeMessage = "Please return the Device to IT Department"
$ITPhoneNumber = "+1 000 000 000"

#enable lost mode for ios device
Enable-LostMode -header $header -deviceid $deviceID -message $EnableLostModeMessage -PhoneNumber $ITPhoneNumber

#Disable lost mode for ios device
Disable-LostMode -header $header -deviceid $deviceID
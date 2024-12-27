<#
.Synopsis
   This script is designed to retrieve a comprehensive list of all devices managed by Intune.
.DESCRIPTION
    This Script designed to retrieve a comprehensive list of all devices managed by Intune. 
    This powerful script doesn't just stop at listing the devices; it goes a step further by offering various filtering options to make the data more meaningful and actionable.
    With this script, you can filter the output based on several criteria such as device OS, device Compliant State, Device Ownership, and even device last sync days. 
    This level of granularity will enable you to get a precise and clear view of the devices under management, helping us to better manage and maintain our device fleet.


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

#Function to Get devices
function Get-IntuneAllDevice
{
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("All","Windows","Android","iOS")]
        [string]$OSType = "All",
        [Parameter(Mandatory = $false)]
        [ValidateSet("All","compliant","noncompliant","configManager")]
        [string]$CompliantStatus = "All",
        [Parameter(Mandatory = $false)]
        [ValidateSet("All","company","personal")]
        [string]$DeviceOwnership = "All",
        [Parameter(Mandatory = $false)]
        [int]$LastSyncInDays = '0'

    )
    
    <#
    $OSType = "All"
    $CompliantStatus = "All"
    $DeviceOwnership = "All"
    $LastSyncInDays = "10"
    Clear-Variable -Name filters
    
    #>
    
    #enable filter
    $filters = "?"

    #Update filter with OS
    if ($OSType -ne "All")
    {
        
        if ($filters -eq "?")
        {
            $filter = "`$filter=operatingSystem eq '$($OSType)'"
            $filters += $filter
        }
        else
        {
            $filter = "operatingSystem eq '$($OSType)'"
            $op = ' And '
            $filters += $op + $filter
        }
    }

    #update filter with CompliantStatus
    if ($CompliantStatus -ne "All")
    {
        
        if ($filters -eq "?")
        {
            $filter = "`$filter=complianceState eq '$($CompliantStatus)'"
            $filters += $filter
        }
        else
        {
            $filter = "complianceState eq '$($CompliantStatus)'"
            $op = ' And '
            $filters += $op + $filter
        }
    }

    #update filter with Device Ownership
    if ($DeviceOwnership -ne "All")
    {
        
        if ($filters -eq "?")
        {
            $filter = "`$filter=managedDeviceOwnerType eq '$($DeviceOwnership)'"
            $filters += $filter
        }
        else
        {
            $filter = "managedDeviceOwnerType eq '$($DeviceOwnership)'"
            $op = ' And '
            $filters += $op + $filter
        }
    }

    #update filter with Device LastSyncInDays
    if ($LastSyncInDays -ne '0')
    {
        
        if ($filters -eq "?")
        {
            $DaysAgo = "{0:s}" -f (Get-Date).AddDays(0 - $LastSyncInDays) + "Z"
            $filter = "`$filter=lastSyncDateTime ge '$($DaysAgo)'"
            $filters += $filter
        }
        else
        {
            $DaysAgo = "{0:s}" -f (Get-Date).AddDays(0 - $LastSyncInDays) + "Z"
            $filter = "lastSyncDateTime ge '$($DaysAgo)'"
            $op = ' And '
            $filters += $op + $filter
        }
    }

    #clear filter if not filter seleted
    if ($filters -eq "?")
    {
        $filters = $null
    }
    Write-Verbose "Filter is set as $($filters)"
    # creating URI
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/managedDevices"
    #$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)$($filter)"

    try
      {
        $results = @()
        $uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)$($filters)"
        $result = Invoke-MgGraphRequest -Uri $uri -Method Get
        $results += $result
        Write-Verbose "Total devices $($results.count)"
        if ($result.'@odata.nextLink') {
          Write-Verbose "$($results.count) returned. More results are available, will begin paging."
          $noMoreResults = $false
          do {

            #retrieve the next set of results
            $result = Invoke-MgGraphRequest -Uri $result.'@odata.nextLink' -Method Get -ErrorAction Continue
            $results += $result

            #check if we need to continue paging
            if (-not $result.'@odata.nextLink') {
              $noMoreResults = $true
              Write-Verbose "$($results.count) returned. No more pages."
            } else {
              Write-Verbose "$($results.count) returned so far. Retrieving next page."
            }
          } until ($noMoreResults)
        }
        return $($results.value)
      }

      catch
      {
        $ex = $_.Exception
        if ($ex.Response) {
          $errorResponse = $ex.Response.GetResponseStream()
          $reader = New-Object System.IO.StreamReader ($errorResponse)
          $reader.BaseStream.Position = 0
          $reader.DiscardBufferedData()
          $responseBody = $reader.ReadToEnd();
          Write-Verbose "Response content:`n$responseBody"
          Write-Error "Request to $Uri failed with HTTP Status $($ex.Response.StatusCode) $($ex.Response.StatusDescription)"
        } else {
          Write-Error $ex.message
        }
        break
      }

}

#function to validate the 
function Pre-Validation
{
    $GraphModule = Get-Module -Name Microsoft.Graph.Authentication -ListAvailable
    if ($null -eq $GraphModule)
    {
        Write-Host "Microsoft Graph Module is not install. Please install using Install-Module -Name Microsoft.Graph.Authentication -Scope CurrentUser"
        exit
    }

}

pre-validation

#update the below details
$clientId = "Enter Application (client) ID " 
$clientSecret = "Enter the application secret key value"
$tenantId = "Enter the Teant ID"
[securestring]$SclientSecret = ConvertTo-SecureString $clientSecret -AsPlainText -Force
[pscredential]$Appcred= New-Object System.Management.Automation.PSCredential ($clientId, $SclientSecret)
Connect-MgGraph -TenantId $TenantId -ClientSecretCredential $Appcred -NoWelcome

$AllDevices = Get-IntuneAllDevice -header $header -LastSyncInDays '5'



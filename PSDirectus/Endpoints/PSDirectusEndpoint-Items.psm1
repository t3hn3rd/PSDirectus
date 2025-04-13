# Import the DirectusEndpoint class to extend
using module "..\Core\PSDirectusEndpoint.psm1"

# Import Core
using module "..\Core\PSDirectusConstants.psm1"
using module "..\Core\PSDirectusContext.psm1"
using module "..\Helpers\PSDirectusRequestURI.psm1"
using module "..\Helpers\PSDirectusFilter.psm1"

class DirectusEndpointItems : DirectusEndpoint {

  DirectusEndpointItems() : base() {
  }

  static [PSObject] Create([DirectusContext]$Context, [hashtable]$Parameters) {
    # Check if the parameters are valid for the endpoint
    if([DirectusEndpoint]::ValidateParameters($Parameters, @('Collection', 'Items'))) {
      # Construct the request URI
      $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                    addPathParam($Parameters['Collection']).
                    addFields($Parameters['Fields']).
                    addFilter($Parameters['Filter']).
                    addLimit($Parameters['Limit']).
                    addOffset($Parameters['Offset']).
                    addSort($Parameters['Sort']).
                    addSearch($Parameters['Search']).
                    get()
      # Invoke the REST method to get the item(s)
      $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Parameters['Items'] | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
      # return the response
      return $Response.data
    }
    # return null on failure
    return $null
  }

  static [PSObject] Read([DirectusContext]$Context, [hashtable]$Parameters) {
    # Check if the parameters are valid for the endpoint
    if([DirectusEndpoint]::ValidateParameters($Parameters, @('Collection'))) {
      # Construct the request URI
      $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                    addPathParam($Parameters['Collection']).
                    addPathParam($Parameters['ItemID']).
                    addFilter($Parameters['Filter']).
                    addFields($Parameters['Fields']).
                    addLimit($Parameters['Limit']).
                    addOffset($Parameters['Offset']).
                    addSort($Parameters['Sort']).
                    get()
      # Invoke the REST method to get the item(s)
      $Response = Invoke-RestMethod -Method Get -Headers $Context.GetHeaders() -Uri $RequestURI
      # return the response
      return $Response.data
    }
    # return null on failure
    return $null
  }

  static [PSObject] Update([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }

  static [PSObject] Delete([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }
}

function Get-PSDirectusItem {
  param(
    [Parameter(Mandatory=$false)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$false)]
    [String] $ItemID,
    [Parameter(Mandatory=$false)]
    [PSDirectusFilter] $Filter,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields,
    [Parameter(Mandatory=$false)]
    [String] $Limit,
    [Parameter(Mandatory=$false)]
    [String] $Offset,
    [Parameter(Mandatory=$false)]
    [String[]] $Sort
  )
  $ResolvedContext = Resolve-PSDirectusContext -Context $Context
  if ($ResolvedContext) {
    return $ResolvedContext.Endpoints.Items.implementation::Read($ResolvedContext, @{
      Collection = $Collection;
      ItemID = $ItemID;
      Filter = $Filter;
      Fields = $Fields;
      Limit = $Limit;
      Offset = $Offset;
      Sort = $Sort
    })
  }
}

$Script:DirectusEndpoints['Items'].implemented = $true
$Script:DirectusEndpoints['Items'].implementation = [DirectusEndpointItems]

Export-ModuleMember -Function Get-PSDirectusItem
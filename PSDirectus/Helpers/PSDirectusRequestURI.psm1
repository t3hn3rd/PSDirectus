# Import External
using module "..\External\PSRequestURI.psm1"

# Import helpers
using module "..\Helpers\PSDirectusFilter.psm1"

<#
.SYNOPSIS
  A class that extends PSRequestURI to build and manipulate URIs for interacting with the Directus API.

.DESCRIPTION
  The PSDirectusRequestURI class is an extension of the PSRequestURI class, providing additional methods to construct URIs specifically for Directus API requests.
  It allows adding fields, filters, search terms, sorting, pagination, and versioning to the URI, which are commonly used in Directus API endpoints.

.PROPERTIES
  [String] $BaseURI         - The base URI (e.g., "https://example.com").
  [String[]] $PathParams    - An array of path parameters to be appended to the base URI.
  [String[]] $QueryParams   - An array of query parameters to be appended to the URI.

.METHODS
  [PSDirectusRequestURI] addFields([String[]]$Fields) - Adds field parameters to the query string.
  [PSDirectusRequestURI] addFilter([PSDirectusFilter]$Filter) - Adds a filter parameter to the query string.
  [PSDirectusRequestURI] addSearch([String]$Search) - Adds a search term to the query string.
  [PSDirectusRequestURI] addSort([String[]]$Sort) - Adds sorting parameters to the query string.
  [PSDirectusRequestURI] addLimit([String]$Limit) - Adds a limit parameter to the query string.
  [PSDirectusRequestURI] addOffset([String]$Offset) - Adds an offset parameter to the query string.
  [PSDirectusRequestURI] addPage([String]$Page) - Adds a page parameter to the query string.
  [PSDirectusRequestURI] addVersion([String]$Version) - Adds a version parameter to the query string.

.EXAMPLES
  $uri = [PSDirectusRequestURI]::new("https://example.com", "items")
  $uri = $uri.addFields(@("id", "name"))
  $uri = $uri.addFilter($filter)
  $uri = $uri.addSearch("exampleSearch")
  $uri = $uri.addSort(@("id", "-name"))
  $uri = $uri.addLimit("10")
  $uri = $uri.addOffset("0")
  $uri = $uri.addPage("2")
  $uri = $uri.addVersion("1")
  $fullURI = $uri.get()  # URI with all query parameters appended

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
class PSDirectusRequestURI : PSRequestURI {
  [String] $BaseURI;
  [String[]] $PathParams;
  [String[]] $QueryParams;
  PSDirectusRequestURI([String]$BaseURI, [String]$Endpoint) : base($BaseURI, $Endpoint) {
  }
  PSDirectusRequestURI([String]$BaseURI, [PSObject]$Endpoint) : base() {
    if($Endpoint.implemented -eq $false) {
      Write-Warning "Attempt to use unimplemented endpoint: `"/$($Endpoint.path)`"."
    }
    $this.construct($BaseURI, $Endpoint.path)
  }
  [PSDirectusRequestURI] addFields([String[]]$Fields) {
    if($Fields -and $Fields.Count -gt 0) {
      $this.addQueryParam('fields=' + ($Fields -join ','))
    }
    return $this
  }
  [PSDirectusRequestURI] addFilter([PSDirectusFilter]$Filter) {
    if($Filter) {
      $this.addQueryParam('filter=' + $Filter.get())
    }
    return $this
  }
  [PSDirectusRequestURI] addSearch([String]$Search) {
    if($Search) {
      $this.addQueryParam('search=' + $Search)
    }
    return $this
  }
  [PSDirectusRequestURI] addSort([String[]]$Sort) {
    if ($Sort -and $Sort.Count -gt 0) {
      $this.addQueryParam('sort=' + ($Sort -join ','))
    }
    return $this
  }
  [PSDirectusRequestURI] addLimit([String]$Limit) {
    if($Limit -and ($Limit -as [uint64])) {
      $this.addQueryParam('limit=' + $Limit)
    }
    return $this
  }
  [PSDirectusRequestURI] addOffset([String]$Offset) {
    if($Offset -and ($Offset -as [uint64])) {
      $this.addQueryParam('offset=' + $Offset)
    }
    return $this
  }
  [PSDirectusRequestURI] addPage([String]$Page) {
    if($Page) {
      $this.addQueryParam('page=' + $Page)
    }
    return $this
  }
  [PSDirectusRequestURI] addVersion([String]$Version) {
    if($Version) {
      $this.addQueryParam('version=' + $Version)
    }
    return $this
  }
}

<#
.SYNOPSIS
    Creates a new PSDirectusRequestURI object.

.DESCRIPTION
    The New-PSDirectusRequestURI function initializes a new PSDirectusRequestURI object using the specified base URI and API endpoint.

.PARAMETER BaseURI
    The base URI of the Directus API.

.PARAMETER Endpoint
    The Directus API endpoint to be appended to the base URI.

.OUTPUTS
    PSDirectusRequestURI
        Returns a new instance of the PSDirectusRequestURI object.

.EXAMPLE
    $requestURI = New-PSDirectusRequestURI -BaseURI "https://example.com/directus" -Endpoint "files"
    Write-Output $requestURI

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
function New-PSDirectusRequestURI {
  param (
    [String]$BaseURI,
    [PSObject]$Endpoint
  )
  process {
    return [PSDirectusRequestURI]::new($BaseURI, $Endpoint)
  }
}

Export-ModuleMember -Function New-PSDirectusRequestURI

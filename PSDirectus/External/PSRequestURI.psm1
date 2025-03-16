<#
.SYNOPSIS
  A class that represents a structured URI with path and query parameters.

.DESCRIPTION
  The PSRequestURI class is used to construct and manipulate a URI by allowing the addition of path and query parameters.
  It supports adding path parameters and query parameters to the base URI and provides a method to retrieve the final formatted URI.

.PROPERTIES
  [String] $BaseURI         - The base URI (e.g., "https://example.com").
  [String[]] $PathParams    - An array of path parameters to be appended to the base URI.
  [String[]] $QueryParams   - An array of query parameters to be appended to the URI.

.METHODS
  [String] get()            - Constructs and returns the full URI as a string, combining the base URI, path parameters, and query parameters.
  [PSRequestURI] addPathParam([String]$PathParam) - Adds a path parameter to the URI.
  [PSRequestURI] addQueryParam([String]$QueryParam) - Adds a query parameter to the URI.

.EXAMPLES
  $uri = [PSRequestURI]::new("https://example.com", "endpoint")
  $uri = $uri.addPathParam("newPath")
  $uri = $uri.addQueryParam("param=value")
  $fullURI = $uri.get()  # "https://example.com/endpoint/newPath?param=value"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
class PSRequestURI {

  [String] $BaseURI;
  [String[]] $PathParams;
  [String[]] $QueryParams;
  hidden [bool] $Constructed;

  [void] init() {
    $this.BaseURI = "";
    $this.PathParams = @();
    $this.QueryParams = @();
    $this.Constructed = $false;
  }

  [void] construct([String]$BaseURI, [String]$Endpoint) {
    if(-not $BaseURI) {
      throw "Base URL cannot be null or empty."
      return
    }

    $this.BaseURI = $BaseURI

    if($this.BaseURI[-1] -ne '/') {
      $this.BaseURI += '/'
    }

    if($Endpoint) {
      $this.PathParams += $Endpoint
    }

    $this.Constructed = $true
  }

  PSRequestURI([String]$BaseURI, [String]$Endpoint) {
    $this.init()
    $this.construct($BaseURI, $Endpoint)
  }

  PSRequestURI() {
    $this.init()
  }

  [String] get() {
    if(-not $this.Constructed) {
      throw "PSRequestURI has not been properly initialized!"
      return ""
    }
    return $this.BaseURI + ($this.PathParams -join '/') + ($this.QueryParams -join '&')
  }

  [PSRequestURI] addPathParam([String]$Path) {
    if(-not $this.Constructed) {
      throw "PSRequestURI has not been properly initialized!"
      return $null
    }
    if($Path) {
      $this.PathParams += $Path
    }
    return $this
  }

  [PSRequestURI] addQueryParam([String]$QueryParam) {
    if(-not $this.Constructed) {
      throw "PSRequestURI has not been properly initialized!"
      return ""
    }
    if($QueryParam) {
      if($this.QueryParams.Count -eq 0) {
        $this.QueryParams += '?' + $QueryParam
      } else {
        $this.QueryParams += $QueryParam
      }
    }
    return $this
  }

  [PSRequestURI] addQueryParam([String]$Parameter, [String]$Value) {
    if(-not $this.Constructed) {
      throw "PSRequestURI has not been properly initialized!"
      return $null
    }
    if($Parameter) {
      if($Value) {
        return $this.addQueryParam("$Parameter=$Value")
      } else {
        return $this.addQueryParam($Parameter)
      }
    } else {
      return $this
    }
    return $this
  }
}

<#
.SYNOPSIS
    Creates a new PSRequestURI object.

.DESCRIPTION
    The New-PSRequestURI function instantiates a new PSRequestURI object using the provided base URL and API endpoint.

.PARAMETER BaseURL
    The base URL of the API.

.PARAMETER Endpoint
    The API endpoint to be appended to the base URL.

.OUTPUTS
    PSRequestURI
        Returns a new instance of the PSRequestURI object.

.EXAMPLE
    $requestURI = New-PSRequestURI -BaseURL "https://example.com/api" -Endpoint "users"
    Write-Output $requestURI

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
function New-PSRequestURI {
  param(
    [String] $BaseURL,
    [String] $Endpoint
  )
  process {
    return [PSRequestURI]::new($BaseURL, $Endpoint)
  }
}

Export-ModuleMember -Function New-PSRequestURI

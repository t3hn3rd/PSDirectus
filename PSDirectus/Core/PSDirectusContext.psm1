using module "..\Helpers\PSDirectusFilter.psm1"
using module "..\Core\PSDirectusConstants.psm1"

<#
.SYNOPSIS
    Represents a Directus API context for authentication and endpoint management.

.DESCRIPTION
    The DirectusContext class stores API authentication details, base URL, headers,
    and endpoint mappings for interacting with the Directus API. It provides utility
    methods for managing headers and creating filter objects.

.CONSTRUCTORS
    DirectusContext([String]$Token, [String]$BaseURL)
        Initializes a new DirectusContext instance with the provided authentication token
        and base URL.

.PROPERTIES
    [String] $BaseURL
        The base URL of the Directus API.

    [Hashtable] $Endpoints
        A hashtable containing Directus API endpoint mappings.

    [String] $Token (Hidden)
        The authentication token used for API requests.

    [Hashtable] $Headers (Hidden)
        The HTTP headers required for authentication and API communication.

.METHODS
    [Hashtable] getHeaders()
        Returns the authentication headers for API requests.

    [PSDirectusFilter] newFilter()
        Creates and returns a new PSDirectusFilter instance for building API query filters.

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
class DirectusContext {
  [String] $BaseURL;
  [Hashtable] $Endpoints;
  hidden [String] $Token;
  hidden [Hashtable] $Headers;
  DirectusContext([String]$Token, [String]$BaseURL) {
    $this.Token = $Token;
    $this.BaseURL = $BaseURL;
    $this.Headers = $Script:DirectusHeadersTemplate.PSObject.Copy();
    $this.Headers['Authorization'] = $this.Headers['Authorization'].Replace(':token', $Token);
    $this.Headers['User-Agent'] = $this.Headers['User-Agent'].Replace(':useragent', $Script:PSDirectusOptions['User-Agent']);
    $this.Endpoints = $Script:DirectusEndpoints.PSObject.Copy();
  }
  hidden [hashtable] getHeaders() {
    return $this.Headers;
  }
  [PSDirectusFilter] newFilter() {
    return [PSDirectusFilter]::new()
  }
}

<#
.SYNOPSIS
    Creates a new Directus API context.

.DESCRIPTION
    Initializes a DirectusContext object using the provided API base URL and authentication token.
    This context is used to manage API authentication and endpoint interactions.

.PARAMETER BaseURL
    The base URL of the Directus API.

.PARAMETER Token
    The authentication token for Directus API access.

.OUTPUTS
    DirectusContext
        Returns an instance of DirectusContext configured with the specified BaseURL and Token.

.EXAMPLE
    $Context = New-PSDirectusContext -BaseURL "https://mydirectus.com" -Token "my-secret-token"
    Creates a DirectusContext for interacting with the Directus API.

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function New-PSDirectusContext {
  param(
    [Parameter(Mandatory=$true)]
    [String] $BaseURL,
    [Parameter(Mandatory=$true)]
    [String] $Token
  )
  process {
    return [DirectusContext]::new($Token, $BaseURL)
  }
}

Export-ModuleMember -Function New-PSDirectusContext

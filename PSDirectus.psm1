<#
.SYNOPSIS
    PSDirectus - A PowerShell wrapper for the Directus API.

.DESCRIPTION
    PSDirectus provides an interface for interacting with the Directus API using PowerShell.
    It includes functionality for authentication, querying items, creating, updating, and deleting data.

.EXPORTS
    - New-PSDirectusFilter
    - New-PSDirectusContext
    - Get-PSDirectusItem
    - New-PSDirectusItem
    - New-PSDirectusItems
    - Remove-PSDirectusItem
    - Remove-PSDirectusItems
    - Update-PSDirectusItem
    - Update-PSDirectusItems
    - Get-PSDirectusItemSingleton
    - Update-PSDirectusItemSingleton

.FUNCTIONS
    - New-PSDirectusFilter
        Creates a new Directus filter object for constructing API queries.

    - New-PSDirectusContext
        Initializes a Directus API context with a base URL and authentication token.

        PARAMETERS:
            - BaseURL (String, Mandatory): The base URL of the Directus instance.
            - Token (String, Mandatory): The authentication token for API access.

    - Get-PSDirectusItem
        Retrieves an item or a collection of items from Directus.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The Directus collection to query.
            - ItemID (String, Optional): The specific item ID to retrieve.
            - Filter (PSDirectusFilter, Optional): A filter object to refine the query.
            - Fields (String[], Optional): A list of fields to include in the response.
            - Limit (String, Optional): The maximum number of items to return.
            - Offset (String, Optional): The number of items to skip.
            - Sort (String[], Optional): Fields to sort the response by.

    - New-PSDirectusItem
        Creates a new item in a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The Directus collection to insert into.
            - Item (PSObject, Mandatory): The item to insert.
            - Fields (String[], Optional): Fields to return in the response.

    - New-PSDirectusItems
        Bulk inserts multiple items into a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The Directus collection to insert into.
            - Items (PSObject[], Mandatory): The list of items to insert.
            - Fields, Limit, Offset, Sort, Filter, Search (Optional): Query modifiers.

    - Remove-PSDirectusItem
        Deletes a specific item from a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection from which to delete.
            - ItemID (String, Mandatory): The ID of the item to delete.

    - Remove-PSDirectusItems
        Deletes multiple items from a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection from which to delete.
            - ItemIDs (String[], Mandatory): The list of item IDs to delete.
            - Fields, Limit, Offset, Sort, Filter, Search (Optional): Query modifiers.

    - Update-PSDirectusItem
        Updates a specific item in a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection to update.
            - ItemID (String, Mandatory): The ID of the item to update.
            - Item (PSObject, Mandatory): The data to update.
            - Fields (String[], Optional): Fields to return in the response.

    - Update-PSDirectusItems
        Bulk updates multiple items in a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection to update.
            - ItemIDs (String[], Mandatory): The IDs of the items to update.
            - Item (PSObject, Mandatory): The data to update.
            - Fields, Filter, Limit, Offset, Sort, Search (Optional): Query modifiers.

    - Get-PSDirectusItemSingleton
        Retrieves a singleton item from a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection containing the singleton.
            - Version (String, Optional): The version of the singleton (if applicable).
            - Fields (String[], Optional): Fields to return in the response.

    - Update-PSDirectusItemSingleton
        Updates a singleton item in a Directus collection.

        PARAMETERS:
            - Context (DirectusContext, Mandatory): The Directus API context.
            - Collection (String, Mandatory): The collection containing the singleton.
            - Item (PSObject, Mandatory): The data to update.
            - Fields (String[], Optional): Fields to return in the response.

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
    License: Apache License 2.0

.LINK
    Directus API Documentation: https://docs.directus.io/
#>

Import-Module "$PSScriptRoot\PSFormData.psm1" -Force
Import-Module "$PSScriptRoot\PSMimeTypes.psm1" -Force

# Global options for PSDirectus
$Script:PSDirectusOptions = @{
  'User-Agent'        = "PSDirectus (1.0.0)"
}

# Mapping of Directus API endpoints with implementation status.
$Script:DirectusEndpoints = @{
  'Assets'          = '/assets'           # TODO: Next
  'Comments'        = '/comments'         # Not Started
  'Dashboards'      = '/dashboards'       # Not Started
  'Extensions'      = '/extensions'       # Not Started
  'Fields'          = '/fields'           # Not Started
  'Files'           = '/files'            # Complete
  'Flows'           = '/flows'            # Not Started
  'Folders'         = '/folders'          # Not Started
  'Items'           = '/items'            # Complete
  'Metrics'         = '/metrics'          # Not Started
  'Notifications'   = '/notifications'    # Not Started  
  'Operations'      = '/operations'       # Not Started  
  'Panels'          = '/panels'           # Not Started  
  'Permissions'     = '/permissions'      # Not Started  
  'Policies'        = '/policies'         # Not Started  
  'Presets'         = '/presets'          # Not Started  
  'Relations'       = '/relations'        # Not Started  
  'Revisions'       = '/revisions'        # Not Started  
  'Roles'           = '/roles'            # Not Started
  'Schema'          = '/schema'           # Not Started  
  'Server'          = '/server'           # Not Started  
  'Settings'        = '/settings'         # Not Started  
  'Shares'          = '/shares'           # Not Started  
  'Translations'    = '/translations'     # Not Started  
  'Users'           = '/users'            # Not Started  
  'Utitlities'      = '/utilities'        # Not Started  
  'Versions'        = '/versions'         # Not Started  
}

# Template for Directus API headers with placeholders for dynamic values.
$Script:DirectusHeadersTemplate = @{
  'Authorization'     = "Bearer :token"
  'User-Agent'        = ":useragent"
}

<#
  .SYNOPSIS
      A PowerShell class for building Directus API filter queries dynamically.

  .DESCRIPTION
      The PSDirectusFilter class provides methods to construct complex filter queries
      for the Directus API. It supports various comparison operators (_eq, _neq, _lt, etc.)
      and logical operations (_and, _or) to combine multiple filters.

  .PROPERTIES
      - Filter [hashtable]: Stores the filter conditions.
      - Output [String]: Stores the JSON representation of the filter.

  .METHODS
      - _eq(), _neq(), _lt(), _lte(), _gt(), _gte(), etc.: Add filter conditions.
      - _in(), _nin(): Filter values in or not in an array.
      - _null(), _nnull(): Check for null values.
      - _contains(), _starts_with(), _ends_with(), etc.: Perform string-based filtering.
      - _between(), _nbetween(): Define range-based filters.
      - _and(), _or(): Combine filters with logical AND/OR conditions.
      - get(): Returns the JSON representation of the filter.

  .NOTES
      Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
      Created: 2025-03-12
      Version: 1.0
#>
class PSDirectusFilter {
  hidden [hashtable] $Filter;
  [String] $Output;

  PSDirectusFilter() {
    $this.Output = "{ }"
    $this.Filter = @{}
  }

  hidden [void] updateOutput() {
    $this.Output = $this.Filter | ConvertTo-Json -Depth 100
  }
  hidden [void] addNestedKeyValue([String]$Key, [String]$Operator, [String]$Value) {
    $this.Filter[$Key] = @{
      $Operator = $Value
    }
    $this.updateOutput()
  }
  hidden [void] addNestedKey([String]$Key, [String]$Operator) {
    $this.Filter[$Key] = $Operator
    $this.updateOutput()
  }

  [PSDirectusFilter] _eq([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_eq', $Value)
    return $this
  }
  [PSDirectusFilter] _neq([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_neq', $Value)
    return $this
  }
  [PSDirectusFilter] _lt([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_lt', $Value)
    return $this
  }
  [PSDirectusFilter] _lte([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_lte', $Value)
    return $this
  }
  [PSDirectusFilter] _gt([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_gt', $Value)
    return $this
  }
  [PSDirectusFilter] _gte([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_gte', $Value)
    return $this
  }
  [PSDirectusFilter] _in([String]$Key, [String[]]$Values) {
    $this.addNestedKeyValue($Key, '_in', $Values)
    return $this
  }
  [PSDirectusFilter] _nin([String]$Key, [String[]]$Values) {
    $this.addNestedKeyValue($Key, '_nin', $Values)
    return $this
  }
  [PSDirectusFilter] _null([String]$Key) {
    $this.addNestedKeyValue($Key, '_null', $true)
    return $this
  }
  [PSDirectusFilter] _nnull([String]$Key) {
    $this.addNestedKeyValue($Key, '_nnull', $true)
    return $this
  }
  [PSDirectusFilter] _contains([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_contains', $Value)
    return $this
  }
  [PSDirectusFilter] _icontains([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_icontains', $Value)
    return $this
  }
  [PSDirectusFilter] _ncontains([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_ncontains', $Value)
    return $this
  }
  [PSDirectusFilter] _starts_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_starts_with', $Value)
    return $this
  }
  [PSDirectusFilter] _istarts_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_istarts_with', $Value)
    return $this
  }
  [PSDirectusFilter] _nstarts_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_nstarts_with', $Value)
    return $this
  }
  [PSDirectusFilter] _nistarts_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_nistarts_with', $Value)
    return $this
  }
  [PSDirectusFilter] _ends_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_ends_with', $Value)
    return $this
  }
  [PSDirectusFilter] _iends_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_iends_with', $Value)
    return $this
  }
  [PSDirectusFilter] _nends_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_nends_with', $Value)
    return $this
  }
  [PSDirectusFilter] _niends_with([String]$Key, [String]$Value) {
    $this.addNestedKeyValue($Key, '_niends_with', $Value)
    return $this
  }
  [PSDirectusFilter] _between([String]$Key, [String]$Value1, [String]$Value2) {
    $this.addNestedKeyValue($Key, '_between', @($Value1, $Value2))
    return $this
  }
  [PSDirectusFilter] _nbetween([String]$Key, [String]$Value1, [String]$Value2) {
    $this.addNestedKeyValue($Key, '_nbetween', @($Value1, $Value2))
    return $this
  }
  [PSDirectusFilter] _empty([String]$Key) {
    $this.addNestedKey($Key, '_empty')
    return $this
  }
  [PSDirectusFilter] _nempty([String]$Key) {
    $this.addNestedKey($Key, '_nempty')
    return $this
  }

  [PSDirectusFilter] _and([PSDirectusFilter]$Filter) {
    if(-not($this.Filter['_and'])) { $this.Filter['_and'] = @() }
    $this.Filter['_and'] += $Filter.Filter
    $this.updateOutput()
    return $this
  }
  [PSDirectusFilter] _or([PSDirectusFilter]$Filter) {
    if(-not($this.Filter['_or'])) { $this.Filter['_or'] = @() }
    $this.Filter['_or'] += $Filter.Filter
    $this.updateOutput()
    return $this
  }

  [String] get() {
    return $this.Filter | ConvertTo-Json -Depth 100 -Compress
  }
}

<#
.SYNOPSIS
    Creates a new Directus filter object.

.DESCRIPTION
    Initializes and returns a new instance of the PSDirectusFilter class, 
    which can be used to build API query filters for Directus.

.OUTPUTS
    PSDirectusFilter
        Returns a new PSDirectusFilter object.

.EXAMPLE
    $Filter = New-PSDirectusFilter
    # Creates a new Directus filter instance.

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function New-PSDirectusFilter {
  return [PSDirectusFilter]::new()
}

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
  return [DirectusContext]::new($Token, $BaseURL)
}

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
  PSRequestURI([String]$BaseURL, [String]$Endpoint) {
    $this.BaseURI = $BaseURL;
    $this.PathParams = @();
    $this.QueryParams = @();
    $this.PathParams += $Endpoint
  }
  [String] get() {
    return $this.BaseURI + ($this.PathParams -join '/') + ($this.QueryParams -join '&')
  }
  [PSRequestURI] addPathParam([String]$PathParam) {
    if($PathParam) {
      $this.PathParams += $PathParam
    }
    return $this
  }
  [PSRequestURI] addQueryParam([String]$QueryParam) {
    if($this.QueryParams.Count -eq 0) {
      $this.QueryParams += '?' + $QueryParam
    } else {
      $this.QueryParams += $QueryParam
    }
    return $this
  }
}

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
  PSDirectusRequestURI([String]$BaseURL, [String]$Endpoint) : base($BaseURL, $Endpoint) {
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
    Retrieves a specific item from a Directus collection using the provided parameters.

.DESCRIPTION
    The Get-PSDirectusItem function constructs a request URI to query the Directus API to retrieve an item from the specified collection.
    If no specific item ID is provided, it retrieves all items. The function allows applying filters, field selections, sorting, and pagination.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection from which the item(s) should be retrieved (e.g., "posts").

.PARAMETER ItemID
    The ID of the specific item to retrieve (optional).

.PARAMETER Filter
    A filter object to apply conditions to the retrieved items (optional).

.PARAMETER Fields
    A list of fields to include in the response (optional).

.PARAMETER Limit
    A limit on the number of items to retrieve (optional).

.PARAMETER Offset
    The starting point from which to retrieve items (optional).

.PARAMETER Sort
    Sorting criteria for the retrieved items (optional).

.OUTPUTS
    PSObject
        Returns the retrieved item or items from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $item = Get-PSDirectusItem -Context $context -Collection "posts" -ItemID "123"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Get-PSDirectusItem {
  param(
    [Parameter(Mandatory=$true)]
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
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addPathParam($ItemID).
                addFilter($Filter).
                addFields($Fields).
                addLimit($Limit).
                addOffset($Offset).
                addSort($Sort).
                get()

  $Response = Invoke-RestMethod -Method Get -Headers $Context.GetHeaders() -Uri $RequestURI
  return $Response.data
}

<#
.SYNOPSIS
    Creates a new item in a Directus collection using the provided parameters.

.DESCRIPTION
    The New-PSDirectusItem function constructs a request URI to interact with the Directus API to create a new item in the specified collection.
    It sends a POST request with the item in JSON format and returns the created item.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the item should be created (e.g., "posts").

.PARAMETER Item
    A PowerShell object representing the item to be created in the collection.

.PARAMETER Fields
    A list of fields to include in the response (optional).

.OUTPUTS
    PSObject
        Returns the created item from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $newItem = [PSCustomObject]@{ title = "New Post"; content = "This is a new post." }
    $createdItem = New-PSDirectusItem -Context $context -Collection "posts" -Item $newItem

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function New-PSDirectusItem {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [PSObject] $Item,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields
  
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addFields($Fields).
                get()

  $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Item | ConvertTo-Json) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Creates new items in a Directus collection using the provided parameters.

.DESCRIPTION
    The New-PSDirectusItems function constructs a request URI to interact with the Directus API to create new items in a specified collection. 
    It sends a POST request with the items in JSON format and returns the created items.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the items should be created (e.g., "posts").

.PARAMETER Items
    An array of PowerShell objects representing the items to be created in the collection.

.PARAMETER Fields
    A list of fields to include in the response (optional).

.PARAMETER Limit
    The limit on the number of items to return (optional).

.PARAMETER Offset
    The offset to start the results from (optional).

.PARAMETER Sort
    A list of fields to sort the results by (optional).

.PARAMETER Filter
    A filter to apply to the results (optional).

.PARAMETER Search
    A search term to filter results by (optional).

.OUTPUTS
    PSObject
        Returns the created items from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $newItems = @(
        [PSCustomObject]@{ title = "New Post"; content = "This is a new post." }
    )
    $createdItems = New-PSDirectusItems -Context $context -Collection "posts" -Items $newItems

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function New-PSDirectusItems {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [PSObject[]] $Items,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields,
    [Parameter(Mandatory=$false)]
    [String] $Limit,
    [Parameter(Mandatory=$false)]
    [String] $Offset,
    [Parameter(Mandatory=$false)]
    [String[]] $Sort,
    [Parameter(Mandatory=$false)]
    [PSDirectusFilter] $Filter,
    [Parameter(Mandatory=$false)]
    [String] $Search
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addFields($Fields).
                addFilter($Filter).
                addLimit($Limit).
                addOffset($Offset).
                addSort($Sort).
                addSearch($Search).
                get()

  $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Items | ConvertTo-Json) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Removes a single item from a Directus collection using the provided parameters.

.DESCRIPTION
    The Remove-PSDirectusItem function constructs a request URI to interact with the Directus API to remove a specific item from a specified collection. 
    It sends a DELETE request to remove the item and returns the response data.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the item exists (e.g., "settings").

.PARAMETER ItemID
    The ID of the item to be removed.

.OUTPUTS
    PSObject
        Returns the response data from the Directus API after the item has been removed.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $response = Remove-PSDirectusItem -Context $context -Collection "settings" -ItemID "123"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Remove-PSDirectusItem {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [String] $ItemID
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addPathParam($ItemID).
                get()

  $Response = Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI
  return $Response.data
}

<#
.SYNOPSIS
    Removes multiple items from a Directus collection using the provided parameters.

.DESCRIPTION
    The Remove-PSDirectusItems function constructs a request URI to interact with the Directus API to remove multiple items from a specified collection. 
    It sends a DELETE request to remove the items and returns the response data.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the items exist (e.g., "settings").

.PARAMETER ItemIDs
    A list of IDs for the items to be removed.

.PARAMETER Fields
    The list of fields to include in the response (optional).

.PARAMETER Limit
    The limit on the number of items to return (optional).

.PARAMETER Offset
    The offset to start the results from (optional).

.PARAMETER Sort
    A list of fields to sort the results by (optional).

.PARAMETER Filter
    A filter to apply to the results (optional).

.PARAMETER Search
    A search term to filter results by (optional).

.OUTPUTS
    PSObject
        Returns the response data from the Directus API after the items have been removed.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $response = Remove-PSDirectusItems -Context $context -Collection "settings" -ItemIDs @("123", "456")

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Remove-PSDirectusItems {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [String[]]$ItemIDs,
    [Parameter(Mandatory=$false)]
    [PSDirectusFilter] $Fields,
    [Parameter(Mandatory=$false)]
    [String] $Limit,
    [Parameter(Mandatory=$false)]
    [String] $Offset,
    [Parameter(Mandatory=$false)]
    [String[]] $Sort,
    [Parameter(Mandatory=$false)]
    [PSDirectusFilter] $Filter,
    [Parameter(Mandatory=$false)]
    [String] $Search
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addFields($Fields).
                addFilter($Filter).
                addLimit($Limit).
                addOffset($Offset).
                addSort($Sort).
                addSearch($Search).
                get()

  $Response = Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($ItemIDs | ConvertTo-Json) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Updates a single item in a Directus collection using the provided parameters.

.DESCRIPTION
    The Update-PSDirectusItem function constructs a request URI to interact with the Directus API to update a specific item of a specified collection. 
    It sends a PATCH request with the updated item data in JSON format and returns the updated item.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the item exists (e.g., "settings").

.PARAMETER Item
    The updated item object to be sent, typically provided as a PowerShell object.

.PARAMETER ItemID
    The ID of the item to be updated.

.PARAMETER Fields
    A list of fields to include in the response (optional).

.OUTPUTS
    PSObject
        Returns the updated item from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $updatedItem = [PSCustomObject]@{ theme = "dark"; language = "en" }
    $updatedSettings = Update-PSDirectusItem -Context $context -Collection "settings" -ItemID "123" -Item $updatedItem

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Update-PSDirectusItem {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [PSObject] $Item,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [String] $ItemID,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addPathParam($ItemID).
                addFields($Fields).
                get()

  Write-Host "Request URI: $RequestURI"
  Write-Host "Item: $($Item | ConvertTo-Json)"
  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Body ($Item | ConvertTo-JSON) -Uri $RequestURI -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Updates multiple items in a Directus collection using the provided parameters.

.DESCRIPTION
    The Update-PSDirectusItems function constructs a request URI to interact with the Directus API to update multiple items of a specified collection. 
    It sends a PATCH request with the updated item data in JSON format and returns the updated items.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the items exist (e.g., "settings").

.PARAMETER Item
    The updated item object to be sent, typically provided as a PowerShell object.

.PARAMETER ItemIDs
    A list of IDs for the items to be updated.

.PARAMETER Fields
    A list of fields to include in the response (optional).

.PARAMETER Filter
    A filter to apply to the results (optional).

.PARAMETER Limit
    The limit on the number of items to return (optional).

.PARAMETER Offset
    The offset to start the results from (optional).

.PARAMETER Sort
    A list of fields to sort the results by (optional).

.PARAMETER Search
    A search term to filter results by (optional).

.OUTPUTS
    PSObject
        Returns the updated items from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $updatedItem = [PSCustomObject]@{ theme = "dark"; language = "en" }
    $updatedSettings = Update-PSDirectusItems -Context $context -Collection "settings" -ItemIDs @("123", "456") -Item $updatedItem

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Update-PSDirectusItems {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [PSObject]$Item,
    [Parameter(Mandatory=$true)]
    [String[]]$ItemIDs,
    [Parameter(Mandatory=$false)]
    [String[]]$Fields,
    [Parameter(Mandatory=$false)]
    [PSDirectusFilter] $Filter,
    [Parameter(Mandatory=$false)]
    [String] $Limit,
    [Parameter(Mandatory=$false)]
    [String] $Offset,
    [Parameter(Mandatory=$false)]
    [String[]] $Sort,
    [Parameter(Mandatory=$false)]
    [String] $Search
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addFields($Fields).
                addFilter($Filter).
                addLimit($Limit).
                addOffset($Offset).
                addSort($Sort).
                addSearch($Search).
                get()

  $Data = @{ "data" = $Item; "keys" = $ItemIDs }
  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Data | ConvertTo-Json) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Retrieves a single item from a Directus collection using the provided parameters.

.DESCRIPTION
    The Get-PSDirectusItemSingleton function constructs a request URI to interact with the Directus API to retrieve the singleton item from a specified collection. 
    It sends a GET request and returns the fetched item.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the singleton item exists (e.g., "settings").

.PARAMETER Version
    The version of the singleton item to retrieve (optional).

.PARAMETER Fields
    A list of fields to include in the response (optional).

.OUTPUTS
    PSObject
        Returns the singleton item from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $settings = Get-PSDirectusItemSingleton -Context $context -Collection "settings"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Get-PSDirectusItemSingleton {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$false)]
    [String] $Version,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addPathParam("singleton").
                addVersion($Version).
                addFields($Fields).
                get()

  $Response = Invoke-RestMethod -Method Get -Headers $Context.GetHeaders() -Uri $RequestURI
  return $Response.data
}

<#
.SYNOPSIS
    Updates the singleton item in a Directus collection using the provided parameters.

.DESCRIPTION
    The Update-PSDirectusItemSingleton function constructs a request URI to interact with the Directus API to update the singleton item of a specified collection. 
    It sends a PATCH request with the updated item data in JSON format and returns the updated item.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Collection
    The name of the collection where the singleton item exists (e.g., "settings").

.PARAMETER Item
    The updated item object to be sent, typically provided as a PowerShell object.

.PARAMETER Fields
    A list of fields to include in the response (optional).

.OUTPUTS
    PSObject
        Returns the updated singleton item from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -APIKey "API_KEY"
    $updatedItem = [PSCustomObject]@{ theme = "dark"; language = "en" }
    $updatedSettings = Update-PSDirectusItemSingleton -Context $context -Collection "settings" -Item $updatedItem

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
#>
function Update-PSDirectusItemSingleton {
  param(
    [Parameter(Mandatory=$true)]
    [DirectusContext] $Context,
    [Parameter(Mandatory=$true)]
    [String] $Collection,
    [Parameter(Mandatory=$true)]
    [PSObject] $Item,
    [Parameter(Mandatory=$false)]
    [String[]] $Fields
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                addPathParam($Collection).
                addPathParam("singleton").
                addFields($Fields).
                get()
  
  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Item | ConvertTo-Json) -ContentType "application/json"
  return $Response.data
}

function Get-PSDirectusFile {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$false)]
        [String] $FileID,
        [Parameter(Mandatory=$false)]
        [String[]] $Fields,
        [Parameter(Mandatory=$false)]
        [String] $Limit,
        [Parameter(Mandatory=$false)]
        [String] $Offset,
        [Parameter(Mandatory=$false)]
        [String[]] $Sort,
        [Parameter(Mandatory=$false)]
        [PSDirectusFilter] $Filter,
        [Parameter(Mandatory=$false)]
        [String] $Search
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).
                  addPathParam($FileID).
                  addFields($Fields).
                  addFilter($Filter).
                  addLimit($Limit).
                  addOffset($Offset).
                  addSort($Sort).
                  addSearch($Search).
                  get()
    
    $Response = Invoke-RestMethod -Method Get -Headers $Context.GetHeaders() -Uri $RequestURI
    return $Response.data
}

Function New-PSDirectusFile {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String] $FilePath,
        [Parameter(Mandatory=$false)]
        [String] $Id,
        [Parameter(Mandatory=$false)]
        [String] $Storage,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDisk,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDownload,
        [Parameter(Mandatory=$false)]
        [String] $Title,
        [Parameter(Mandatory=$false)]
        [String] $Type,
        [Parameter(Mandatory=$false)]
        [String] $Folder,
        [Parameter(Mandatory=$false)]
        [String] $UploadedBy,
        [Parameter(Mandatory=$false)]
        [String] $CreatedOn,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedBy,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedOn,
        [Parameter(Mandatory=$false)]
        [String] $Charset,
        [Parameter(Mandatory=$false)]
        [String] $Filesize,
        [Parameter(Mandatory=$false)]
        [String] $Width,
        [Parameter(Mandatory=$false)]
        [String] $Height,
        [Parameter(Mandatory=$false)]
        [String] $Duration,
        [Parameter(Mandatory=$false)]
        [String] $Embed,
        [Parameter(Mandatory=$false)]
        [String] $Description,
        [Parameter(Mandatory=$false)]
        [String] $Location,
        [Parameter(Mandatory=$false)]
        [String[]] $Tags,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointX,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointY,
        [Parameter(Mandatory=$false)]
        [String] $UploadedOn
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).get()

    $Multipart = (New-MultipartFormData).
                AddField('id', $Id).
                AddField('storage', $Storage).
                AddField('filename_disk', $FileNameDisk).
                AddField('filename_download', $FileNameDownload).
                AddField('title', $Title).
                AddField('type', $Type).
                AddField('folder', $Folder).
                AddField('uploaded_by', $UploadedBy).
                AddField('created_on', $CreatedOn).
                AddField('modified_by', $ModifiedBy).
                AddField('modified_on', $ModifiedOn).
                AddField('charset', $Charset).
                AddField('filesize', $Filesize).
                AddField('width', $Width).
                AddField('height', $Height).
                AddField('duration', $Duration).
                AddField('embed', $Embed).
                AddField('description', $Description).
                AddField('location', $Location).
                AddObject('tags', $Tags).
                AddField('focal_point_x', $FocalPointX).
                AddField('focal_point_y', $FocalPointY).
                AddField('uploaded_on', $UploadedOn).
                AddFile($FilePath)

    $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body $Multipart.GetBody() -ContentType "multipart/form-data; charset=iso-8859-1; boundary=`"$($Multipart.GetBoundary())`""
    return $Response.data
}

Function Remove-PSDirectusFile {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String] $FileID
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).
                addPathParam($FileID).
                get()

    Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI
}

Function Remove-PSDirectusFiles {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String[]] $FileIDs
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).get()

    $Response = Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($FileIDs | ConvertTo-Json) -ContentType "application/json"
    return $Response.data
}

Function Update-PSDirectusFile {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String] $Id,
        [Parameter(Mandatory=$false)]
        [String] $FilePath,
        [Parameter(Mandatory=$false)]
        [String] $Storage,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDisk,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDownload,
        [Parameter(Mandatory=$false)]
        [String] $Title,
        [Parameter(Mandatory=$false)]
        [String] $Type,
        [Parameter(Mandatory=$false)]
        [String] $Folder,
        [Parameter(Mandatory=$false)]
        [String] $UploadedBy,
        [Parameter(Mandatory=$false)]
        [String] $CreatedOn,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedBy,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedOn,
        [Parameter(Mandatory=$false)]
        [String] $Charset,
        [Parameter(Mandatory=$false)]
        [String] $Filesize,
        [Parameter(Mandatory=$false)]
        [String] $Width,
        [Parameter(Mandatory=$false)]
        [String] $Height,
        [Parameter(Mandatory=$false)]
        [String] $Duration,
        [Parameter(Mandatory=$false)]
        [String] $Embed,
        [Parameter(Mandatory=$false)]
        [String] $Description,
        [Parameter(Mandatory=$false)]
        [String] $Location,
        [Parameter(Mandatory=$false)]
        [String[]] $Tags,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointX,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointY,
        [Parameter(Mandatory=$false)]
        [String] $UploadedOn
    )

    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).
                addPathParam($Id).
                get()

    if($FilePath) {
        $Multipart = (New-MultipartFormData).
                    AddField('storage', $Storage).
                    AddField('filename_disk', $FileNameDisk).
                    AddField('filename_download', $FileNameDownload).
                    AddField('title', $Title).
                    AddField('type', $Type).
                    AddField('folder', $Folder).
                    AddField('uploaded_by', $UploadedBy).
                    AddField('created_on', $CreatedOn).
                    AddField('modified_by', $ModifiedBy).
                    AddField('modified_on', $ModifiedOn).
                    AddField('charset', $Charset).
                    AddField('filesize', $Filesize).
                    AddField('width', $Width).
                    AddField('height', $Height).
                    AddField('duration', $Duration).
                    AddField('embed', $Embed).
                    AddField('description', $Description).
                    AddField('location', $Location).
                    AddObject('tags', $Tags).
                    AddField('focal_point_x', $FocalPointX).
                    AddField('focal_point_y', $FocalPointY).
                    AddField('uploaded_on', $UploadedOn).
                    AddFile($FilePath)

        $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body $Multipart.GetBody() -ContentType "multipart/form-data; charset=iso-8859-1; boundary=`"$($Multipart.GetBoundary())`""
        return $Response.data
    } else {
        $Data = @{}
        if($Storage) { $Data.storage = $Storage }
        if($FileNameDisk) { $Data.filename_disk = $FileNameDisk } 
        if($FileNameDownload) { $Data.filename_download = $FileNameDownload }
        if($Title) { $Data.title = $Title }
        if($Type) { $Data.type = $Type }
        if($Folder) { $Data.folder = $Folder }
        if($UploadedBy) { $Data.uploaded_by = $UploadedBy }
        if($CreatedOn) { $Data.created_on = $CreatedOn }
        if($ModifiedBy) { $Data.modified_by = $ModifiedBy }
        if($ModifiedOn) { $Data.modified_on = $ModifiedOn }
        if($Charset) { $Data.charset = $Charset }
        if($Filesize) { $Data.filesize = $Filesize }
        if($Width) { $Data.width = $Width }
        if($Height) { $Data.height = $Height }
        if($Duration) { $Data.duration = $Duration }
        if($Embed) { $Data.embed = $Embed }
        if($Description) { $Data.description = $Description }
        if($Location) { $Data.location = $Location }
        if($Tags) { $Data.tags = $Tags }
        if($FocalPointX) { $Data.focal_point_x = $FocalPointX }
        if($FocalPointY) { $Data.focal_point_y = $FocalPointY }
        if($UploadedOn) { $Data.uploaded_on = $UploadedOn }
        $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Data | ConvertTo-Json) -ContentType "application/json"
        return $Response.data
    }
}

Function Update-PSDirectusFiles {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String[]] $FileIDs,
        [Parameter(Mandatory=$false)]
        [String] $Storage,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDisk,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDownload,
        [Parameter(Mandatory=$false)]
        [String] $Title,
        [Parameter(Mandatory=$false)]
        [String] $Type,
        [Parameter(Mandatory=$false)]
        [String] $Folder,
        [Parameter(Mandatory=$false)]
        [String] $UploadedBy,
        [Parameter(Mandatory=$false)]
        [String] $CreatedOn,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedBy,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedOn,
        [Parameter(Mandatory=$false)]
        [String] $Charset,
        [Parameter(Mandatory=$false)]
        [String] $Filesize,
        [Parameter(Mandatory=$false)]
        [String] $Width,
        [Parameter(Mandatory=$false)]
        [String] $Height,
        [Parameter(Mandatory=$false)]
        [String] $Duration,
        [Parameter(Mandatory=$false)]
        [String] $Embed,
        [Parameter(Mandatory=$false)]
        [String] $Description,
        [Parameter(Mandatory=$false)]
        [String] $Location,
        [Parameter(Mandatory=$false)]
        [String[]] $Tags,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointX,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointY,
        [Parameter(Mandatory=$false)]
        [String] $UploadedOn,
        [Parameter(Mandatory=$false)]
        [String[]] $Fields,
        [Parameter(Mandatory=$false)]
        [String] $Limit,
        [Parameter(Mandatory=$false)]
        [String] $Offset,
        [Parameter(Mandatory=$false)]
        [String[]] $Sort,
        [Parameter(Mandatory=$false)]
        [PSDirectusFilter] $Filter,
        [Parameter(Mandatory=$false)]
        [String] $Search
        
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).
                  addFields($Fields).
                  addFilter($Filter).
                  addLimit($Limit).
                  addOffset($Offset).
                  addSort($Sort).
                  addSearch($Search).
                  get()

    $Data = @{}
    if($Storage) { $Data.storage = $Storage }
    if($FileNameDisk) { $Data.filename_disk = $FileNameDisk }
    if($FileNameDownload) { $Data.filename_download = $FileNameDownload }
    if($Title) { $Data.title = $Title }
    if($Type) { $Data.type = $Type }
    if($Folder) { $Data.folder = $Folder }
    if($UploadedBy) { $Data.uploaded_by = $UploadedBy }
    if($CreatedOn) { $Data.created_on = $CreatedOn }
    if($ModifiedBy) { $Data.modified_by = $ModifiedBy }
    if($ModifiedOn) { $Data.modified_on = $ModifiedOn }
    if($Charset) { $Data.charset = $Charset }
    if($Filesize) { $Data.filesize = $Filesize }
    if($Width) { $Data.width = $Width }
    if($Height) { $Data.height = $Height }
    if($Duration) { $Data.duration = $Duration }
    if($Embed) { $Data.embed = $Embed }
    if($Description) { $Data.description = $Description }
    if($Location) { $Data.location = $Location }
    if($Tags) { $Data.tags = $Tags }
    if($FocalPointX) { $Data.focal_point_x = $FocalPointX }
    if($FocalPointY) { $Data.focal_point_y = $FocalPointY }
    if($UploadedOn) { $Data.uploaded_on = $UploadedOn }

    $Body = @{ "data" = $Data; "keys" = $FileIDs }
    Write-Host "Body: $($Body | ConvertTo-Json)"

    $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Body | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
    return $Response.data
}

Function Import-PSDirectusFile {
    param(
        [Parameter(Mandatory=$true)]
        [DirectusContext] $Context,
        [Parameter(Mandatory=$true)]
        [String] $URL,
        [Parameter(Mandatory=$false)]
        [String] $Id,
        [Parameter(Mandatory=$false)]
        [String] $Storage,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDisk,
        [Parameter(Mandatory=$false)]
        [String] $FileNameDownload,
        [Parameter(Mandatory=$false)]
        [String] $Title,
        [Parameter(Mandatory=$false)]
        [String] $Type,
        [Parameter(Mandatory=$false)]
        [String] $Folder,
        [Parameter(Mandatory=$false)]
        [String] $UploadedBy,
        [Parameter(Mandatory=$false)]
        [String] $CreatedOn,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedBy,
        [Parameter(Mandatory=$false)]
        [String] $ModifiedOn,
        [Parameter(Mandatory=$false)]
        [String] $Charset,
        [Parameter(Mandatory=$false)]
        [String] $Filesize,
        [Parameter(Mandatory=$false)]
        [String] $Width,
        [Parameter(Mandatory=$false)]
        [String] $Height,
        [Parameter(Mandatory=$false)]
        [String] $Duration,
        [Parameter(Mandatory=$false)]
        [String] $Embed,
        [Parameter(Mandatory=$false)]
        [String] $Description,
        [Parameter(Mandatory=$false)]
        [String] $Location,
        [Parameter(Mandatory=$false)]
        [String[]] $Tags,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointX,
        [Parameter(Mandatory=$false)]
        [String] $FocalPointY,
        [Parameter(Mandatory=$false)]
        [String] $UploadedOn
    )
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).
                  addPathParam("import").
                  get()

    $Data = @{}
    if($Id) { $Data.id = $Id }
    if($Storage) { $Data.storage = $Storage }
    if($FileNameDisk) { $Data.filename_disk = $FileNameDisk }
    if($FileNameDownload) { $Data.filename_download = $FileNameDownload }
    if($Title) { $Data.title = $Title }
    if($Type) { $Data.type = $Type }
    if($Folder) { $Data.folder = $Folder }
    if($UploadedBy) { $Data.uploaded_by = $UploadedBy }
    if($CreatedOn) { $Data.created_on = $CreatedOn }
    if($ModifiedBy) { $Data.modified_by = $ModifiedBy }
    if($ModifiedOn) { $Data.modified_on = $ModifiedOn }
    if($Charset) { $Data.charset = $Charset }
    if($Filesize) { $Data.filesize = $Filesize }
    if($Width) { $Data.width = $Width }
    if($Height) { $Data.height = $Height }
    if($Duration) { $Data.duration = $Duration }
    if($Embed) { $Data.embed = $Embed }
    if($Description) { $Data.description = $Description }
    if($Location) { $Data.location = $Location }
    if($Tags) { $Data.tags = $Tags }
    if($FocalPointX) { $Data.focal_point_x = $FocalPointX }
    if($FocalPointY) { $Data.focal_point_y = $FocalPointY }
    if($UploadedOn) { $Data.uploaded_on = $UploadedOn }

    $Body = @{
        url = $URL
        data = $Data
    }

    $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Body | ConvertTo-Json) -ContentType "application/json"
    return $Response.data
}


Export-ModuleMember -Function New-PSDirectusContext, 
                              New-PSDirectusFilter,

                              Get-PSDirectusItemSingleton,
                              Get-PSDirectusItem,
                              New-PSDirectusItem,
                              New-PSDirectusItems,
                              Remove-PSDirectusItem,
                              Remove-PSDirectusItems,
                              Update-PSDirectusItemSingleton,
                              Update-PSDirectusItem,
                              Update-PSDirectusItems,

                              Get-PSDirectusFile,
                              New-PSDirectusFile,
                              Remove-PSDirectusFile,
                              Remove-PSDirectusFiles,
                              Update-PSDirectusFile,
                              Update-PSDirectusFiles,
                              Import-PSDirectusFile
                              
# Import Core
using module "..\Core\PSDirectusConstants.psm1"
using module "..\Core\PSDirectusContext.psm1"

# Import helpers
using module "..\Helpers\PSDirectusRequestURI.psm1"
using module "..\Helpers\PSDirectusFilter.psm1"

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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
  process {
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                    addPathParam($Collection).
                    addFields($Fields).
                    get()

    $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Item | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
    return $Response.data
  }
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
  process {
    $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Items']).
                    addPathParam($Collection).
                    addFields($Fields).
                    addFilter($Filter).
                    addLimit($Limit).
                    addOffset($Offset).
                    addSort($Sort).
                    addSearch($Search).
                    get()

    $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Items | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
    return $Response.data
  }
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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

  $Response = Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($ItemIDs | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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

  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Body ($Item | ConvertTo-JSON -Depth 100 -Compress) -Uri $RequestURI -ContentType "application/json"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Data | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
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

  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Item | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
  return $Response.data
}

# Mark this endpoint as implemented
$Script:DirectusEndpoints['Items'].implemented = $true

# Export functions
Export-ModuleMember -Function   Get-PSDirectusItem,
                                New-PSDirectusItem,
                                New-PSDirectusItems,
                                Remove-PSDirectusItem,
                                Remove-PSDirectusItems,
                                Update-PSDirectusItem,
                                Update-PSDirectusItems,
                                Get-PSDirectusItemSingleton,
                                Update-PSDirectusItemSingleton

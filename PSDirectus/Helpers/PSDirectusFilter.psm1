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
    $this.Output = $this.Filter | ConvertTo-Json -Depth 100 -Compress
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
  process {
    return [PSDirectusFilter]::new()
  }
}

Export-ModuleMember -Function New-PSDirectusFilter

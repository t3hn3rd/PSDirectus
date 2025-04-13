using module "..\Core\PSDirectusContext.psm1"

class DirectusEndpoint {
  DirectusEndpoint() {
    Write-Warning "DirectusEndpoint is an static, abstract class. Use a derived class instead."
  }
  static [PSObject] Create([DirectusContext]$Context, [hashtable]$Parameters) {
    Write-Warning "DirectusEndpoint is an static, abstract class. Use a derived class instead."
    return $null
  }
  static [PSObject] Read([DirectusContext]$Context, [hashtable]$Parameters) {
    Write-Warning "DirectusEndpoint is an static, abstract class. Use a derived class instead."
    return $null
  }
  static [PSObject] Update([DirectusContext]$Context, [hashtable]$Parameters) {
    Write-Warning "DirectusEndpoint is an static, abstract class. Use a derived class instead."
    return $null
  }
  static [PSObject] Delete([DirectusContext]$Context, [hashtable]$Parameters) {
    Write-Warning "DirectusEndpoint is an static, abstract class. Use a derived class instead."
    return $null
  }
  static [Boolean] ValidateParameters([hashtable]$Parameters, [String[]]$Expected) {
    # Verify that the parameters are valid for the endpoint
    foreach($Parameter in $Expected) {
      if(-not $Parameters.ContainsKey($Parameter)) {
        Write-Warning "Missing required parameter: $Parameter"
        return $false
      }
    }
    return $true
  }
}

function New-PSDirectusEndpoint {
  return [DirectusEndpoint]::new()
}

Export-ModuleMember -Function New-PSDirectusEndpoint
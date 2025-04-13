# Import the DirectusEndpoint class to extend
using module "..\Core\PSDirectusEndpoint.psm1"

# Import Core
using module "..\Core\PSDirectusConstants.psm1"
using module "..\Core\PSDirectusContext.psm1"


class DirectusEndpointFiles : DirectusEndpoint {
  DirectusEndpointFiles() : base() {
  }
  static [PSObject] Create([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }
  static [PSObject] Read([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }
  static [PSObject] Update([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }
  static [PSObject] Delete([DirectusContext]$Context, [hashtable]$Parameters) {
    return $null
  }
}

$Script:DirectusEndpoints['Files'].implemented = $true
$Script:DirectusEndpoints['Files'].implementation = [DirectusEndpointFiles]
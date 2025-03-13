class MimeTypeResolver {
  hidden static [PSObject] $MimeTypes
  static [string] resolveMimeType([string]$Extension) {
    if(-not([MimeTypeResolver]::MimeTypes)) {
      [MimeTypeResolver]::MimeTypes = Invoke-RestMethod -Uri "https://cdn.jsdelivr.net/gh/jshttp/mime-db@master/db.json"
    }
    $Extension = $Extension.TrimStart(".")
    $AllProperties = [MimeTypeResolver]::MimeTypes.PSObject.Properties
    $MimeType = $AllProperties | Where-Object { $_.Value.extensions -contains $Extension }
    if($MimeType.name) {
      return $MimeType.name
    } 
    return "application/octet-stream"
  }
}

function Convert-ExtensionToMimeType {
  param (
    [string]$Extension
  )
  return [MimeTypeResolver]::resolveMimeType($Extension)
}

function Convert-FileNameToMimeType {
  param (
    [string]$FileName
  )
  $Extension = [System.IO.Path]::GetExtension($FileName)
  return Convert-ExtensionToMimeType -Extension $Extension
}

Export-ModuleMember -Function Convert-ExtensionToMimeType, Convert-FileNameToMimeType
Import-Module "$PSScriptRoot\PSMimeTypes.psm1" -Force

class MultiPartFormData {
  hidden [PSObject[]]$bodyLines
  hidden [string]$boundary
  hidden [string]$LF
  MultiPartFormData() {
    $this.bodyLines = @()
    $this.boundary = [System.Guid]::NewGuid().ToString()
    $this.LF = "`r`n"
  }
  [MultiPartFormData] AddField([string]$name, [string]$value) {
    if($value) {
      $this.bodyLines += "--$($this.boundary)"
      $this.bodyLines += "Content-Disposition: form-data; name=`"$name`"" + $this.LF
      $this.bodyLines += "$value"
    }
    return $this
  }
  [MultiPartFormData] AddFile([string]$name, [string]$filename, [string]$mime, [PSObject]$fileContent) {
    $this.bodyLines += "--$($this.boundary)"
    $this.bodyLines += "Content-Disposition: form-data; name=`"$name`"; filename=`"$filename`""
    $this.bodyLines += "Content-Type: $mime" + $this.LF
    $this.bodyLines += $fileContent
    return $this
  }
  [MultiPartFormData] AddFile([string]$FilePath) {
    if($FilePath) {
      $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
      $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
      $Filename = Split-Path $FilePath -Leaf
      $MIME = Convert-FileNameToMimeType -FileName $Filename
      $this.AddFile('file', $Filename, $MIME, $fileEnc)
    }
    return $this
  }
  [MultiPartFormData] AddObject([string]$name, [PSObject]$object) {
    if($Object) {
      $this.AddField($name, ($object | ConvertTo-Json -Depth 100 -Compress))
    }
    return $this
  }
  [string] GetBody() {
    if ($this.bodyLines.Count -eq 0) {
      return ""
    }
    return ($this.bodyLines -join $this.LF) + $this.LF + "--$($this.boundary)--$($this.LF)"
  }
  [string] GetBoundary() {
    return $this.boundary
  }
}

Function Import-FileAsMultipartFormData {
  param (
    [string]$FilePath
  )
  $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
  $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
  $Filename = Split-Path $FilePath -Leaf
  $MIME = Convert-FileNameToMimeType -FileName $Filename
  $MPFD = [MultiPartFormData]::new()
  return $MPFD.AddFile('file', $Filename, $MIME, $fileEnc)
}

function New-MultipartFormData {
  return [MultiPartFormData]::new()
}

Export-ModuleMember -Function Import-FileAsMultipartFormData, New-MultipartFormData
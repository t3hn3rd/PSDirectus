# Import Core
using module "..\Core\PSDirectusConstants.psm1"
using module "..\Core\PSDirectusContext.psm1"

# Import helpers
using module "..\Helpers\PSDirectusRequestURI.psm1"
using module "..\Helpers\PSDirectusFilter.psm1"

# Import external dependencies
Import-Module "PSMultipartFormData" -Force

<#
.SYNOPSIS
    Retrieves a file or a list of files from the Directus API.

.DESCRIPTION
    The Get-PSDirectusFile function constructs a request URI to fetch file metadata from the Directus API.
    It allows retrieving a specific file by its ID or querying multiple files with optional filters, sorting, and pagination.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER FileID
    (Optional) The ID of the specific file to retrieve. If omitted, the function returns a list of files based on the provided filters.

.PARAMETER Fields
    (Optional) A list of fields to include in the response.

.PARAMETER Limit
    (Optional) The maximum number of files to return.

.PARAMETER Offset
    (Optional) The number of records to skip before starting to return results.

.PARAMETER Sort
    (Optional) An array specifying sorting order for the returned files.

.PARAMETER Filter
    (Optional) A filter object to narrow down the results.

.PARAMETER Search
    (Optional) A search query string to perform a full-text search on file metadata.

.OUTPUTS
    PSObject
        Returns the requested file metadata or a collection of file records from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    $file = Get-PSDirectusFile -Context $context

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    $file = Get-PSDirectusFile -Context $context -FileID "abc123"

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    $files = Get-PSDirectusFile -Context $context -Limit 10 -Sort @("-date_created")

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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

<#
.SYNOPSIS
    Uploads a new file to the Directus API.

.DESCRIPTION
    The New-PSDirectusFile function uploads a file to the Directus API and allows setting metadata such as storage location,
    filename, title, description, and other file properties. The function supports multipart form data submission.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER FilePath
    The local path of the file to be uploaded.

.PARAMETER Id
    (Optional) A specific ID to assign to the file in Directus.

.PARAMETER Storage
    (Optional) The storage location where the file should be saved.

.PARAMETER FileNameDisk
    (Optional) The name of the file as stored on disk.

.PARAMETER FileNameDownload
    (Optional) The name of the file when downloaded.

.PARAMETER Title
    (Optional) The title of the file.

.PARAMETER Type
    (Optional) The MIME type of the file.

.PARAMETER Folder
    (Optional) The folder ID in which the file should be placed.

.PARAMETER UploadedBy
    (Optional) The ID of the user who uploaded the file.

.PARAMETER CreatedOn
    (Optional) The timestamp of when the file was created.

.PARAMETER ModifiedBy
    (Optional) The ID of the user who last modified the file.

.PARAMETER ModifiedOn
    (Optional) The timestamp of the last modification.

.PARAMETER Charset
    (Optional) The character encoding of the file.

.PARAMETER Filesize
    (Optional) The size of the file in bytes.

.PARAMETER Width
    (Optional) The width of the file (for images or videos).

.PARAMETER Height
    (Optional) The height of the file (for images or videos).

.PARAMETER Duration
    (Optional) The duration of the file (for audio or video).

.PARAMETER Embed
    (Optional) An embed link associated with the file.

.PARAMETER Description
    (Optional) A text description of the file.

.PARAMETER Location
    (Optional) The location metadata for the file.

.PARAMETER Tags
    (Optional) An array of tags associated with the file.

.PARAMETER FocalPointX
    (Optional) The X coordinate of the file's focal point.

.PARAMETER FocalPointY
    (Optional) The Y coordinate of the file's focal point.

.PARAMETER UploadedOn
    (Optional) The timestamp of when the file was uploaded.

.OUTPUTS
    PSObject
        Returns the uploaded file metadata from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    $file = New-PSDirectusFile -Context $context -FilePath "C:\path\to\file.jpg"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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
  process {
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
}

<#
.SYNOPSIS
    Deletes a file from the Directus API.

.DESCRIPTION
    The Remove-PSDirectusFile function sends a DELETE request to the Directus API to remove a file by its ID.
    This action is irreversible and will permanently delete the file from the system.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER FileID
    The ID of the file to be deleted.

.OUTPUTS
    None
        This function does not return any output upon successful deletion.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    Remove-PSDirectusFile -Context $context -FileID "abc123"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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

<#
.SYNOPSIS
    Deletes multiple files from the Directus API.

.DESCRIPTION
    The Remove-PSDirectusFiles function sends a DELETE request to the Directus API to remove multiple files by their IDs.
    This action is irreversible and will permanently delete the specified files.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER FileIDs
    An array of file IDs to be deleted.

.OUTPUTS
    PSObject
        Returns the response from the Directus API, typically indicating which files were deleted.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    Remove-PSDirectusFiles -Context $context -FileIDs @("abc123", "def456", "ghi789")

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
Function Remove-PSDirectusFiles {
  param(
      [Parameter(Mandatory=$true)]
      [DirectusContext] $Context,
      [Parameter(Mandatory=$true)]
      [String[]] $FileIDs
  )
  $RequestURI = [PSDirectusRequestURI]::new($Context.BaseURL, $Context.Endpoints['Files']).get()

  $Response = Invoke-RestMethod -Method Delete -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($FileIDs | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Updates an existing file in the Directus API.

.DESCRIPTION
    The Update-PSDirectusFile function sends a PATCH request to the Directus API to update an existing file.
    It supports updating file metadata as well as replacing the file itself if a new file path is provided.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER Id
    The ID of the file to be updated.

.PARAMETER FilePath
    The local file path to upload and replace the existing file (optional).

.PARAMETER Storage
    The storage location where the file is stored (optional).

.PARAMETER FileNameDisk
    The name of the file on disk (optional).

.PARAMETER FileNameDownload
    The name of the file when downloaded (optional).

.PARAMETER Title
    The title of the file (optional).

.PARAMETER Type
    The MIME type of the file (optional).

.PARAMETER Folder
    The folder ID where the file is stored (optional).

.PARAMETER UploadedBy
    The ID of the user who uploaded the file (optional).

.PARAMETER CreatedOn
    The timestamp of when the file was created (optional).

.PARAMETER ModifiedBy
    The ID of the user who last modified the file (optional).

.PARAMETER ModifiedOn
    The timestamp of when the file was last modified (optional).

.PARAMETER Charset
    The character set of the file (optional).

.PARAMETER Filesize
    The size of the file in bytes (optional).

.PARAMETER Width
    The width of the image or media file (optional).

.PARAMETER Height
    The height of the image or media file (optional).

.PARAMETER Duration
    The duration of the media file (optional).

.PARAMETER Embed
    The embed URL for the file, if applicable (optional).

.PARAMETER Description
    A description of the file (optional).

.PARAMETER Location
    The location metadata for the file (optional).

.PARAMETER Tags
    A list of tags associated with the file (optional).

.PARAMETER FocalPointX
    The X-coordinate of the focal point in the file (optional).

.PARAMETER FocalPointY
    The Y-coordinate of the focal point in the file (optional).

.PARAMETER UploadedOn
    The timestamp of when the file was uploaded (optional).

.OUTPUTS
    PSObject
        Returns the updated file metadata from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    Update-PSDirectusFile -Context $context -Id "abc123" -Title "Updated File Title" -Description "New description"

.EXAMPLE
    Update-PSDirectusFile -Context $context -Id "abc123" -FilePath "C:\NewFile.png"

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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
      $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Data | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
      return $Response.data
  }
}

<#
.SYNOPSIS
    Updates multiple files in the Directus API.

.DESCRIPTION
    The Update-PSDirectusFiles function sends a PATCH request to the Directus API to update multiple files.
    It allows modifying metadata fields across multiple files at once.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER FileIDs
    An array of file IDs to be updated.

.PARAMETER Storage
    The storage location where the files are stored (optional).

.PARAMETER FileNameDisk
    The name of the files on disk (optional).

.PARAMETER FileNameDownload
    The name of the files when downloaded (optional).

.PARAMETER Title
    The title of the files (optional).

.PARAMETER Type
    The MIME type of the files (optional).

.PARAMETER Folder
    The folder ID where the files are stored (optional).

.PARAMETER UploadedBy
    The ID of the user who uploaded the files (optional).

.PARAMETER CreatedOn
    The timestamp of when the files were created (optional).

.PARAMETER ModifiedBy
    The ID of the user who last modified the files (optional).

.PARAMETER ModifiedOn
    The timestamp of when the files were last modified (optional).

.PARAMETER Charset
    The character set of the files (optional).

.PARAMETER Filesize
    The size of the files in bytes (optional).

.PARAMETER Width
    The width of the images or media files (optional).

.PARAMETER Height
    The height of the images or media files (optional).

.PARAMETER Duration
    The duration of the media files (optional).

.PARAMETER Embed
    The embed URL for the files, if applicable (optional).

.PARAMETER Description
    A description of the files (optional).

.PARAMETER Location
    The location metadata for the files (optional).

.PARAMETER Tags
    A list of tags associated with the files (optional).

.PARAMETER FocalPointX
    The X-coordinate of the focal point in the files (optional).

.PARAMETER FocalPointY
    The Y-coordinate of the focal point in the files (optional).

.PARAMETER UploadedOn
    The timestamp of when the files were uploaded (optional).

.PARAMETER Fields
    The specific fields to be returned in the response (optional).

.PARAMETER Limit
    The maximum number of results to return (optional).

.PARAMETER Offset
    The number of records to skip before returning results (optional).

.PARAMETER Sort
    An array specifying the sorting order (optional).

.PARAMETER Filter
    A Directus filter object to apply to the update query (optional).

.PARAMETER Search
    A search query string to filter the results (optional).

.OUTPUTS
    PSObject
        Returns the updated file metadata from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    Update-PSDirectusFiles -Context $context -FileIDs @("abc123", "def456") -Title "Updated Title"

.EXAMPLE
    Update-PSDirectusFiles -Context $context -FileIDs @("abc123", "def456") -Tags @("important", "archive")

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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

  $Response = Invoke-RestMethod -Method Patch -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Body | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
  return $Response.data
}

<#
.SYNOPSIS
    Imports a file into Directus from a specified URL.

.DESCRIPTION
    The Import-PSDirectusFile function sends a POST request to the Directus API to import a file from a remote URL.
    It allows specifying metadata for the file upon import.

.PARAMETER Context
    The Directus context object containing the base URL and authentication headers for the API request.

.PARAMETER URL
    The URL of the file to be imported.

.PARAMETER Id
    The ID to assign to the file (optional).

.PARAMETER Storage
    The storage location where the file will be stored (optional).

.PARAMETER FileNameDisk
    The name of the file on disk (optional).

.PARAMETER FileNameDownload
    The name of the file when downloaded (optional).

.PARAMETER Title
    The title of the file (optional).

.PARAMETER Type
    The MIME type of the file (optional).

.PARAMETER Folder
    The folder ID where the file will be stored (optional).

.PARAMETER UploadedBy
    The ID of the user who uploaded the file (optional).

.PARAMETER CreatedOn
    The timestamp of when the file was created (optional).

.PARAMETER ModifiedBy
    The ID of the user who last modified the file (optional).

.PARAMETER ModifiedOn
    The timestamp of when the file was last modified (optional).

.PARAMETER Charset
    The character set of the file (optional).

.PARAMETER Filesize
    The size of the file in bytes (optional).

.PARAMETER Width
    The width of the image or media file (optional).

.PARAMETER Height
    The height of the image or media file (optional).

.PARAMETER Duration
    The duration of the media file (optional).

.PARAMETER Embed
    The embed URL for the file, if applicable (optional).

.PARAMETER Description
    A description of the file (optional).

.PARAMETER Location
    The location metadata for the file (optional).

.PARAMETER Tags
    A list of tags associated with the file (optional).

.PARAMETER FocalPointX
    The X-coordinate of the focal point in the file (optional).

.PARAMETER FocalPointY
    The Y-coordinate of the focal point in the file (optional).

.PARAMETER UploadedOn
    The timestamp of when the file was uploaded (optional).

.OUTPUTS
    PSObject
        Returns the imported file metadata from the Directus API.

.EXAMPLE
    $context = Get-DirectusContext -BaseURL "https://example.com" -Token "API_KEY"
    Import-PSDirectusFile -Context $context -URL "https://example.com/image.jpg" -Title "Imported Image"

.EXAMPLE
    Import-PSDirectusFile -Context $context -URL "https://example.com/video.mp4" -Tags @("video", "imported")

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-16
    Version: 1.0
#>
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

  $Response = Invoke-RestMethod -Method Post -Headers $Context.GetHeaders() -Uri $RequestURI -Body ($Body | ConvertTo-Json -Depth 100 -Compress) -ContentType "application/json"
  return $Response.data
}

# Mark this endpoint as implemented
$Script:DirectusEndpoints['Files'].implemented = $true

# Export functions
Export-ModuleMember -Function Get-PSDirectusFile,
                              New-PSDirectusFile,
                              Remove-PSDirectusFile,
                              Remove-PSDirectusFiles,
                              Update-PSDirectusFile,
                              Update-PSDirectusFiles,
                              Import-PSDirectusFile

<#
.SYNOPSIS
    PSDirectus - A PowerShell wrapper for the Directus API.

.DESCRIPTION
    PSDirectus provides an interface for interacting with the Directus API using PowerShell.
    It includes functionality for authentication, querying items, creating, updating, and deleting data.

.NOTES
    Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
    Created: 2025-03-12
    Version: 1.0
    License: Apache License 2.0

.LINK
    Directus API Documentation: https://docs.directus.io/
.LINK
    PSDirectus GitHub Repository: https://github.com/t3hn3rd/PSDirectus
.LINK
    PSDirectus License: https://github.com/t3hn3rd/PSDirectus/raw/master/LICENSE
.LINK
    Project Homepage: https://spexeah.com/project?id=2
#>

# Import core
using module ".\Core\PSDirectusConstants.psm1"
using module ".\Core\PSDirectusContext.psm1"

# Import helpers
using module ".\Helpers\PSDirectusRequestURI.psm1"
using module ".\Helpers\PSDirectusFilter.psm1"

# Import implemented endpoints
using module ".\Endpoints\PSDirectusEndpoint-Items.psm1"
using module ".\Endpoints\PSDirectusEndpoint-Files.psm1"

Import-Module "PSMimeTypes"
Import-Module "PSMultipartFormData"

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
                              Import-PSDirectusFile,

                              New-PSDirectusRequestURI


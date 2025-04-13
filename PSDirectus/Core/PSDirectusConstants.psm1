# Global options for PSDirectus
$Script:PSDirectusOptions = @{
  'User-Agent'        = "PSDirectus (1.0.0)"
}

# Mapping of Directus API endpoints with implementation status.
# Each endpoint has a path and a boolean flag indicating if it has been implemented.
# The implemented status as shown here is not nessisarily accurate,
#      as each endpoint is implemented in a separate file and will override this value.
$Script:DirectusEndpoints = @{
  'Assets'          = @{ 'path' = 'assets';           'implemented' = $false;     'implementation' = $null } # TODO: Next
  'Comments'        = @{ 'path' = 'comments';         'implemented' = $false;     'implementation' = $null } # Not Started
  'Dashboards'      = @{ 'path' = 'dashboards';       'implemented' = $false;     'implementation' = $null } # Not Started
  'Extensions'      = @{ 'path' = 'extensions';       'implemented' = $false;     'implementation' = $null } # Not Started
  'Fields'          = @{ 'path' = 'fields';           'implemented' = $false;     'implementation' = $null } # Not Started
  'Files'           = @{ 'path' = 'files';            'implemented' = $false;     'implementation' = $null } # Complete
  'Flows'           = @{ 'path' = 'flows';            'implemented' = $false;     'implementation' = $null } # Not Started
  'Folders'         = @{ 'path' = 'folders';          'implemented' = $false;     'implementation' = $null } # Not Started
  'Items'           = @{ 'path' = 'items';            'implemented' = $false;     'implementation' = $null } # Complete
  'Metrics'         = @{ 'path' = 'metrics';          'implemented' = $false;     'implementation' = $null } # Not Started
  'Notifications'   = @{ 'path' = 'notifications';    'implemented' = $false;     'implementation' = $null } # Not Started
  'Operations'      = @{ 'path' = 'operations';       'implemented' = $false;     'implementation' = $null } # Not Started
  'Panels'          = @{ 'path' = 'panels';           'implemented' = $false;     'implementation' = $null } # Not Started
  'Permissions'     = @{ 'path' = 'permissions';      'implemented' = $false;     'implementation' = $null } # Not Started
  'Policies'        = @{ 'path' = 'policies';         'implemented' = $false;     'implementation' = $null } # Not Started
  'Presets'         = @{ 'path' = 'presets';          'implemented' = $false;     'implementation' = $null } # Not Started
  'Relations'       = @{ 'path' = 'relations';        'implemented' = $false;     'implementation' = $null } # Not Started
  'Revisions'       = @{ 'path' = 'revisions';        'implemented' = $false;     'implementation' = $null } # Not Started
  'Roles'           = @{ 'path' = 'roles';            'implemented' = $false;     'implementation' = $null } # Not Started
  'Schema'          = @{ 'path' = 'schema';           'implemented' = $false;     'implementation' = $null } # Not Started
  'Server'          = @{ 'path' = 'server';           'implemented' = $false;     'implementation' = $null } # Not Started
  'Settings'        = @{ 'path' = 'settings';         'implemented' = $false;     'implementation' = $null } # Not Started
  'Shares'          = @{ 'path' = 'shares';           'implemented' = $false;     'implementation' = $null } # Not Started
  'Translations'    = @{ 'path' = 'translations';     'implemented' = $false;     'implementation' = $null } # Not Started
  'Users'           = @{ 'path' = 'users';            'implemented' = $false;     'implementation' = $null } # Not Started
  'Utitlities'      = @{ 'path' = 'utilities';        'implemented' = $false;     'implementation' = $null } # Not Started
  'Versions'        = @{ 'path' = 'versions';         'implemented' = $false;     'implementation' = $null } # Not Started
}

# Template for Directus API headers with placeholders for dynamic values.
$Script:DirectusHeadersTemplate = @{
  'Authorization'     = "Bearer :token"
  'User-Agent'        = ":useragent"
}

# Template for Directus API headers without authentication.
$Script:DirectusHeadersNoAuthTemplate = @{
  'User-Agent'        = ":useragent"
}

# Runtime context for Directus module, used to store the current context and other runtime information.
$Script:DirectusModuleRuntime = @{
  'StoredContext'     = $null
}

Export-ModuleMember -Variable PSDirectusOptions, DirectusEndpoints, DirectusHeadersTemplate, DirectusHeadersNoAuthTemplate, DirectusModuleRuntime

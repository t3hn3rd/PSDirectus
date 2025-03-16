# Global options for PSDirectus
$Script:PSDirectusOptions = @{
  'User-Agent'        = "PSDirectus (1.0.0)"
}

# Mapping of Directus API endpoints with implementation status.
# Each endpoint has a path and a boolean flag indicating if it has been implemented.
# The implemented status as shown here is not nessisarily accurate,
#      as each endpoint is implemented in a separate file and will override this value.
$Script:DirectusEndpoints = @{
  'Assets'          = @{ 'path' = 'assets';         'implemented' = $false } # TODO: Next
  'Comments'        = @{ 'path' = 'comments';       'implemented' = $false } # Not Started
  'Dashboards'      = @{ 'path' = 'dashboards';     'implemented' = $false } # Not Started
  'Extensions'      = @{ 'path' = 'extensions';     'implemented' = $false } # Not Started
  'Fields'          = @{ 'path' = 'fields';         'implemented' = $false } # Not Started
  'Files'           = @{ 'path' = 'files';          'implemented' = $false } # Complete
  'Flows'           = @{ 'path' = 'flows';          'implemented' = $false } # Not Started
  'Folders'         = @{ 'path' = 'folders';        'implemented' = $false } # Not Started
  'Items'           = @{ 'path' = 'items';          'implemented' = $false } # Complete
  'Metrics'         = @{ 'path' = 'metrics';        'implemented' = $false } # Not Started
  'Notifications'   = @{ 'path' = 'notifications';  'implemented' = $false } # Not Started
  'Operations'      = @{ 'path' = 'operations';     'implemented' = $false } # Not Started
  'Panels'          = @{ 'path' = 'panels';         'implemented' = $false } # Not Started
  'Permissions'     = @{ 'path' = 'permissions';    'implemented' = $false } # Not Started
  'Policies'        = @{ 'path' = 'policies';       'implemented' = $false } # Not Started
  'Presets'         = @{ 'path' = 'presets';        'implemented' = $false } # Not Started
  'Relations'       = @{ 'path' = 'relations';      'implemented' = $false } # Not Started
  'Revisions'       = @{ 'path' = 'revisions';      'implemented' = $false } # Not Started
  'Roles'           = @{ 'path' = 'roles';          'implemented' = $false } # Not Started
  'Schema'          = @{ 'path' = 'schema';         'implemented' = $false } # Not Started
  'Server'          = @{ 'path' = 'server';         'implemented' = $false } # Not Started
  'Settings'        = @{ 'path' = 'settings';       'implemented' = $false } # Not Started
  'Shares'          = @{ 'path' = 'shares';         'implemented' = $false } # Not Started
  'Translations'    = @{ 'path' = 'translations';   'implemented' = $false } # Not Started
  'Users'           = @{ 'path' = 'users';          'implemented' = $false } # Not Started
  'Utitlities'      = @{ 'path' = 'utilities';      'implemented' = $false } # Not Started
  'Versions'        = @{ 'path' = 'versions';       'implemented' = $false } # Not Started
}

# Template for Directus API headers with placeholders for dynamic values.
$Script:DirectusHeadersTemplate = @{
  'Authorization'     = "Bearer :token"
  'User-Agent'        = ":useragent"
}

Export-ModuleMember -Variable PSDirectusOptions, DirectusEndpoints, DirectusHeadersTemplate

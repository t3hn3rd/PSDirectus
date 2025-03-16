@{
  RootModule = 'PSDirectus.psm1'

  ModuleVersion = '1.0.1'

  GUID = '2aaa4afa-2973-4005-8ebb-f73bf6b65ff4'

  Author = 't3hn3rd (kjm@kieronmorris.me)'

  CompanyName = 'Spexeah'

  Description = 'PSDirectus - A PowerShell wrapper for the Directus API.'

  RequiredModules = @('PSMultipartFormData', 'PSMimeTypes')

  FunctionsToExport = @('New-PSDirectusContext', 
                        'New-PSDirectusFilter',

                        'Get-PSDirectusItemSingleton',
                        'Get-PSDirectusItem',
                        'New-PSDirectusItem',
                        'New-PSDirectusItems',
                        'Remove-PSDirectusItem',
                        'Remove-PSDirectusItems',
                        'Update-PSDirectusItemSingleton',
                        'Update-PSDirectusItem',
                        'Update-PSDirectusItems',

                        'Get-PSDirectusFile',
                        'New-PSDirectusFile',
                        'Remove-PSDirectusFile',
                        'Remove-PSDirectusFiles',
                        'Update-PSDirectusFile',
                        'Update-PSDirectusFiles',
                        'Import-PSDirectusFile'
                      )
  PrivateData = @{
    PSData = @{
      Tags = @('Directus', 'API', 'Module', 'Files', 'Items', 'CRUD', 'REST')
      LicenseUri = 'https://github.com/t3hn3rd/PSDirectus/blob/master/LICENSE'
      ProjectUri = 'https://github.com/t3hn3rd/PSDirectus'
      IconUri = 'https://github.com/t3hn3rd/PSDirectus/raw/master/media/icon_256.png'
    }
  }
}
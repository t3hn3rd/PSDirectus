@{
  ModuleVersion = '1.0.0'
  GUID = '2aaa4afa-2973-4005-8ebb-f73bf6b65ff4'
  Author = 'Kieron Morris'
  CompanyName = 'Spexeah'
  Description = 'PSDirectus - A PowerShell wrapper for the Directus API.'
  PowerShellVersion = '5.1'

  ScriptsToProcess = @(
    'PSDirectus.psm1'
  )

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
  CmdletsToExport = @()
  VariablesToExport = @()
  AliasToExport = @()

  RequiredModules = @()
}
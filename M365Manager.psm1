﻿$psGalleryDependencies = @(
    'Az'
    'AzureADPreview'
    'ExchangeOnlineManagement'
    'MicrosoftTeams'
    'MSOnline'
    'PnP.PowerShell'
)

$currentUserModules = Get-ChildItem ~/Documents/WindowsPowerShell/Modules -Depth 0 -Directory
$psGalleryDependencies | ForEach-Object {
    $dependencyName = $_
    if (-not ($dependencyName -in $currentUserModules.Name)) {
        try {
            Write-Host "Required dependency missing. Installing from PSGallery: " -NoNewline
            Write-Host $dependencyName -ForegroundColor Yellow
            Install-Module -Name $dependencyName `
                -Scope CurrentUser `
                -Force -AllowClobber `
                -WarningAction SilentlyContinue `
                -ErrorAction Stop
            if ($dependencyName -eq 'SharePointPnPPowerShellOnline') {
                Import-Module $dependencyName -WarningAction SilentlyContinue
            }
            else {
                Import-Module $dependencyName
            }
        }
        catch {
            throw "An error occurred while installing a required dependency for this module:`n$_"
        }
    }
    else {
        if ($dependencyName -eq 'SharePointPnPPowerShellOnline') {
            Import-Module $dependencyName -WarningAction SilentlyContinue
        }
        else {
            Import-Module $dependencyName
        }
    }
}

$moduleName = $PSScriptRoot.Split([System.IO.Path]::DirectorySeparatorChar)[-1]
$moduleManifest = "$PSScriptRoot\$moduleName.psd1"
$currentManifest = Test-ModuleManifest $moduleManifest

$aliases = @()
$publicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\ps1" | Where-Object {$_.Extension -eq '.ps1'}
$privateFunctions = Get-ChildItem -Path "$PSScriptRoot\Private\ps1" | Where-Object {$_.Extension -eq '.ps1'}
$publicFunctions | ForEach-Object { . $_.FullName }
$privateFunctions | ForEach-Object { . $_.FullName }

$functionsAdded = $publicFunctions | Where-Object {$_.BaseName -notin $currentManifest.ExportedFunctions.Keys}
$functionsRemoved = $currentManifest.ExportedFunctions.Keys | Where-Object {$_ -notin $publicFunctions.BaseName}
$aliasesAdded = $aliases | Where-Object {$_ -notin $currentManifest.ExportedAliases.Keys}
$aliasesRemoved = $currentManifest.ExportedAliases.Keys | Where-Object {$_ -notin $aliases}

$publicFunctions | ForEach-Object { # Export all of the public functions from this module

    # The command has already been sourced in above. Query any defined aliases.
    $alias = Get-Alias -Definition $_.BaseName -ErrorAction SilentlyContinue
    if ($alias) {
        $aliases += $alias
        Export-ModuleMember -Function $_.BaseName -Alias $alias
    }
    else {
        Export-ModuleMember -Function $_.BaseName
    }

}

if ($functionsAdded -or $functionsRemoved -or $aliasesAdded -or $aliasesRemoved) {

    try {

        $updateModuleManifestParams = @{}
        $updateModuleManifestParams.Add('Path', $moduleManifest)
        $updateModuleManifestParams.Add('ErrorAction', 'Stop')
        if ($aliases.Count -gt 0) { $updateModuleManifestParams.Add('AliasesToExport', $aliases) }
        if ($publicFunctions.Count -gt 0) { $updateModuleManifestParams.Add('FunctionsToExport', $publicFunctions.BaseName) }

        Update-ModuleManifest @updateModuleManifestParams

    }
    catch {

        $_ | Write-Error

    }

}

<#
    .SYNOPSIS
        syncFiles is just a robocopy wrapper
    .DESCRIPTION
        Simple params to sync safely (does not remove, not /mir).
        Gets the params from a config file.
        Supports dry run mode (no, it does not yet).
#>

Param(
    [CmdletBinding(PositionalBinding=$false)]
    [Parameter()] [string] $configFile = "config.json", # -configFile specifies the path of the JSON file for the script configuration values.
    [Parameter()] [string] $configName = "default",     # -configName indicates which settings to run robocopy with.
    [Parameter()] [bool] $dryRun = $true                # -dryRun enabled by default, will output the commands but don't do anything.
)

try {
    $config = Get-Content -Path $configFile | ConvertFrom-Json
}
catch {
    Write-Error -Message "Cannot load configuration file $configFile."
    exit 1
}

if (-Not $config.settings.$configName) {
    Write-Error -Message "Cannot find settings named $configName"
    exit 1
}

$settings = $config.settings.$configName

if (-Not (Test-Path -Path $config.logdir)) {
    New-Item $config.logdir -ItemType Directory
}

$now = Get-Date -Format "yyyyMMddHHmm"

Start-Process -FilePath "robocopy" -ArgumentList "$($settings.source) $($settings.destination) $($settings.parameters) /unilog:$($config.logdir)\$configName.$now.log.txt" -Wait
exit 0
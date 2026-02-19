param(
	[string]$GrocyConfigPath = '',
	[switch]$NoBackup
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$addonRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path
$addonFile = Join-Path $addonRoot 'dist\custom_js.html'

if (-not (Test-Path $addonFile))
{
	throw "Addon introuvable: $addonFile"
}

if ([string]::IsNullOrWhiteSpace($GrocyConfigPath))
{
	$autoConfig = Resolve-Path (Join-Path $addonRoot '..\config') -ErrorAction SilentlyContinue
	if ($autoConfig)
	{
		$GrocyConfigPath = $autoConfig.Path
	}
	else
	{
		throw 'GrocyConfigPath manquant et ../config introuvable.'
	}
}

$dataDir = Join-Path $GrocyConfigPath 'data'
$targetFile = Join-Path $dataDir 'custom_js.html'
$stateFile = Join-Path $dataDir 'grocy-addon-state.json'

if (-not (Test-Path $dataDir))
{
	New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

$backupFile = $null
if ((Test-Path $targetFile) -and (-not $NoBackup))
{
	$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
	$backupFile = Join-Path $dataDir ("custom_js.html.bak_addon_{0}" -f $ts)
	Copy-Item $targetFile $backupFile -Force
	Write-Host "Backup cree: $backupFile"
}

Copy-Item $addonFile $targetFile -Force

$state = [ordered]@{
	installed_at = (Get-Date).ToString('o')
	installed_by = 'install.ps1'
	addon_file = $addonFile
	target_file = $targetFile
	backup_file = $backupFile
}
$state | ConvertTo-Json | Set-Content -Encoding UTF8 $stateFile

Write-Host "Addon installe: $targetFile"
Write-Host "Etat: $stateFile"

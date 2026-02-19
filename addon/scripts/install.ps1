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
$payloadFileName = if ($env:ADDON_PAYLOAD_FILENAME) { $env:ADDON_PAYLOAD_FILENAME } else { 'custom_js_nerdstats.html' }
$activeFileName = if ($env:ACTIVE_TARGET_FILENAME) { $env:ACTIVE_TARGET_FILENAME } else { 'custom_js.html' }
$composeSourcesRaw = if ($env:COMPOSE_SOURCES) { $env:COMPOSE_SOURCES } else { 'custom_js_nerdcore.html,custom_js_nerdstats.html,custom_js_product_helper.html' }
$composeEnabled = if ($env:COMPOSE_ENABLED) { $env:COMPOSE_ENABLED } else { '1' }
$nerdCoreFileName = if ($env:NERDCORE_FILENAME) { $env:NERDCORE_FILENAME } else { 'custom_js_nerdcore.html' }

$targetFile = Join-Path $dataDir $payloadFileName
$activeFile = Join-Path $dataDir $activeFileName
$stateFile = Join-Path $dataDir 'statnerd-addon-state.json'
$nerdCoreFile = Join-Path $dataDir $nerdCoreFileName

function Compose-CustomJs {
	param(
		[string]$DataDir,
		[string]$ComposeSourcesRaw,
		[string]$ActiveTargetFile
	)

	if ($composeEnabled -match '^(0|false)$')
	{
		return $false
	}

	$sources = @($ComposeSourcesRaw.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
	$tmpFile = Join-Path ([System.IO.Path]::GetTempPath()) ("grocy-addon-compose-{0}.tmp" -f ([Guid]::NewGuid().ToString('N')))
	$parts = @('<!-- managed by install.ps1 (StatNerd) -->')
	$added = 0

	foreach ($src in $sources)
	{
		$path = Join-Path $DataDir $src
		if (-not (Test-Path $path)) { continue }
		$content = Get-Content -Raw -Path $path -ErrorAction SilentlyContinue
		if ([string]::IsNullOrWhiteSpace($content)) { continue }
		$parts += ''
		$parts += "<!-- source: $src -->"
		$parts += $content
		$added++
	}

	if ($added -le 0)
	{
		return $false
	}

	[System.IO.File]::WriteAllText($tmpFile, ($parts -join [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
	Move-Item $tmpFile $ActiveTargetFile -Force
	return $true
}

if (-not (Test-Path $dataDir))
{
	New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

if (-not (Test-Path $nerdCoreFile))
{
	throw "NerdCore requis. Fichier manquant: $nerdCoreFile"
}

$backupFile = $null
if ((Test-Path $activeFile) -and (-not $NoBackup))
{
	$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
	$backupFile = Join-Path $dataDir ("custom_js.html.bak_addon_{0}" -f $ts)
	Copy-Item $activeFile $backupFile -Force
	Write-Host "Backup cree: $backupFile"
}

Copy-Item $addonFile $targetFile -Force

if (-not (Compose-CustomJs -DataDir $dataDir -ComposeSourcesRaw $composeSourcesRaw -ActiveTargetFile $activeFile))
{
	Copy-Item $targetFile $activeFile -Force
}

$state = [ordered]@{
	installed_at = (Get-Date).ToString('o')
	installed_by = 'install.ps1'
	addon_file = $addonFile
	target_file = $targetFile
	active_file = $activeFile
	backup_file = $backupFile
}
$state | ConvertTo-Json | Set-Content -Encoding UTF8 $stateFile

Write-Host "Payload addon installe: $targetFile"
Write-Host "Fichier actif compose: $activeFile"
Write-Host "Etat: $stateFile"


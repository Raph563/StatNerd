param(
	[string]$GrocyConfigPath = ''
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$addonRoot = (Resolve-Path (Join-Path $scriptDir '..')).Path

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

$targetFile = Join-Path $dataDir $payloadFileName
$activeFile = Join-Path $dataDir $activeFileName
$stateFile = Join-Path $dataDir 'statnerd-addon-state.json'

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
	$parts = @('<!-- managed by uninstall.ps1 (StatNerd) -->')
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

	$payload = $parts -join [Environment]::NewLine
	[System.IO.File]::WriteAllText($ActiveTargetFile, $payload, [System.Text.UTF8Encoding]::new($false))
	return $true
}

if (-not (Test-Path $dataDir))
{
	throw "Dossier data introuvable: $dataDir"
}

$restoreFile = $null
if (Test-Path $stateFile)
{
	try
	{
		$state = Get-Content $stateFile -Raw | ConvertFrom-Json
		if ($state.backup_file -and (Test-Path $state.backup_file))
		{
			$restoreFile = $state.backup_file
		}
	}
	catch
	{
		Write-Warning "Etat addon illisible: $stateFile"
	}
}

if (Test-Path $targetFile)
{
	Remove-Item $targetFile -Force
}
if (Test-Path $stateFile)
{
	Remove-Item $stateFile -Force
}

if (Compose-CustomJs -DataDir $dataDir -ComposeSourcesRaw $composeSourcesRaw -ActiveTargetFile $activeFile)
{
	Write-Host "Addon retire: $targetFile"
	Write-Host "Fichier actif recompose: $activeFile"
	exit 0
}

if (-not $restoreFile)
{
	$latestBackup = Get-ChildItem $dataDir -Filter 'custom_js.html.bak_addon_*' -ErrorAction SilentlyContinue |
		Sort-Object LastWriteTime -Descending |
		Select-Object -First 1
	if ($latestBackup)
	{
		$restoreFile = $latestBackup.FullName
	}
}

if ($restoreFile -and (Test-Path $restoreFile))
{
	Copy-Item $restoreFile $activeFile -Force
	Write-Host "Restaure depuis: $restoreFile"
	Write-Host "Fichier actif: $activeFile"
	exit 0
}

if (Test-Path $activeFile)
{
	Remove-Item $activeFile -Force
}

Write-Host "Addon retire: $targetFile"
Write-Host "Aucun autre addon actif, fichier supprime: $activeFile"


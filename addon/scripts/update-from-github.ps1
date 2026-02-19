param(
	[string]$Repository = 'Raph563/Grocy',
	[string]$ReleaseTag = '',
	[string]$GrocyConfigPath = '',
	[switch]$NoBackup,
	[switch]$AllowPrerelease,
	[switch]$AllowDowngrade
)

$ErrorActionPreference = 'Stop'

function Resolve-RepositoryParts {
	param([string]$RepositoryValue)
	$text = [string]$RepositoryValue
	$text = $text.Trim()
	if ([string]::IsNullOrWhiteSpace($text))
	{
		throw 'Repository is required (expected owner/repo).'
	}

	$text = $text -replace '^https?://github\.com/', ''
	$text = $text -replace '\.git$', ''
	$text = $text.Trim('/')

	$parts = $text.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries)
	if ($parts.Count -lt 2)
	{
		throw "Invalid repository: $RepositoryValue (expected owner/repo)"
	}

	$owner = $parts[0]
	$name = $parts[1]
	if ($owner -notmatch '^[A-Za-z0-9_.-]+$' -or $name -notmatch '^[A-Za-z0-9_.-]+$')
	{
		throw "Invalid repository: $RepositoryValue (expected owner/repo)"
	}

	return [ordered]@{
		Owner = $owner
		Name = $name
		Repository = "$owner/$name"
	}
}

function Resolve-GrocyConfigPath {
	param(
		[string]$ConfigPathInput,
		[string]$ScriptDir
	)

	if ([string]::IsNullOrWhiteSpace($ConfigPathInput))
	{
		$autoConfig = Resolve-Path (Join-Path $ScriptDir '..\..\config') -ErrorAction SilentlyContinue
		if ($autoConfig)
		{
			return $autoConfig.Path
		}
		throw 'GrocyConfigPath missing and ../config not found.'
	}

	$resolved = Resolve-Path $ConfigPathInput -ErrorAction SilentlyContinue
	if ($resolved)
	{
		return $resolved.Path
	}
	if (Test-Path $ConfigPathInput)
	{
		return (Get-Item $ConfigPathInput).FullName
	}
	throw "Grocy config path not found: $ConfigPathInput"
}

function Get-ReleasePayload {
	param(
		[string]$ApiBase,
		[string]$RequestedTag,
		[switch]$UsePrerelease
	)

	$headers = @{
		Accept = 'application/vnd.github+json'
		'X-GitHub-Api-Version' = '2022-11-28'
	}

	if (-not [string]::IsNullOrWhiteSpace($RequestedTag))
	{
		$tag = $RequestedTag.Trim()
		if ($tag -notmatch '^v')
		{
			$tag = "v$tag"
		}
		$uri = "$ApiBase/releases/tags/$([Uri]::EscapeDataString($tag))"
		return Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
	}

	if ($UsePrerelease)
	{
		$rows = Invoke-RestMethod -Uri "$ApiBase/releases?per_page=20" -Headers $headers -Method Get
		if ($rows -isnot [System.Array])
		{
			$rows = @($rows)
		}
		$release = $rows | Where-Object { $_.draft -ne $true } | Select-Object -First 1
		if (-not $release)
		{
			throw 'No GitHub release found.'
		}
		return $release
	}

	try
	{
		return Invoke-RestMethod -Uri "$ApiBase/releases/latest" -Headers $headers -Method Get
	}
	catch
	{
		$statusCode = $null
		try { $statusCode = $_.Exception.Response.StatusCode.value__ } catch {}
		if ($statusCode -eq 404)
		{
			throw 'No GitHub release found.'
		}
		throw
	}
}

function Get-InstalledReleaseTag {
	param([string]$StateFilePath)
	if (-not (Test-Path $StateFilePath))
	{
		return ''
	}
	try
	{
		$payload = Get-Content -Path $StateFilePath -Raw | ConvertFrom-Json
		$tag = [string]($payload.release_tag)
		$tag = $tag.Trim()
		if ([string]::IsNullOrWhiteSpace($tag))
		{
			return ''
		}
		if ($tag -notmatch '^v')
		{
			$tag = "v$tag"
		}
		return $tag
	}
	catch
	{
		return ''
	}
}

function Parse-AddonTag {
	param([string]$TagInput)
	$tag = [string]$TagInput
	$tag = $tag.Trim()
	$tag = $tag -replace '^v', ''
	$match = [regex]::Match($tag, '^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?$')
	if (-not $match.Success)
	{
		return $null
	}
	return [ordered]@{
		major = [int]$match.Groups[1].Value
		minor = [int]$match.Groups[2].Value
		patch = [int]$match.Groups[3].Value
		pre = [string]$match.Groups[4].Value
	}
}

function Compare-Prerelease {
	param(
		[string]$LeftPre,
		[string]$RightPre
	)
	$l = [string]$LeftPre
	$r = [string]$RightPre
	if ([string]::IsNullOrWhiteSpace($l) -and [string]::IsNullOrWhiteSpace($r)) { return 0 }
	if ([string]::IsNullOrWhiteSpace($l)) { return 1 }
	if ([string]::IsNullOrWhiteSpace($r)) { return -1 }

	$lParts = $l.Split(@('.', '-'), [System.StringSplitOptions]::RemoveEmptyEntries)
	$rParts = $r.Split(@('.', '-'), [System.StringSplitOptions]::RemoveEmptyEntries)
	$max = [Math]::Max($lParts.Count, $rParts.Count)
	for ($i = 0; $i -lt $max; $i++)
	{
		if ($i -ge $lParts.Count) { return -1 }
		if ($i -ge $rParts.Count) { return 1 }
		$li = [string]$lParts[$i]
		$ri = [string]$rParts[$i]
		$lNum = 0
		$rNum = 0
		$lIsNum = [int]::TryParse($li, [ref]$lNum)
		$rIsNum = [int]::TryParse($ri, [ref]$rNum)
		if ($lIsNum -and $rIsNum)
		{
			if ($lNum -lt $rNum) { return -1 }
			if ($lNum -gt $rNum) { return 1 }
			continue
		}
		if ($lIsNum -and -not $rIsNum) { return -1 }
		if (-not $lIsNum -and $rIsNum) { return 1 }
		$cmp = [string]::Compare($li, $ri, $true)
		if ($cmp -lt 0) { return -1 }
		if ($cmp -gt 0) { return 1 }
	}
	return 0
}

function Compare-AddonTag {
	param(
		[string]$LeftTag,
		[string]$RightTag
	)
	$l = Parse-AddonTag -TagInput $LeftTag
	$r = Parse-AddonTag -TagInput $RightTag
	if ($null -eq $l -or $null -eq $r) { return 0 }
	if ($l.major -ne $r.major) { return $(if ($l.major -lt $r.major) { -1 } else { 1 }) }
	if ($l.minor -ne $r.minor) { return $(if ($l.minor -lt $r.minor) { -1 } else { 1 }) }
	if ($l.patch -ne $r.patch) { return $(if ($l.patch -lt $r.patch) { -1 } else { 1 }) }
	return Compare-Prerelease -LeftPre $l.pre -RightPre $r.pre
}

function Compose-CustomJs {
	param(
		[string]$DataDir,
		[string]$ComposeSourcesRaw,
		[string]$ActiveTargetFile,
		[string]$ComposeEnabled,
		[string]$SourceLabel
	)

	if ([string]$ComposeEnabled -match '^(0|false)$')
	{
		return $false
	}

	$sources = @($ComposeSourcesRaw.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
	$parts = @("<!-- managed by update-from-github.ps1 ($SourceLabel) -->")
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

	[System.IO.File]::WriteAllText($ActiveTargetFile, ($parts -join [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false))
	return $true
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$grocyConfigResolved = Resolve-GrocyConfigPath -ConfigPathInput $GrocyConfigPath -ScriptDir $scriptDir
$dataDir = Join-Path $grocyConfigResolved 'data'
$payloadFileName = if ($env:ADDON_PAYLOAD_FILENAME) { $env:ADDON_PAYLOAD_FILENAME } else { 'custom_js_nerdstats.html' }
$activeFileName = if ($env:ACTIVE_TARGET_FILENAME) { $env:ACTIVE_TARGET_FILENAME } else { 'custom_js.html' }
$composeSourcesRaw = if ($env:COMPOSE_SOURCES) { $env:COMPOSE_SOURCES } else { 'custom_js_nerdstats.html,custom_js_product_helper.html' }
$composeEnabled = if ($env:COMPOSE_ENABLED) { $env:COMPOSE_ENABLED } else { '1' }
$targetFile = Join-Path $dataDir $payloadFileName
$activeFile = Join-Path $dataDir $activeFileName
$stateFile = Join-Path $dataDir 'grocy-addon-state.json'

if (-not (Test-Path $dataDir))
{
	New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

$repo = Resolve-RepositoryParts -RepositoryValue $Repository
$apiBase = "https://api.github.com/repos/$($repo.Owner)/$($repo.Name)"

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("grocy-addon-update-{0}" -f ([Guid]::NewGuid().ToString('N')))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

try
{
	$release = Get-ReleasePayload -ApiBase $apiBase -RequestedTag $ReleaseTag -UsePrerelease:$AllowPrerelease
	if (-not $release)
	{
		throw 'No GitHub release found.'
	}
	$requestedTag = [string]$release.tag_name
	$currentTag = Get-InstalledReleaseTag -StateFilePath $stateFile
	if (-not $AllowDowngrade -and -not [string]::IsNullOrWhiteSpace($currentTag))
	{
		$cmp = Compare-AddonTag -LeftTag $requestedTag -RightTag $currentTag
		if ($cmp -lt 0)
		{
			throw "Refusing downgrade from $currentTag to $requestedTag. Use -AllowDowngrade to force."
		}
	}

	$assets = @($release.assets)
	$asset = $assets | Where-Object { $_.name -match '^grocy-addon-v.+\.zip$' } | Select-Object -First 1
	if (-not $asset)
	{
		$asset = $assets | Where-Object { $_.name -match '\.zip$' } | Select-Object -First 1
	}
	if (-not $asset)
	{
		throw "No ZIP asset found in release $($release.tag_name)."
	}

	$archiveFile = Join-Path $tempRoot ([string]$asset.name)
	Invoke-WebRequest -Uri ([string]$asset.browser_download_url) -OutFile $archiveFile -Headers @{ Accept = 'application/octet-stream' }

	$extractDir = Join-Path $tempRoot 'extract'
	Expand-Archive -Path $archiveFile -DestinationPath $extractDir -Force

	$addonFile = Join-Path $extractDir 'addon\dist\custom_js.html'
	if (-not (Test-Path $addonFile))
	{
		$fallback = Get-ChildItem -Path $extractDir -Recurse -Filter custom_js.html -File |
			Where-Object { $_.FullName -match 'addon[\\/]+dist[\\/]+custom_js\.html$' } |
			Select-Object -First 1
		if ($fallback)
		{
			$addonFile = $fallback.FullName
		}
	}

	if (-not (Test-Path $addonFile))
	{
		throw "custom_js.html not found in release archive ($($asset.name))."
	}

	$backupFile = $null
	if ((Test-Path $activeFile) -and (-not $NoBackup))
	{
		$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
		$backupFile = Join-Path $dataDir ("custom_js.html.bak_addon_{0}" -f $ts)
		Copy-Item $activeFile $backupFile -Force
		Write-Host "Backup created: $backupFile"
	}

	Copy-Item $addonFile $targetFile -Force
	if (-not (Compose-CustomJs -DataDir $dataDir -ComposeSourcesRaw $composeSourcesRaw -ActiveTargetFile $activeFile -ComposeEnabled $composeEnabled -SourceLabel 'Grocy'))
	{
		Copy-Item $targetFile $activeFile -Force
	}

	$state = [ordered]@{
		installed_at = (Get-Date).ToString('o')
		installed_by = 'update-from-github.ps1'
		repository = $repo.Repository
		release_tag = [string]$release.tag_name
		release_url = [string]$release.html_url
		asset_name = [string]$asset.name
		asset_url = [string]$asset.browser_download_url
		target_file = $targetFile
		active_file = $activeFile
		backup_file = $backupFile
	}
	$state | ConvertTo-Json | Set-Content -Encoding UTF8 $stateFile

	Write-Host "Addon payload updated: $targetFile"
	Write-Host "Active file composed: $activeFile"
	Write-Host "Release: $($release.tag_name)"
	Write-Host "State: $stateFile"
}
finally
{
	Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

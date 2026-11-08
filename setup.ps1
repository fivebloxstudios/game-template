# FiveBlox Studios project setup. Safe to run again at any time.
# Windows only. Run with:
#   powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/fivebloxstudios/game-template/main/setup.ps1 | iex"

$ErrorActionPreference = 'Stop'

$Organization = 'fivebloxstudios'
$TemplateName = 'game-template'
$ProjectsFolder = Join-Path $HOME 'FiveBlox'

function Invoke-Checked {
	param([string]$Command, [string[]]$Arguments)
	& $Command @Arguments | Out-Host
	if ($LASTEXITCODE -ne 0) { throw "'$Command $($Arguments -join ' ')' failed." }
}

function Update-SessionPath {
	$machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
	$user = [Environment]::GetEnvironmentVariable('Path', 'User')
	$env:Path = "$machine;$user"
}

function Install-IfMissing {
	param([string]$Command, [string]$PackageId)
	if (Get-Command $Command -ErrorAction SilentlyContinue) { return }
	Write-Host "Installing $Command..."
	Invoke-Checked 'winget' @('install', '--id', $PackageId, '--exact', '--source', 'winget', '--accept-package-agreements', '--accept-source-agreements')
	Update-SessionPath
}

function Add-MiseShimsToPath {
	$shims = Join-Path $env:LOCALAPPDATA 'mise\shims'
	$user = [Environment]::GetEnvironmentVariable('Path', 'User')
	if ($user -notlike "*$shims*") {
		[Environment]::SetEnvironmentVariable('Path', "$user;$shims", 'User')
	}
	if ($env:Path -notlike "*$shims*") { $env:Path = "$env:Path;$shims" }
}

function Read-PlaceNumber {
	param([string]$Prompt)
	while ($true) {
		$answer = Read-Host $Prompt
		if ($answer -match '\d{5,}') { return $Matches[0] }
		Write-Host 'That should be a long number, like 1234567890.'
	}
}

function Replace-InFile {
	param([string]$Path, [string]$Old, [string]$New)
	$text = [IO.File]::ReadAllText($Path)
	[IO.File]::WriteAllText($Path, $text.Replace($Old, $New))
}

function Connect-GitHub {
	& gh auth status *> $null
	if ($LASTEXITCODE -ne 0) {
		Write-Host 'Log in with YOUR OWN GitHub account in the browser window.'
		Invoke-Checked 'gh' @('auth', 'login', '--web', '--git-protocol', 'https', '--hostname', 'github.com')
	}
	Invoke-Checked 'gh' @('auth', 'setup-git')
}

function New-Game {
	$name = (Read-Host 'Game folder name, lowercase with dashes (like box-for-eggs)').Trim().ToLower()
	if ($name -notmatch '^[a-z0-9][a-z0-9-]*$') { throw 'Use only lowercase letters, numbers and dashes.' }

	Write-Host ''
	Write-Host 'Create the experience first: publish a new place to the FiveBlox group and turn on Team Create.'
	$universe = Read-PlaceNumber 'Universe ID (Creator Hub > the experience > Overview, in the page address)'
	$teamPlace = Read-PlaceNumber 'Team place ID (the start place of that experience)'

	$path = Join-Path $ProjectsFolder $name
	Invoke-Checked 'gh' @('repo', 'create', "$Organization/$name", '--private', '--template', "$Organization/$TemplateName")
	Start-Sleep -Seconds 3
	Invoke-Checked 'gh' @('repo', 'clone', "$Organization/$name", $path)

	foreach ($file in '.rogen.json', 'wally.toml', 'wally.lock', 'CLAUDE.md') {
		Replace-InFile (Join-Path $path $file) $TemplateName $name
	}
	$miseFile = Join-Path $path 'mise.toml'
	Replace-InFile $miseFile 'UNIVERSE_ID = "0"' "UNIVERSE_ID = `"$universe`""
	Replace-InFile $miseFile 'TEAM_PLACE_ID = "0"' "TEAM_PLACE_ID = `"$teamPlace`""

	Set-GitIdentity $path
	Invoke-Checked 'git' @('-C', $path, 'add', '-A')
	Invoke-Checked 'git' @('-C', $path, 'commit', '-m', 'project setup')
	Invoke-Checked 'git' @('-C', $path, 'push')
	return $path
}

function Join-Game {
	$games = @(& gh repo list $Organization --limit 100 --json name --jq '.[].name' | Where-Object { $_ -ne $TemplateName })
	if ($games.Count -eq 0) { throw "No games found in $Organization. Has someone added you to the organization?" }
	for ($index = 0; $index -lt $games.Count; $index++) {
		Write-Host "  $($index + 1). $($games[$index])"
	}
	$choice = [int](Read-Host 'Which game? Type its number')
	if ($choice -lt 1 -or $choice -gt $games.Count) { throw 'That number is not in the list.' }

	$name = $games[$choice - 1]
	$path = Join-Path $ProjectsFolder $name
	if (Test-Path (Join-Path $path '.git')) {
		Invoke-Checked 'git' @('-C', $path, 'pull', '--ff-only')
	} else {
		Invoke-Checked 'gh' @('repo', 'clone', "$Organization/$name", $path)
	}
	return $path
}

function Set-GitIdentity {
	param([string]$Path)
	$login = & gh api user --jq '.login'
	$id = & gh api user --jq '.id'
	$displayName = & gh api user --jq '.name // .login'
	Invoke-Checked 'git' @('-C', $Path, 'config', 'user.name', $displayName)
	Invoke-Checked 'git' @('-C', $Path, 'config', 'user.email', "$id+$login@users.noreply.github.com")
}

function Register-TestPlace {
	param([string]$Path)
	$envFile = Join-Path $Path '.env'
	if (Test-Path $envFile) { return }

	Write-Host ''
	Write-Host 'You need your own test place. In Studio: open the game, View > Asset Manager > Places, Add New Place.'
	Write-Host 'Name it after yourself, then right-click it and choose Copy ID.'
	$place = Read-PlaceNumber 'Your test place ID'
	[IO.File]::WriteAllText($envFile, "MY_PLACE_ID=$place`n")

	$configFile = Join-Path $Path '.rogen.json'
	$config = [IO.File]::ReadAllText($configFile)
	if ($config -match "\b$place\b") { return }

	Invoke-Checked 'git' @('-C', $Path, 'pull', '--ff-only')
	$config = [IO.File]::ReadAllText($configFile)
	$list = [regex]::Match($config, '"servePlaceIds":\s*\[([^\]]*)\]')
	$places = @([regex]::Matches($list.Groups[1].Value, '\d+') | ForEach-Object { $_.Value }) + $place
	[IO.File]::WriteAllText($configFile, $config.Replace($list.Value, '"servePlaceIds": [' + ($places -join ', ') + ']'))
	Invoke-Checked 'git' @('-C', $Path, 'add', '.rogen.json')
	Invoke-Checked 'git' @('-C', $Path, 'commit', '-m', 'add test place')
	Invoke-Checked 'git' @('-C', $Path, 'push')
}

function Initialize-Project {
	param([string]$Path)
	Set-GitIdentity $Path
	Register-TestPlace $Path

	Push-Location $Path
	try {
		Invoke-Checked 'mise' @('trust', '--yes')
		Invoke-Checked 'mise' @('install', '--yes')
		Invoke-Checked 'mise' @('run', 'types')
		Invoke-Checked 'mise' @('exec', '--', 'rojo', 'plugin', 'install')
	} finally {
		Pop-Location
	}
}

Install-IfMissing 'git' 'Git.Git'
Install-IfMissing 'gh' 'GitHub.cli'
Install-IfMissing 'mise' 'jdx.mise'
Add-MiseShimsToPath
Connect-GitHub
New-Item -ItemType Directory -Force $ProjectsFolder | Out-Null

Write-Host ''
Write-Host '  1. Join a game that already exists'
Write-Host '  2. Create a brand new game'
$projectPath = if ((Read-Host 'Type 1 or 2') -eq '2') { New-Game } else { Join-Game }
Initialize-Project $projectPath

Write-Host ''
Write-Host "All set. Your project is in $projectPath"
Write-Host 'Last steps, once per PC:'
Write-Host '  1. Restart Roblox Studio.'
Write-Host '  2. In Studio: Assistant > ... > Manage MCP Servers > turn on Enable Studio as MCP server.'
Write-Host '  3. Open that folder in Claude Code and type /start'

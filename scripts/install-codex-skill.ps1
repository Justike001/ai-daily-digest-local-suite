[CmdletBinding()]
param(
  [string]$RepoDir = "",
  [string]$CodexHome = "",
  [ValidateSet("Link", "Copy")]
  [string]$Mode = "Link",
  [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not $CodexHome) {
  if ($env:CODEX_HOME) {
    $CodexHome = $env:CODEX_HOME
  } else {
    $CodexHome = Join-Path $HOME ".codex"
  }
}

if (-not $RepoDir) {
  $RepoDir = Join-Path $PSScriptRoot ".."
}

$repoPath = (Resolve-Path $RepoDir).Path
$skillName = "ai-daily-digest"
$sourceSkill = Join-Path $repoPath "SKILL.md"

if (-not (Test-Path $sourceSkill)) {
  throw "SKILL.md not found in repo path: $repoPath"
}

$skillsDir = Join-Path $CodexHome "skills"
$targetPath = Join-Path $skillsDir $skillName

if (-not (Test-Path $skillsDir)) {
  New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
}

if (Test-Path $targetPath) {
  if (-not $Force) {
    throw "Target already exists: $targetPath`nRe-run with -Force to overwrite."
  }
  Remove-Item -Path $targetPath -Recurse -Force
}

if ($Mode -eq "Link") {
  cmd /c "mklink /J `"$targetPath`" `"$repoPath`""
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to create junction link. Try -Mode Copy instead."
  }
} else {
  $repoFull = [System.IO.Path]::GetFullPath($repoPath).TrimEnd('\')
  $targetFull = [System.IO.Path]::GetFullPath($targetPath).TrimEnd('\')
  if ($targetFull.StartsWith($repoFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to copy into a path inside RepoDir. Choose a different CodexHome."
  }

  New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
  robocopy $repoPath $targetPath /E /XD .git output .idea .vscode /NFL /NDL /NJH /NJS /NC /NS | Out-Null
  if ($LASTEXITCODE -ge 8) {
    throw "Copy failed with robocopy exit code: $LASTEXITCODE"
  }
}

$installedSkill = Join-Path $targetPath "SKILL.md"
if (-not (Test-Path $installedSkill)) {
  throw "Install finished but SKILL.md missing at: $installedSkill"
}

Write-Host "Installed skill to: $targetPath"
Write-Host "Mode: $Mode"
Write-Host "SKILL.md: $installedSkill"
Write-Host "Restart Codex to pick up new skills."
